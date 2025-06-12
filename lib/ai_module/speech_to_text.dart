import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../widgets/banner_ad_widget.dart';

class VoiceToTextHelperScreen extends StatefulWidget {
  const VoiceToTextHelperScreen({Key? key}) : super(key: key);

  @override
  State<VoiceToTextHelperScreen> createState() => _VoiceToTextHelperScreenState();
}

class _VoiceToTextHelperScreenState extends State<VoiceToTextHelperScreen>
    with SingleTickerProviderStateMixin {
  late stt.SpeechToText _speech;
  final FlutterTts _flutterTts = FlutterTts();

  bool _isListening = false;
  final TextEditingController _textController = TextEditingController();

  AnimationController? _animationController;
  late Animation<double> _pulseAnimation;

  List<dynamic> _voices = [];
  String? _selectedVoice;

  List<String> _locales = [];
  String? _selectedLocale;

  double _speechRate = 0.5;
  double _pitch = 1.0;

  bool _isDarkTheme = true;

  // Colors matching TravelPlannerScreen
  final List<Color> shadowColors = [
    const Color(0xFF00E5FF), // Cyan
    const Color(0xFF7C4DFF), // Purple
    const Color(0xFFFF9100), // Orange
    const Color(0xFFFF4081), // Pink
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      lowerBound: 0.95,
      upperBound: 1.0,
    );
    _pulseAnimation = CurvedAnimation(
      parent: _animationController!,
      curve: Curves.easeOut,
    );

    _initSpeechRecognition();
    _initTTS();
    _loadSavedText();
  }

  Future<void> _loadSavedText() async {
    final prefs = await SharedPreferences.getInstance();
    final savedText = prefs.getString('voice_to_text_saved_note') ?? '';
    setState(() {
      _textController.text = savedText;
    });
  }

  Future<void> _saveText() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('voice_to_text_saved_note', _textController.text);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Note saved locally!', style: GoogleFonts.poppins()),
        backgroundColor: shadowColors[2],
      ),
    );
  }

  Future<void> _loadText() async {
    final prefs = await SharedPreferences.getInstance();
    final savedText = prefs.getString('voice_to_text_saved_note');
    if (savedText != null && savedText.isNotEmpty) {
      setState(() {
        _textController.text = savedText;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Note loaded!', style: GoogleFonts.poppins()),
          backgroundColor: shadowColors[0],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No saved note found.', style: GoogleFonts.poppins()),
          backgroundColor: shadowColors[3],
        ),
      );
    }
  }

  Future<void> _initTTS() async {
    await _flutterTts.awaitSpeakCompletion(true);

    List<dynamic> voices = await _flutterTts.getVoices;
    if (voices.isNotEmpty) {
      setState(() {
        _voices = voices;
        _selectedVoice = voices.first['name'];
        _selectedLocale = voices.first['locale'];
      });

      final localesSet = <String>{};
      for (var v in voices) {
        if (v['locale'] != null) {
          localesSet.add(v['locale']);
        }
      }
      _locales = localesSet.toList();
    }
  }

  void _initSpeechRecognition() async {
    final status = await Permission.microphone.request();
    if (status.isGranted) {
      _speech = stt.SpeechToText();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Microphone permission is required.',
              style: GoogleFonts.poppins()),
          backgroundColor: shadowColors[3],
        ),
      );
    }
  }

  void _listen() async {
    HapticFeedback.mediumImpact();
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
            setState(() => _isListening = false);
          }
        },
        onError: (error) {
          setState(() => _isListening = false);
          debugPrint('Speech recognition error: $error');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Speech recognition error: $error',
                  style: GoogleFonts.poppins()),
              backgroundColor: shadowColors[3],
            ),
          );
        },
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          localeId: _selectedLocale,
          onResult: (result) => setState(() {
            _textController.text = result.recognizedWords;
            _textController.selection = TextSelection.fromPosition(
                TextPosition(offset: _textController.text.length));
          }),
        );
      } else {
        setState(() => _isListening = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Speech recognition not available.',
                style: GoogleFonts.poppins()),
            backgroundColor: shadowColors[3],
          ),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  void _speak() async {
    if (_selectedVoice != null) {
      try {
        final voice = _voices.firstWhere((v) => v['name'] == _selectedVoice,
            orElse: () => {});
        if (voice.isNotEmpty) {
          await _flutterTts.setVoice(
              {"name": voice["name"], "locale": voice["locale"]});
        }
      } catch (e) {
        debugPrint('Error setting voice: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error setting voice: $e', style: GoogleFonts.poppins()),
            backgroundColor: shadowColors[3],
          ),
        );
      }
    }
    try {
      await _flutterTts.setPitch(_pitch);
      await _flutterTts.setSpeechRate(_speechRate);
      await _flutterTts.speak(_textController.text);
    } catch (e) {
      debugPrint('Error speaking: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error speaking: $e', style: GoogleFonts.poppins()),
          backgroundColor: shadowColors[3],
        ),
      );
    }
  }

  Future<void> _exportToTxt() async {
    if (_textController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Text is empty, cannot export.',
              style: GoogleFonts.poppins()),
          backgroundColor: shadowColors[3],
        ),
      );
      return;
    }

    if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Storage permission denied.',
                style: GoogleFonts.poppins()),
            backgroundColor: shadowColors[3],
          ),
        );
        return;
      }
    }

    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File(
          '${dir.path}/voice_to_text_export_${DateTime.now().millisecondsSinceEpoch}.txt');
      await file.writeAsString(_textController.text);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Exported to ${file.path}',
              style: GoogleFonts.poppins()),
          backgroundColor: shadowColors[0],
        ),
      );
    } catch (e) {
      debugPrint('Export error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to export file.', style: GoogleFonts.poppins()),
          backgroundColor: shadowColors[3],
        ),
      );
    }
  }

  void _shareText() {
    if (_textController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Nothing to share.', style: GoogleFonts.poppins()),
          backgroundColor: shadowColors[3],
        ),
      );
      return;
    }
    Share.share(_textController.text);
  }

  void _toggleTheme() {
    setState(() {
      _isDarkTheme = !_isDarkTheme;
    });
  }

  InputDecoration customInputDecoration(String label, Color focusColor) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.poppins(
        color: Colors.white70,
        fontWeight: FontWeight.w600,
        fontSize: 15,
      ),
      filled: true,
      fillColor: const Color(0xFF1E1E1E),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: focusColor, width: 2.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      isDense: true,
    );
  }

  @override
  void dispose() {
    _animationController?.dispose();
    _flutterTts.stop();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textColor = _isDarkTheme ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Match TravelPlannerScreen
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
        title: Text(
          'Voice-to-Text Helper',
          style: GoogleFonts.poppins(
            color: textColor,
            fontWeight: FontWeight.w600,
            fontSize: 22.sp,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Save Note',
            icon: Icon(Icons.save, color: textColor, size: 24.sp),
            onPressed: _textController.text.trim().isNotEmpty ? _saveText : null,
          ),
          IconButton(
            tooltip: 'Load Note',
            icon: Icon(Icons.folder_open, color: textColor, size: 24.sp),
            onPressed: _loadText,
          ),
          IconButton(
            tooltip: 'Export as .txt',
            icon: Icon(Icons.file_download, color: textColor, size: 24.sp),
            onPressed: _exportToTxt,
          ),
          IconButton(
            tooltip: 'Share Text',
            icon: Icon(Icons.share, color: textColor, size: 24.sp),
            onPressed: _textController.text.trim().isNotEmpty ? _shareText : null,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 20.h),
          child: ListView(
            physics: const BouncingScrollPhysics(),
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: const BannerAdWidget(),
              ),
              Text(
                'Speak and Convert 🎤➡️🗣️',
                style: GoogleFonts.poppins(
                  fontSize: 30.sp,
                  color: textColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                'Convert speech to text and back with style',
                style: GoogleFonts.roboto(
                  fontSize: 16.sp,
                  color: textColor.withOpacity(0.7),
                  height: 1.3,
                ),
              ),
              SizedBox(height: 28.h),
              _buildInputCard(
                label: 'Your Text',
                controller: _textController,
                shadowColor: shadowColors[0],
                focusColor: shadowColors[0],
              ),
              SizedBox(height: 16.h),
              _buildVoiceSelector(textColor, shadowColors[1]),
              SizedBox(height: 16.h),
              _buildSliders(textColor, shadowColors[2]),
              SizedBox(height: 50.h),
              _buildActionButtons(textColor, shadowColors[3]),
              SizedBox(height: 50.h),
              _buildClearCopyButtons(textColor, shadowColors[0]),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: const BannerAdWidget(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputCard({
    required String label,
    required TextEditingController controller,
    required Color shadowColor,
    required Color focusColor,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: shadowColor.withOpacity(0.5),
            blurRadius: 14.r,
            offset: Offset(0, 7.h),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        maxLines: null,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 16.sp,
          letterSpacing: 0.4,
        ),
        decoration: customInputDecoration(label, focusColor).copyWith(
          hintText: 'Your text will appear here...',
          hintStyle: GoogleFonts.poppins(
            color: Colors.white70,
            fontSize: 15.sp,
          ),
        ),
      ),
    );
  }

  Widget _buildVoiceSelector(Color textColor, Color shadowColor) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: shadowColor.withOpacity(0.5),
            blurRadius: 14.r,
            offset: Offset(0, 7.h),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          dropdownColor: const Color(0xFF1E1E1E),
          isExpanded: true,
          value: _selectedVoice,
          iconEnabledColor: textColor,
          style: GoogleFonts.poppins(color: textColor, fontSize: 16.sp),
          items: _voices.map((voice) {
            final name = voice['name'] ?? 'Unknown';
            final locale = voice['locale'] ?? '';
            return DropdownMenuItem<String>(
              value: name,
              child: Text('$name ($locale)',
                  style: GoogleFonts.poppins(color: textColor)),
            );
          }).toList(),
          onChanged: (newVal) {
            setState(() {
              _selectedVoice = newVal;
              final matchedVoice = _voices.firstWhere(
                  (v) => v['name'] == newVal,
                  orElse: () => null);
              if (matchedVoice != null) {
                _selectedLocale = matchedVoice['locale'];
              }
            });
          },
          hint: Text('Select Voice',
              style: GoogleFonts.poppins(color: textColor)),
        ),
      ),
    );
  }

  Widget _buildSliders(Color textColor, Color shadowColor) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: shadowColor.withOpacity(0.5),
            blurRadius: 14.r,
            offset: Offset(0, 7.h),
          ),
        ],
      ),
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          Row(
            children: [
              Text('Speech Rate:',
                  style: GoogleFonts.poppins(color: textColor, fontSize: 16.sp)),
              SizedBox(width: 10.w),
              Expanded(
                child: Slider(
                  value: _speechRate,
                  min: 0.1,
                  max: 1.0,
                  divisions: 9,
                  label: _speechRate.toStringAsFixed(2),
                  activeColor: shadowColors[2],
                  inactiveColor: shadowColors[2].withOpacity(0.3),
                  onChanged: (value) {
                    setState(() {
                      _speechRate = value;
                    });
                  },
                ),
              ),
            ],
          ),
          Row(
            children: [
              Text('Pitch:', style: GoogleFonts.poppins(color: textColor, fontSize: 16.sp)),
              SizedBox(width: 10.w),
              Expanded(
                child: Slider(
                  value: _pitch,
                  min: 0.5,
                  max: 2.0,
                  divisions: 15,
                  label: _pitch.toStringAsFixed(2),
                  activeColor: shadowColors[2],
                  inactiveColor: shadowColors[2].withOpacity(0.3),
                  onChanged: (value) {
                    setState(() {
                      _pitch = value;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(Color textColor, Color shadowColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        ScaleTransition(
          scale: _pulseAnimation,
          child: InkWell(
            borderRadius: BorderRadius.circular(20.r),
            splashColor: shadowColor.withOpacity(0.3),
            onTapDown: (_) => _animationController!.reverse(),
            onTapUp: (_) {
              _animationController!.forward();
              _listen();
            },
            onTapCancel: () => _animationController!.forward(),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                color: _isListening ? shadowColors[3] : shadowColors[0],
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: shadowColor.withOpacity(0.6),
                    blurRadius: 16.r,
                    offset: Offset(0, 8.h),
                  ),
                ],
              ),
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _isListening ? Icons.mic_off : Icons.mic,
                    color: Colors.white,
                    size: 30.sp,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    _isListening ? 'Stop' : 'Listen',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        ScaleTransition(
          scale: _pulseAnimation,
          child: InkWell(
            borderRadius: BorderRadius.circular(20.r),
            splashColor: shadowColor.withOpacity(0.3),
            onTapDown: (_) => _animationController!.reverse(),
            onTapUp: (_) {
              _animationController!.forward();
              _speak();
            },
            onTapCancel: () => _animationController!.forward(),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                color: shadowColors[1],
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: shadowColor.withOpacity(0.6),
                    blurRadius: 16.r,
                    offset: Offset(0, 8.h),
                  ),
                ],
              ),
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.volume_up,
                    color: Colors.white,
                    size: 30.sp,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Speak',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildClearCopyButtons(Color textColor, Color shadowColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ScaleTransition(
          scale: _pulseAnimation,
          child: InkWell(
            borderRadius: BorderRadius.circular(20.r),
            splashColor: shadowColor.withOpacity(0.3),
            onTapDown: (_) => _animationController!.reverse(),
            onTapUp: (_) {
              _animationController!.forward();
              setState(() {
                _textController.clear();
              });
            },
            onTapCancel: () => _animationController!.forward(),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                color: shadowColors[3],
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: shadowColor.withOpacity(0.6),
                    blurRadius: 16.r,
                    offset: Offset(0, 8.h),
                  ),
                ],
              ),
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.clear,
                    color: Colors.white,
                    size: 24.sp,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Clear',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        ScaleTransition(
          scale: _pulseAnimation,
          child: InkWell(
            borderRadius: BorderRadius.circular(20.r),
            splashColor: shadowColor.withOpacity(0.3),
            onTapDown: (_) => _animationController!.reverse(),
            onTapUp: (_) {
              _animationController!.forward();
              Clipboard.setData(ClipboardData(text: _textController.text));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Copied to clipboard!',
                      style: GoogleFonts.poppins()),
                  backgroundColor: shadowColors[0],
                ),
              );
            },
            onTapCancel: () => _animationController!.forward(),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                color: shadowColors[1],
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: shadowColor.withOpacity(0.6),
                    blurRadius: 16.r,
                    offset: Offset(0, 8.h),
                  ),
                ],
              ),
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.copy,
                    color: Colors.white,
                    size: 24.sp,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Copy',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:startapp_sdk/startapp.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:flutter/services.dart'; // NEW UI ADDITION
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../services/startappad.dart';
import '../widgets/banner_ad_widget.dart';
import 'api.dart';

class DocumentSimplifierScreen extends StatefulWidget {
  const DocumentSimplifierScreen({Key? key}) : super(key: key);

  @override
  State<DocumentSimplifierScreen> createState() => _DocumentSimplifierScreenState();
}

class _DocumentSimplifierScreenState extends State<DocumentSimplifierScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  String _simplifiedText = '';
  bool _isLoading = false;
  String _selectedLanguage = 'English';
  final FlutterTts _flutterTts = FlutterTts();
  bool _isDarkMode = true; // NEW UI ADDITION

  final List<String> _languages = ['English', 'Spanish', 'French', 'German','Gujarati','Hindi'];
  final List<Color> shadowColors = [
    const Color(0xFF00E5FF),
    const Color(0xFF7C4DFF),
    const Color(0xFFFF9100),
    const Color(0xFFFF4081),
  ];
  var startAppAd = StartAppAdService();
  final StartAppSdk _sdk = StartAppSdk();
  @override
  void initState() {
    super.initState();
    // _sdk.setTestAdsEnabled(true);
    startAppAd.loadBannerAd();
    startAppAd.loadRewardedAd(onReward: (){
      print("Reward");
    }).timeout(Duration(seconds: 5),onTimeout: (){
      print("TIMEOUT CANT LOAD AD");
    });
    startAppAd.loadInterstitialAd().timeout(Duration(seconds: 5),onTimeout: (){
      print("TIMEOUT CANT LOAD AD");
    });
  }
  Future<void> _handleSimplification() async {
    final input = _textController.text.trim();
    if (input.isEmpty) return;

    setState(() {
      _isLoading = true;
      _simplifiedText = '';
    });

    try {
      final simplified = await ApiService.getSimplifiedDocument(input, language: _selectedLanguage);
      startAppAd.showRewardedAd();
      startAppAd.loadRewardedAd(onReward: (){
        print("Reward");
      }).timeout(Duration(seconds: 5),onTimeout: (){
        print("TIMEOUT CANT LOAD AD");
      });
      startAppAd.loadInterstitialAd().timeout(Duration(seconds: 5),onTimeout: (){
        print("TIMEOUT CANT LOAD AD");
      });
      setState(() {
        _simplifiedText = simplified;
      });

      final prefs = await SharedPreferences.getInstance();
      prefs.setString('last_simplified', simplified);
    } catch (e) {
      setState(() {
        _simplifiedText = 'Error: ${e.toString()}';
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['txt', 'pdf']);
    if (result != null && result.files.single.path != null) {
      final path = result.files.single.path!;
      final file = File(path);

      String content = '';
      if (path.endsWith('.pdf')) {
        final document = PdfDocument(inputBytes: await file.readAsBytes());
        content = PdfTextExtractor(document).extractText();
        document.dispose();
      } else {
        content = await file.readAsString();
      }

      setState(() {
        _textController.text = content;
      });
    }
  }

  Future<void> _exportText() async {
    if (_simplifiedText.isEmpty) return;

    final bytes = _simplifiedText.codeUnits;
    await FileSaver.instance.saveFile(name: '${DateTime.now()}');
  }

  void _clearAll() {
    setState(() {
      _textController.clear();
      _simplifiedText = '';
    });
  }

  Future<void> _speakResult() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.45);
    await _flutterTts.speak(_simplifiedText);
  }

  InputDecoration customInputDecoration(String label, Color focusColor) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.poppins(
        color: Colors.white70,
        fontWeight: FontWeight.w500,
        fontSize: 16.sp,
      ),
      filled: true,
      fillColor: const Color(0xFF1E1E1E),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20.r),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20.r),
        borderSide: BorderSide(color: focusColor, width: 2),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isDarkMode ? const Color(0xFF121212) : Colors.white,
      appBar: AppBar(
        iconTheme: IconThemeData(color: _isDarkMode ? Colors.white : Colors.black),
        title: ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [
              _isDarkMode ? Colors.white : Colors.black,
              _isDarkMode ? Colors.white70 : Colors.black87,
              shadowColors[1],
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: Text(
              "Document Simplifier",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                fontSize: 22.sp,
                color: _isDarkMode ? Colors.white : Colors.black,
                letterSpacing: 1,
              )
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, size: 24.sp),
            onPressed: _clearAll,
            tooltip: "Clear All",
          )
        ],
      ),
      body: Stack(
        children: [

          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      (_isDarkMode ? const Color(0xFF121212) : Colors.white).withOpacity(0.3),
                      (_isDarkMode ? const Color(0xFF121212) : Colors.white).withOpacity(0.5),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
              child: ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: startAppAd.getBannerWidget(),
                  ),
                  // Title with enhanced gradient
                  ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: [
                        _isDarkMode ? Colors.white : Colors.black,
                        _isDarkMode ? Colors.white70 : Colors.black87,
                        shadowColors[1],
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds),
                    child: Text(
                      "Simplify Your Documents 🧾",
                      style: GoogleFonts.poppins(
                        fontSize: 32.sp,
                        color: _isDarkMode ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        height: 1.2,
                      ),
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    "Paste text, choose language, or upload a document",
                    style: GoogleFonts.roboto(
                      fontSize: 16.sp,
                      color: _isDarkMode ? Colors.white70 : Colors.black54,
                      height: 1.4,
                      letterSpacing: 0.2,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  _buildLanguageSelector(),
                  SizedBox(height: 20.h),
                  _buildInputCard(),
                  SizedBox(height: 16.h),
                  _buildActionButton(
                    "Pick Document",
                    _pickFile,
                    shadowColors[1],
                    icon: Icons.upload_file,
                  ),
                  SizedBox(height: 14.h),
                  _buildActionButton(
                    "Simplify Text",
                    _handleSimplification,
                    shadowColors[2],
                    icon: Icons.auto_fix_high,
                  ),
                  if (_isLoading)
                    Padding(
                      padding: EdgeInsets.only(top: 20.h),
                      child: Center(
                        child: Column(
                          children: [
                            SizedBox(
                              width: 40.w,
                              height: 40.h,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(shadowColors[2]),
                                strokeWidth: 3,
                              ),
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              "Simplifying your document...",
                              style: GoogleFonts.poppins(
                                color: _isDarkMode ? Colors.white70 : Colors.black54,
                                fontSize: 14.sp,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  SizedBox(height: 20.h),
                  if (_simplifiedText.isNotEmpty) _buildResultCard(_simplifiedText),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: startAppAd.getBannerWidget(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageSelector() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: shadowColors[1].withOpacity(0.4),
            blurRadius: 12.r,
            offset: Offset(0, 6.h),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4.r,
            offset: Offset(0, 2.h),
          ),
        ],
        border: Border.all(
          color: shadowColors[1].withOpacity(0.1),
          width: 1,
        ),
      ),
      child: DropdownButtonFormField<String>(
        dropdownColor: const Color(0xFF1E1E1E),
        value: _selectedLanguage,
        items: _languages.map((lang) => DropdownMenuItem(
          value: lang,
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                margin: EdgeInsets.only(right: 12.w),
                decoration: BoxDecoration(
                  color: shadowColors[1].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(Icons.language, color: shadowColors[1], size: 20.sp),
              ),
              Text(
                lang,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 16.sp,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        )).toList(),
        onChanged: (value) => setState(() => _selectedLanguage = value!),
        decoration: InputDecoration(
          labelText: "Select Language",
          labelStyle: GoogleFonts.poppins(
            color: Colors.white70,
            fontWeight: FontWeight.w600,
            fontSize: 15.sp,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.r),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        ),
      ),
    );
  }

  Widget _buildInputCard() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: shadowColors[0].withOpacity(0.4),
            blurRadius: 12.r,
            offset: Offset(0, 6.h),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4.r,
            offset: Offset(0, 2.h),
          ),
        ],
        border: Border.all(
          color: shadowColors[0].withOpacity(0.1),
          width: 1,
        ),
      ),
      child: TextField(
        controller: _textController,
        maxLines: 8,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 16.sp,
          letterSpacing: 0.3,
        ),
        decoration: InputDecoration(
          labelText: "Paste or upload document text",
          labelStyle: GoogleFonts.poppins(
            color: Colors.white70,
            fontWeight: FontWeight.w600,
            fontSize: 15.sp,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              padding: EdgeInsets.all(12.w),
              margin: EdgeInsets.only(right: 8.w),
              decoration: BoxDecoration(
                color: shadowColors[0].withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(Icons.description, color: shadowColors[0], size: 20.sp),
            ),
          ),
          filled: true,
          fillColor: const Color(0xFF1E1E1E),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.r),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.r),
            borderSide: BorderSide(color: shadowColors[0], width: 2.5),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, VoidCallback onTap, Color shadowColor, {required IconData icon}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [shadowColor, shadowColor.withOpacity(0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: shadowColor.withOpacity(0.4),
              blurRadius: 12.r,
              offset: Offset(0, 6.h),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4.r,
              offset: Offset(0, 2.h),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(vertical: 16.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20.sp),
            SizedBox(width: 8.w),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 16.sp,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(String result) {
    // Split text by ** markers
    List<String> parts = result.split('**');
    List<TextSpan> textSpans = [];

    for (int i = 0; i < parts.length; i++) {
      if (i % 2 == 0) {
        // Regular text
        textSpans.add(TextSpan(
          text: parts[i],
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 16.sp,
            height: 1.5,
            letterSpacing: 0.3,
          ),
        ));
      } else {
        // Bold text
        textSpans.add(TextSpan(
          text: parts[i],
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 16.sp,
            height: 1.5,
            letterSpacing: 0.3,
            fontWeight: FontWeight.bold,
          ),
        ));
      }
    }

    return Padding(
      padding: EdgeInsets.all(8.w),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: shadowColors[3].withOpacity(0.4),
              blurRadius: 12.r,
              offset: Offset(0, 6.h),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4.r,
              offset: Offset(0, 2.h),
            ),
          ],
          border: Border.all(
            color: shadowColors[3].withOpacity(0.1),
            width: 1,
          ),
        ),
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: shadowColors[3].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(Icons.auto_fix_high, color: shadowColors[3], size: 20.sp),
                ),
                SizedBox(width: 12.w),
                Text(
                  "Simplified Text",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            SelectableText.rich(
              TextSpan(children: textSpans),
            ),
            SizedBox(height: 20.h),
            Row(
              children: [
                _buildMiniButton(Icons.volume_up, _speakResult, shadowColors[0]),
                SizedBox(width: 12.w),
                _buildMiniButton(Icons.download, _exportText, shadowColors[1]),
                SizedBox(width: 12.w),
                _buildMiniButton(Icons.copy, () {
                  Clipboard.setData(ClipboardData(text: result));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Text copied to clipboard")),
                  );
                }, shadowColors[2]),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniButton(IconData icon, VoidCallback onTap, Color color) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withOpacity(0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8.r,
              offset: Offset(0, 4.h),
            ),
          ],
        ),
        padding: EdgeInsets.all(10.w),
        child: Icon(icon, color: Colors.white, size: 24.sp),
      ),
    );
  }
}

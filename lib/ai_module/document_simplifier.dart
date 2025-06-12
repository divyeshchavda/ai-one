import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:flutter/services.dart'; // NEW UI ADDITION
import 'package:flutter_screenutil/flutter_screenutil.dart';
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

  final List<String> _languages = ['English', 'Spanish', 'French', 'German'];
  final List<Color> shadowColors = [
    const Color(0xFF00E5FF),
    const Color(0xFF7C4DFF),
    const Color(0xFFFF9100),
    const Color(0xFFFF4081),
  ];

  Future<void> _handleSimplification() async {
    final input = _textController.text.trim();
    if (input.isEmpty) return;

    setState(() {
      _isLoading = true;
      _simplifiedText = '';
    });

    try {
      final simplified = await ApiService.getSimplifiedDocument(input, language: _selectedLanguage);
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
        title: Text(
          "Document Simplifier",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 20.sp,
            color: _isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
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
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 500),
                opacity: 0.05,
                child: Image.asset(
                  'assets/particles_bg.png',
                  fit: BoxFit.cover,
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
                    child: const BannerAdWidget(),
                  ),
                  Text(
                    "Simplify Your Documents 🧾",
                    style: GoogleFonts.poppins(
                      fontSize: 28.sp,
                      color: _isDarkMode ? Colors.white : Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    "Paste text, choose language, or upload a document",
                    style: GoogleFonts.roboto(
                      fontSize: 16.sp,
                      color: _isDarkMode ? Colors.white70 : Colors.black54,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  DropdownButtonFormField<String>(
                    dropdownColor: const Color(0xFF1E1E1E),
                    value: _selectedLanguage,
                    items: _languages.map((lang) => DropdownMenuItem(
                      value: lang,
                      child: Text(
                        lang,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 16.sp,
                        ),
                      ),
                    )).toList(),
                    onChanged: (value) => setState(() => _selectedLanguage = value!),
                    decoration: customInputDecoration("Select Language", shadowColors[1]),
                  ),
                  SizedBox(height: 20.h),
                  _buildInputCard(),
                  SizedBox(height: 16.h),
                  _buildActionButton("Pick Document", _pickFile, shadowColors[1]),
                  SizedBox(height: 14.h),
                  _buildActionButton("Simplify Text", _handleSimplification, shadowColors[2]),
                  if (_isLoading)
                    Padding(
                      padding: EdgeInsets.only(top: 20.h),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  SizedBox(height: 20.h),
                  if (_simplifiedText.isNotEmpty) _buildResultCard(_simplifiedText),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: const BannerAdWidget(),
                  ),
                ],
              ),
            ),
          ),
        ],
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
        ],
      ),
      child: TextField(
        controller: _textController,
        maxLines: 8,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 16.sp,
        ),
        decoration: customInputDecoration("Paste or upload document text", shadowColors[0]),
      ),
    );
  }

  Widget _buildActionButton(String label, VoidCallback onTap, Color shadowColor) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: shadowColor,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: shadowColor.withOpacity(0.4),
              blurRadius: 12.r,
              offset: Offset(0, 6.h),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(vertical: 16.h),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 16.sp,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultCard(String result) {
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
          ],
        ),
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SelectableText(
              result,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 16.sp,
                height: 1.5,
              ),
            ),
            SizedBox(height: 20.h),
            Row(
              children: [
                _buildMiniButton(Icons.volume_up, _speakResult),
                SizedBox(width: 12.w),
                _buildMiniButton(Icons.download, _exportText),
                SizedBox(width: 12.w),
                _buildMiniButton(Icons.copy, () {
                  Clipboard.setData(ClipboardData(text: result));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Text copied to clipboard")),
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF292929),
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 6.r,
            ),
          ],
        ),
        padding: EdgeInsets.all(10.w),
        child: Icon(icon, color: Colors.white, size: 24.sp),
      ),
    );
  }
}

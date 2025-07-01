import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:startapp_sdk/startapp.dart';
import '../services/startappad.dart';
import 'api.dart';

class SymptomCheckerScreen extends StatefulWidget {
  const SymptomCheckerScreen({super.key});

  @override
  State<SymptomCheckerScreen> createState() => _SymptomCheckerScreenState();
}

class _SymptomCheckerScreenState extends State<SymptomCheckerScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController symptomsController = TextEditingController();
  bool isLoading = false;
  String result = '';

  final List<Color> shadowColors = [
    const Color(0xFF00E5FF), // Input Card
    const Color(0xFFFF4081), // Button
    const Color(0xFF7C4DFF), // Result
  ];

  final List<String> commonSymptoms = [
    "Headache",
    "Fever",
    "Cough",
    "Nausea",
    "Fatigue",
    "Chest pain",
    "Shortness of breath",
    "Dizziness",
    "Sore throat",
    "Body aches"
  ];
  List<String> selectedSymptoms = [];

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
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
    _loadLastResult();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    symptomsController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadLastResult() async {
    final prefs = await SharedPreferences.getInstance();
    final savedResult = prefs.getString('last_symptom_result') ?? '';
    if (savedResult.isNotEmpty) {
      setState(() {
        result = savedResult;
      });
    }
  }

  Future<void> _saveResult(String text) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_symptom_result', text);
  }

  void analyzeSymptoms() async {
    final combinedInput = [
      ...selectedSymptoms,
      symptomsController.text.trim()
    ].where((element) => element.isNotEmpty).join(', ');

    if (combinedInput.isEmpty) {
      setState(() => result = 'Please select or enter at least one symptom.');
      return;
    }

    setState(() {
      isLoading = true;
      result = '';
    });
    _fadeController.reverse();

    try {
      final response = await ApiService.getMedicalAdvice(combinedInput);
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
        if (response.trim().isEmpty) {
          result =
          'Sorry, no advice could be retrieved. Please try again later.';
        } else {
          result = response;
          _saveResult(response);
        }
        isLoading = false;
        selectedSymptoms.clear();
        symptomsController.clear();
      });

      _fadeController.forward();
    } catch (e) {
      setState(() {
        result = 'Error occurred while fetching advice. Please try again.';
        isLoading = false;
      });
      _fadeController.forward();
    }
  }

  void clearAll() {
    setState(() {
      symptomsController.clear();
      selectedSymptoms.clear();
      result = '';
    });
    _saveResult('');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Input and results cleared.')),
    );
  }

  void copyResultToClipboard() {
    if (result.isEmpty) return;
    Clipboard.setData(ClipboardData(text: result));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Result copied to clipboard!')),
    );
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
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [
              Colors.white,
              Colors.white70,
              shadowColors[1],
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: Text(
            "Medical Symptom Checker",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700,
              fontSize: 22.sp,
              color: Colors.white,
              letterSpacing: 1,
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: clearAll,
            icon: Icon(Icons.clear_all, size: 24.sp),
            tooltip: 'Clear all',
          ),
          IconButton(
            onPressed: copyResultToClipboard,
            icon: Icon(Icons.copy, size: 24.sp),
            tooltip: 'Copy result',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Animated background with particles
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
          // Gradient overlay
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      const Color(0xFF121212).withOpacity(0.3),
                      const Color(0xFF121212).withOpacity(0.5),
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
                        Colors.white,
                        Colors.white70,
                        shadowColors[1],
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds),
                    child: Text(
                      "Check Your Symptoms 🩺",
                      style: GoogleFonts.poppins(
                        fontSize: 32.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        height: 1.2,
                      ),
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    "Describe what you're feeling to get possible causes and advice",
                    style: GoogleFonts.roboto(
                      fontSize: 16.sp,
                      color: Colors.white70,
                      height: 1.4,
                      letterSpacing: 0.2,
                    ),
                  ),
                  SizedBox(height: 30.h),
                  _buildSectionTitle("Select common symptoms:"),
                  SizedBox(height: 12.h),
                  _buildSymptomChips(),
                  SizedBox(height: 24.h),
                  _buildInputCard(
                    label: 'Or type your symptoms (e.g., headache, fever)',
                    controller: symptomsController,
                    shadowColor: shadowColors[0],
                    focusColor: shadowColors[0],
                  ),
                  SizedBox(height: 18.h),
                  _buildAnalyzeButton(shadowColors[1]),
                  SizedBox(height: 30.h),
                  if (isLoading)
                    Center(
                      child: Column(
                        children: [
                          SizedBox(
                            width: 40.w,
                            height: 40.h,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(shadowColors[1]),
                              strokeWidth: 3,
                            ),
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            "Analyzing your symptoms...",
                            style: GoogleFonts.poppins(
                              color: Colors.white70,
                              fontSize: 14.sp,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (result.isNotEmpty)
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildResultCard(result, shadowColors[2]),
                    ),
                  SizedBox(height: 24.h),
                  _buildDisclaimer(),
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

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: shadowColors[1].withOpacity(0.1),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(Icons.medical_services, color: shadowColors[1], size: 20.sp),
        ),
        SizedBox(width: 12.w),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white70,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildSymptomChips() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20.h),
      child: Wrap(
        spacing: 8.w,
        runSpacing: 8.h,
        children: commonSymptoms.map((symptom) {
          final isSelected = selectedSymptoms.contains(symptom);
          return ChoiceChip(
            label: Text(
              symptom,
              style: GoogleFonts.poppins(
                color: isSelected ? Colors.white : Colors.white70,
                fontSize: 14.sp,
                letterSpacing: 0.3,
              ),
            ),
            selected: isSelected,
            selectedColor: shadowColors[1],
            backgroundColor: const Color(0xFF2A2A2A),
            onSelected: (selected) {
              setState(() {
                if (selected) {
                  selectedSymptoms.add(symptom);
                } else {
                  selectedSymptoms.remove(symptom);
                }
              });
            },
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.r),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildInputCard({
    required String label,
    required TextEditingController controller,
    required Color shadowColor,
    required Color focusColor,
  }) {
    return Padding(
      padding: EdgeInsets.all(8.w),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
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
          border: Border.all(
            color: shadowColor.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: TextField(
          controller: controller,
          maxLines: 4,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 16.sp,
            letterSpacing: 0.3,
          ),
          decoration: InputDecoration(
            labelText: label,
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
                  color: shadowColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(Icons.medical_information, color: shadowColor, size: 20.sp),
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
              borderSide: BorderSide(color: focusColor, width: 2.5),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          ),
        ),
      ),
    );
  }

  Widget _buildAnalyzeButton(Color shadowColor) {
    return GestureDetector(
      onTap: isLoading ? null : analyzeSymptoms,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              isLoading ? shadowColor.withOpacity(0.5) : shadowColor,
              isLoading ? shadowColor.withOpacity(0.3) : shadowColor.withOpacity(0.8),
            ],
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
        child: Center(
          child: isLoading
              ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 20.w,
                height: 20.h,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                'Analyzing...',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 16.sp,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          )
              : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.medical_services, color: Colors.white, size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                'Analyze Symptoms',
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
      ),
    );
  }

  Widget _buildResultCard(String result, Color shadowColor) {
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

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
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
        border: Border.all(
          color: shadowColor.withOpacity(0.1),
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
                  color: shadowColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(Icons.medical_information, color: shadowColor, size: 20.sp),
              ),
              SizedBox(width: 12.w),
              Text(
                "Analysis Results",
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
          SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Text.rich(
              TextSpan(children: textSpans),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisclaimer() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: Colors.red.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.red, size: 24.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              "⚠️ This tool provides informational guidance only and does not replace professional medical advice. Please consult a healthcare professional for diagnosis and treatment.",
              style: GoogleFonts.roboto(
                color: Colors.white70,
                fontSize: 12.sp,
                fontStyle: FontStyle.italic,
                height: 1.4,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets/banner_ad_widget.dart';
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

  @override
  void initState() {
    super.initState();
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
              ),
            ),
            selected: isSelected,
            selectedColor: Colors.redAccent,
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
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          "Medical Symptom Checker",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 20.sp,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
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
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
          child: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: const BannerAdWidget(),
              ),
              Text(
                "Check Your Symptoms 🩺",
                style: GoogleFonts.poppins(
                  fontSize: 28.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                "Describe what you're feeling to get possible causes and advice",
                style: GoogleFonts.roboto(
                  fontSize: 16.sp,
                  color: Colors.white70,
                ),
              ),
              SizedBox(height: 30.h),
              Text(
                "Select common symptoms:",
                style: GoogleFonts.poppins(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.white70,
                ),
              ),
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
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: CircularProgressIndicator(color: shadowColors[1]),
                  ),
                )
              else if (result.isNotEmpty)
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: _buildResultCard(result, shadowColors[2]),
                ),
              SizedBox(height: 24.h),
              Text(
                "⚠️ This tool provides informational guidance only and does not replace professional medical advice. Please consult a healthcare professional for diagnosis and treatment.",
                style: GoogleFonts.roboto(
                  color: Colors.white54,
                  fontSize: 12.sp,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
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
          ],
        ),
        child: TextField(
          controller: controller,
          maxLines: 4,
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 16.sp),
          decoration: customInputDecoration(label, focusColor),
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
          color: isLoading ? shadowColor.withOpacity(0.5) : shadowColor,
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
            'Analyze Symptoms',
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

  Widget _buildResultCard(String result, Color shadowColor) {
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
        ],
      ),
      padding: EdgeInsets.all(16.w),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Text(
          result,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 16.sp,
            height: 1.5,
          ),
        ),
      ),
    );
  }
}

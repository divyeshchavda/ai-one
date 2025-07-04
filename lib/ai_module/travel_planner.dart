import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:startapp_sdk/startapp.dart';
import '../services/startappad.dart';
import '../widgets/banner_ad_widget.dart';
import 'api.dart';

class TravelPlannerScreen extends StatefulWidget {
  const TravelPlannerScreen({super.key});

  @override
  State<TravelPlannerScreen> createState() => _TravelPlannerScreenState();
}

class _TravelPlannerScreenState extends State<TravelPlannerScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController destinationController = TextEditingController();
  final TextEditingController hisplaceController = TextEditingController();
  final TextEditingController budgetController = TextEditingController();
  final TextEditingController daysController = TextEditingController();
  final TextEditingController personsController = TextEditingController();

  DateTime? selectedDate;
  String result = '';
  bool isLoading = false;

  late AnimationController _btnAnimationController;
  late Animation<double> _btnScaleAnimation;

  final ApiService apiService = ApiService();

  // Colors matching your HomePage tool card colors
  final List<Color> shadowColors = [
    const Color(0xFF00E5FF), // Cyan
    const Color(0xFF7C4DFF), // Purple
    const Color(0xFFFF9100), // Orange
    const Color(0xFFFF4081), // Pink
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
    _btnAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      lowerBound: 0.95,
      upperBound: 1.0,
    );
    _btnScaleAnimation =
        CurvedAnimation(parent: _btnAnimationController, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    destinationController.dispose();
    hisplaceController.dispose();
    budgetController.dispose();
    daysController.dispose();
    personsController.dispose();
    _btnAnimationController.dispose();
    super.dispose();
  }

  Future<void> pickDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFFF4081),
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: const Color(0xFF1E1E1E),
            textTheme: GoogleFonts.poppinsTextTheme(),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void generateTravelPlan() async {
    final destination = destinationController.text.trim();
    final hisplace = hisplaceController.text.trim();
    final budget = budgetController.text.trim();
    final days = daysController.text.trim();
    final persons = personsController.text.trim();
    final date = selectedDate != null
        ? DateFormat('yyyy-MM-dd').format(selectedDate!)
        : '';

    if (destination.isEmpty ||
        hisplace.isEmpty ||
        budget.isEmpty ||
        days.isEmpty ||
        persons.isEmpty ||
        date.isEmpty) {
      setState(() {
        result = 'Please fill in all the fields and select a date.';
      });
      return;
    }

    setState(() {
      isLoading = true;
      result = '';
    });

    final plan =
    await apiService.getTravelPlan(destination, hisplace, budget, days, date, persons);
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
      result = plan;
      isLoading = false;
    });
  }

  InputDecoration customInputDecoration(String label, Color focusColor) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.poppins(
        color: Colors.white70,
        fontWeight: FontWeight.w600,
        fontSize: 15.sp,
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
      isDense: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = selectedDate != null
        ? DateFormat('dd MMM yyyy').format(selectedDate!)
        : 'Select Start Date';

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [Colors.white, Colors.white70, shadowColors[0]],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: Text(
              "Travel Planner",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                fontSize: 22.sp,
                color: Colors.white,
                letterSpacing: 1,
              )
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Animated background with particles
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedOpacity(
                duration: Duration(milliseconds: 500),
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
              padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 20.h),
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: startAppAd.getBannerWidget(),
                  ),
                  // Title with enhanced gradient
                  ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: [Colors.white, Colors.white70, shadowColors[0]],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds),
                    child: Text(
                      "Plan Your Trip 🌍",
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
                    "Enter details to create a personalized travel plan",
                    style: GoogleFonts.roboto(
                      fontSize: 16.sp,
                      color: Colors.white70,
                      height: 1.4,
                      letterSpacing: 0.2,
                    ),
                  ),
                  SizedBox(height: 28.h),
                  _buildInputCard(
                    label: 'Destination',
                    controller: destinationController,
                    shadowColor: shadowColors[0],
                    focusColor: shadowColors[0],
                  ),
                  SizedBox(height: 16.h),
                  _buildInputCard(
                    label: 'Your Location',
                    controller: hisplaceController,
                    shadowColor: shadowColors[1],
                    focusColor: shadowColors[1],
                  ),
                  SizedBox(height: 16.h),
                  _buildInputCard(
                    label: 'Budget (Rupees)',
                    controller: budgetController,
                    keyboardType: TextInputType.number,
                    shadowColor: shadowColors[2],
                    focusColor: shadowColors[2],
                  ),
                  SizedBox(height: 16.h),
                  _buildInputCard(
                    label: 'Number of Days',
                    controller: daysController,
                    keyboardType: TextInputType.number,
                    shadowColor: shadowColors[3],
                    focusColor: shadowColors[3],
                  ),
                  SizedBox(height: 16.h),
                  _buildInputCard(
                    label: 'Number of Persons',
                    controller: personsController,
                    keyboardType: TextInputType.number,
                    shadowColor: shadowColors[0],
                    focusColor: shadowColors[0],
                  ),
                  SizedBox(height: 16.h),
                  _buildDatePickerButton(formattedDate, shadowColors[1]),
                  SizedBox(height: 22.h),
                  ScaleTransition(
                    scale: _btnScaleAnimation,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20.r),
                      splashColor: shadowColors[2].withOpacity(0.3),
                      onTapDown: (_) => _btnAnimationController.reverse(),
                      onTapUp: (_) {
                        _btnAnimationController.forward();
                        generateTravelPlan();
                      },
                      onTapCancel: () => _btnAnimationController.forward(),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [shadowColors[2], shadowColors[2].withOpacity(0.8)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20.r),
                          boxShadow: [
                            BoxShadow(
                              color: shadowColors[2].withOpacity(0.6),
                              blurRadius: 16.r,
                              offset: Offset(0, 8.h),
                            ),
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4.r,
                              offset: Offset(0, 2.h),
                            ),
                          ],
                        ),
                        padding: EdgeInsets.symmetric(vertical: 18.h),
                        alignment: Alignment.center,
                        child: Text(
                          'Generate Travel Plan',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w700,
                            fontSize: 17.sp,
                            color: Colors.white,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 28.h),
                  if (isLoading)
                    Center(
                      child: Column(
                        children: [
                          SizedBox(
                            width: 40.w,
                            height: 40.h,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(shadowColors[3]),
                              strokeWidth: 3,
                            ),
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            "Creating your travel plan...",
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
                    AnimatedOpacity(
                      opacity: result.isNotEmpty ? 1 : 0,
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeInOut,
                      child: _buildResultCard(result, shadowColors[0]),
                    ),
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

  Widget _buildInputCard({
    required String label,
    required TextEditingController controller,
    required Color shadowColor,
    required Color focusColor,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: AnimatedContainer(
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
          keyboardType: keyboardType,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 16.sp,
            letterSpacing: 0.4,
          ),
          decoration: customInputDecoration(label, focusColor),
        ),
      ),
    );
  }

  Widget _buildDatePickerButton(String formattedDate, Color shadowColor) {
    return InkWell(
      borderRadius: BorderRadius.circular(20.r),
      splashColor: shadowColor.withOpacity(0.3),
      onTap: () => pickDate(context),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 22.w),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: shadowColor.withOpacity(0.5),
              blurRadius: 14.r,
              offset: Offset(0, 7.h),
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              formattedDate,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16.sp,
                letterSpacing: 0.3,
              ),
            ),
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: shadowColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(Icons.calendar_today, color: shadowColor, size: 24.sp),
            ),
          ],
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
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: shadowColor.withOpacity(0.55),
            blurRadius: 18.r,
            offset: Offset(0, 8.h),
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
      padding: EdgeInsets.all(18.w),
      child: RichText(
        text: TextSpan(children: textSpans),
      ),
    );
  }
}

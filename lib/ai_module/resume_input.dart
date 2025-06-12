import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ResumeInputScreen extends StatefulWidget {
  final Function(Map<String, dynamic>) onContinue;

  const ResumeInputScreen({super.key, required this.onContinue});

  @override
  State<ResumeInputScreen> createState() => _ResumeInputScreenState();
}

class _ResumeInputScreenState extends State<ResumeInputScreen>
    with SingleTickerProviderStateMixin {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final objectiveController = TextEditingController();
  final skillsController = TextEditingController();
  final certificationsController = TextEditingController();
  final languagesController = TextEditingController();

  List<Map<String, TextEditingController>> educationList = [];
  List<Map<String, TextEditingController>> experienceList = [];

  AnimationController? _btnAnimationController;
  Animation<double>? _btnScaleAnimation;

  final List<Color> shadowColors = [
    const Color(0xFF00E5FF), // Cyan
    const Color(0xFF7C4DFF), // Purple
    const Color(0xFFFF9100), // Orange
    const Color(0xFFFF4081), // Pink
  ];

  @override
  void initState() {
    super.initState();
    addEducation();
    addExperience();
    _btnAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      lowerBound: 0.95,
      upperBound: 1.0,
    );
    _btnScaleAnimation = CurvedAnimation(
      parent: _btnAnimationController!,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    objectiveController.dispose();
    skillsController.dispose();
    certificationsController.dispose();
    languagesController.dispose();
    for (var edu in educationList) {
      edu['degree']?.dispose();
      edu['institution']?.dispose();
      edu['year']?.dispose();
    }
    for (var exp in experienceList) {
      exp['role']?.dispose();
      exp['company']?.dispose();
      exp['duration']?.dispose();
      exp['description']?.dispose();
    }
    _btnAnimationController?.dispose();
    super.dispose();
  }

  void addEducation() {
    setState(() {
      educationList.add({
        'degree': TextEditingController(),
        'institution': TextEditingController(),
        'year': TextEditingController(),
      });
    });
  }

  void addExperience() {
    setState(() {
      experienceList.add({
        'role': TextEditingController(),
        'company': TextEditingController(),
        'duration': TextEditingController(),
        'description': TextEditingController(),
      });
    });
  }

  void fillDummyData() {
    setState(() {
      // Clear existing data
      nameController.text = 'John Doe';
      emailController.text = 'john.doe@example.com';
      phoneController.text = '+1 123-456-7890';
      addressController.text = '123 Main St, Springfield, USA';
      objectiveController.text =
          'To leverage my skills in software development to contribute to innovative projects.';
      skillsController.text = 'Flutter, Dart, Python, JavaScript, Git';
      certificationsController.text =
          'Google Flutter Certification, AWS Certified Developer';
      languagesController.text = 'English, Spanish';

      // Clear existing education and experience
      for (var edu in educationList) {
        edu['degree']?.dispose();
        edu['institution']?.dispose();
        edu['year']?.dispose();
      }
      for (var exp in experienceList) {
        exp['role']?.dispose();
        exp['company']?.dispose();
        exp['duration']?.dispose();
        exp['description']?.dispose();
      }
      educationList.clear();
      experienceList.clear();

      // Add dummy education
      educationList.add({
        'degree': TextEditingController(text: 'B.Sc. Computer Science'),
        'institution': TextEditingController(text: 'University of Springfield'),
        'year': TextEditingController(text: '2018-2022'),
      });
      educationList.add({
        'degree': TextEditingController(text: 'M.Sc. Software Engineering'),
        'institution': TextEditingController(text: 'Tech Institute'),
        'year': TextEditingController(text: '2022-2024'),
      });

      // Add dummy experience
      experienceList.add({
        'role': TextEditingController(text: 'Flutter Developer'),
        'company': TextEditingController(text: 'Tech Solutions Inc.'),
        'duration': TextEditingController(text: '2022-Present'),
        'description': TextEditingController(
          text: 'Developed cross-platform mobile apps using Flutter and Dart.',
        ),
      });
      experienceList.add({
        'role': TextEditingController(text: 'Intern'),
        'company': TextEditingController(text: 'Innovate Tech'),
        'duration': TextEditingController(text: '2021-2022'),
        'description': TextEditingController(
          text: 'Assisted in web development projects using JavaScript.',
        ),
      });
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

  Widget buildInputCard({
    required String label,
    required TextEditingController controller,
    required Color shadowColor,
    required Color focusColor,
    int maxLines = 1,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 8.h),
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
          ],
        ),
        child: TextField(
          controller: controller,
          maxLines: maxLines,
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

  Widget buildCard(String title, List<Widget> children, Color shadowColor) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 22.w),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
        margin: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: shadowColor.withOpacity(0.55),
              blurRadius: 18.r,
              offset: Offset(0, 8.h),
            ),
          ],
        ),
        padding: EdgeInsets.all(18.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 12.h),
            ...children,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scaleAnimation = _btnScaleAnimation ?? AlwaysStoppedAnimation(1.0);

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Resume Builder',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 22.sp,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 20.h),
          child: ListView(
            physics: const BouncingScrollPhysics(),
            children: [
              Text(
                "Build Your Resume 📝",
                style: GoogleFonts.poppins(
                  fontSize: 30.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                "Enter your details to create a professional resume",
                style: GoogleFonts.roboto(
                  fontSize: 16.sp,
                  color: Colors.white70,
                  height: 1.3,
                ),
              ),
              SizedBox(height: 28.h),
              buildCard("Personal Info", [
                buildInputCard(
                  label: "Full Name",
                  controller: nameController,
                  shadowColor: shadowColors[0],
                  focusColor: shadowColors[0],
                ),
                buildInputCard(
                  label: "Email",
                  controller: emailController,
                  shadowColor: shadowColors[1],
                  focusColor: shadowColors[1],
                ),
                buildInputCard(
                  label: "Phone",
                  controller: phoneController,
                  shadowColor: shadowColors[2],
                  focusColor: shadowColors[2],
                ),
                buildInputCard(
                  label: "Address",
                  controller: addressController,
                  shadowColor: shadowColors[3],
                  focusColor: shadowColors[3],
                ),
              ], shadowColors[0]),
              buildCard("Objective / Summary", [
                buildInputCard(
                  label: "Write a short summary or objective",
                  controller: objectiveController,
                  shadowColor: shadowColors[1],
                  focusColor: shadowColors[1],
                  maxLines: 4,
                ),
              ], shadowColors[1]),
              buildCard("Education", [
                ...educationList.asMap().entries.map((entry) {
                  final index = entry.key;
                  final edu = entry.value;
                  return Column(
                    children: [
                      buildInputCard(
                        label: "Degree",
                        controller: edu['degree']!,
                        shadowColor: shadowColors[index % shadowColors.length],
                        focusColor: shadowColors[index % shadowColors.length],
                      ),
                      buildInputCard(
                        label: "Institution",
                        controller: edu['institution']!,
                        shadowColor:
                            shadowColors[(index + 1) % shadowColors.length],
                        focusColor:
                            shadowColors[(index + 1) % shadowColors.length],
                      ),
                      buildInputCard(
                        label: "Year",
                        controller: edu['year']!,
                        shadowColor:
                            shadowColors[(index + 2) % shadowColors.length],
                        focusColor:
                            shadowColors[(index + 2) % shadowColors.length],
                      ),
                      const Divider(color: Colors.white24),
                    ],
                  );
                }),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: addEducation,
                    icon: Icon(Icons.add, color: shadowColors[2]),
                    label: Text(
                      "Add Education",
                      style: GoogleFonts.poppins(color: shadowColors[2]),
                    ),
                  ),
                ),
              ], shadowColors[2]),
              buildCard("Work Experience", [
                ...experienceList.asMap().entries.map((entry) {
                  final index = entry.key;
                  final exp = entry.value;
                  return Column(
                    children: [
                      buildInputCard(
                        label: "Role / Position",
                        controller: exp['role']!,
                        shadowColor: shadowColors[index % shadowColors.length],
                        focusColor: shadowColors[index % shadowColors.length],
                      ),
                      buildInputCard(
                        label: "Company",
                        controller: exp['company']!,
                        shadowColor:
                            shadowColors[(index + 1) % shadowColors.length],
                        focusColor:
                            shadowColors[(index + 1) % shadowColors.length],
                      ),
                      buildInputCard(
                        label: "Duration",
                        controller: exp['duration']!,
                        shadowColor:
                            shadowColors[(index + 2) % shadowColors.length],
                        focusColor:
                            shadowColors[(index + 2) % shadowColors.length],
                      ),
                      buildInputCard(
                        label: "Description",
                        controller: exp['description']!,
                        shadowColor:
                            shadowColors[(index + 3) % shadowColors.length],
                        focusColor:
                            shadowColors[(index + 3) % shadowColors.length],
                        maxLines: 3,
                      ),
                      const Divider(color: Colors.white24),
                    ],
                  );
                }),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: addExperience,
                    icon: Icon(Icons.add, color: shadowColors[3]),
                    label: Text(
                      "Add Experience",
                      style: GoogleFonts.poppins(color: shadowColors[3]),
                    ),
                  ),
                ),
              ], shadowColors[3]),
              buildCard("Skills", [
                buildInputCard(
                  label: "Comma-separated skills",
                  controller: skillsController,
                  shadowColor: shadowColors[0],
                  focusColor: shadowColors[0],
                ),
              ], shadowColors[0]),
              buildCard("Certifications", [
                buildInputCard(
                  label: "List certifications (comma separated)",
                  controller: certificationsController,
                  shadowColor: shadowColors[1],
                  focusColor: shadowColors[1],
                ),
              ], shadowColors[1]),
              buildCard("Languages", [
                buildInputCard(
                  label: "Languages known (comma separated)",
                  controller: languagesController,
                  shadowColor: shadowColors[2],
                  focusColor: shadowColors[2],
                ),
              ], shadowColors[2]),
              SizedBox(height: 20.h),
              ScaleTransition(
                scale: scaleAnimation,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20.r),
                  splashColor: shadowColors[1].withOpacity(0.3),
                  onTapDown: (_) => _btnAnimationController?.reverse(),
                  onTapUp: (_) {
                    _btnAnimationController?.forward();
                    fillDummyData();
                  },
                  onTapCancel: () => _btnAnimationController?.forward(),
                  child: Container(
                    decoration: BoxDecoration(
                      color: shadowColors[1],
                      borderRadius: BorderRadius.circular(20.r),
                      boxShadow: [
                        BoxShadow(
                          color: shadowColors[1].withOpacity(0.6),
                          blurRadius: 16.r,
                          offset: Offset(0, 8.h),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.symmetric(vertical: 18.h),
                    alignment: Alignment.center,
                    child: Text(
                      'Fill Dummy Data',
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
              SizedBox(height: 20.h),
              ScaleTransition(
                scale: scaleAnimation,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20.r),
                  splashColor: shadowColors[2].withOpacity(0.3),
                  onTapDown: (_) => _btnAnimationController?.reverse(),
                  onTapUp: (_) {
                    _btnAnimationController?.forward();
                    final data = {
                      'fullName': nameController.text,
                      'email': emailController.text,
                      'phone': phoneController.text,
                      'address': addressController.text,
                      'objective': objectiveController.text,
                      'education':
                          educationList
                              .map(
                                (edu) => {
                                  'degree': edu['degree']!.text,
                                  'institution': edu['institution']!.text,
                                  'year': edu['year']!.text,
                                },
                              )
                              .toList(),
                      'experience':
                          experienceList
                              .map(
                                (exp) => {
                                  'role': exp['role']!.text,
                                  'company': exp['company']!.text,
                                  'duration': exp['duration']!.text,
                                  'description': exp['description']!.text,
                                },
                              )
                              .toList(),
                      'skills':
                          skillsController.text
                              .split(',')
                              .map((e) => e.trim())
                              .where((e) => e.isNotEmpty)
                              .toList(),
                      'certifications':
                          certificationsController.text
                              .split(',')
                              .map((e) => e.trim())
                              .where((e) => e.isNotEmpty)
                              .toList(),
                      'languages':
                          languagesController.text
                              .split(',')
                              .map((e) => e.trim())
                              .where((e) => e.isNotEmpty)
                              .toList(),
                    };
                    widget.onContinue(data);
                  },
                  onTapCancel: () => _btnAnimationController?.forward(),
                  child: Container(
                    decoration: BoxDecoration(
                      color: shadowColors[2],
                      borderRadius: BorderRadius.circular(20.r),
                      boxShadow: [
                        BoxShadow(
                          color: shadowColors[2].withOpacity(0.6),
                          blurRadius: 16.r,
                          offset: Offset(0, 8.h),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.symmetric(vertical: 18.h),
                    alignment: Alignment.center,
                    child: Text(
                      'Continue',
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
              SizedBox(height: 30.h),
            ],
          ),
        ),
      ),
    );
  }
}

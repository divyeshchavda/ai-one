import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


import '../ai_module/chat_assistant.dart';

import '../ai_module/document_simplifier.dart';
import '../ai_module/image_generator.dart';

import '../ai_module/medical_symtoms_checker.dart';
import '../ai_module/resume_input.dart';
import '../ai_module/speech_to_text.dart';
import '../ai_module/templateselectorscreen.dart';
import '../ai_module/travel_planner.dart';
import '../widgets/banner_ad_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String username = "";

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        username = prefs.getString("name") ?? "User";
      });
    });
    fetchUsername();
  }
  Future<void> fetchUsername() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email');

    if (email != null) {
      final snapshot = await FirebaseFirestore.instance
          .collection('details')
          .where('email', isEqualTo: email)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final fetchedName = snapshot.docs.first.data()['name'];
        final cachedName = prefs.getString("name");

        // Update only if the fetched name is different
        if (fetchedName != cachedName) {
          await prefs.setString("name", fetchedName);
          setState(() {
            username = fetchedName;
          });
        } else {
          // No change, just use the cached one
          setState(() {
            username = cachedName ?? "User";
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 30.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: const BannerAdWidget(),
              )),
              Text(
                "Hey $username 👋",
                style: GoogleFonts.poppins(
                  fontSize: 28.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                "What would you like to explore today?",
                style: GoogleFonts.roboto(
                  fontSize: 16.sp,
                  color: Colors.white70,
                ),
              ),
              SizedBox(height: 30.h),


              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 5.w,
                  mainAxisSpacing: 5.h,
                  children: [
                    _AnimatedToolCard(
                      icon: Icons.chat,
                      title: "Chat Assistant",
                      color: const Color(0xFF00E5FF),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => ChatAssistantScreen(),));
                      },
                    ),
                    _AnimatedToolCard(
                        icon: Icons.image,
                        title: "Image Generator",
                        color: const Color(0xFF00C853),
                        onTap: ()  {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => ImageGeneratorScreen(),));
                        }
                    ),

                    _AnimatedToolCard(
                      icon: Icons.flight_takeoff,
                      title: "Travel Planner",
                      color: Colors.pinkAccent,
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => TravelPlannerScreen(),));
                      },
                    ),
                    _AnimatedToolCard(
                      icon: Icons.description,
                      title: "Document Simplifier",
                      color:  Colors.deepPurple,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const DocumentSimplifierScreen(),
                          ),
                        );
                      },
                    ),
                    _AnimatedToolCard(
                      icon: Icons.mic,
                      title: "Voice-to-Text Helper",
                      color: Colors.teal,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const VoiceToTextHelperScreen(),
                          ),
                        );
                      },
                    ),
                    _AnimatedToolCard(
                      icon: Icons.local_hospital,
                      title: "Medical Symptom Checker",
                      color: Colors.red,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SymptomCheckerScreen(),
                          ),
                        );
                      },
                    ),
                    // _AnimatedToolCard(
                    //   icon: Icons.picture_as_pdf_rounded,
                    //   title: "Resume Builder",
                    //   color: Colors.white,
                    //   onTap: () {
                    //     Navigator.push(
                    //       context,
                    //       MaterialPageRoute(
                    //         builder: (context) => ResumeInputScreen(
                    //           onContinue: (resumeData) {
                    //             Navigator.push(
                    //               context,
                    //               MaterialPageRoute(
                    //                 builder: (context) => ResumeTemplateSelectorScreen(data: resumeData),
                    //               ),
                    //             );
                    //           },
                    //         ),
                    //       ),
                    //     );
                    //   },
                    // ),

                    // _AnimatedToolCard(
                    //   icon: Icons.share,
                    //   title: "Share",
                    //   color: Colors.limeAccent,
                    //   onTap: () {
                    //     Navigator.push(
                    //       context,
                    //       MaterialPageRoute(
                    //         builder: (context) => ShareAioneButton(),
                    //       ),
                    //     );
                    //   },
                    // ),

                  ],
                ),
              ),
              Center(child: const BannerAdWidget()),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimatedToolCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _AnimatedToolCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
    super.key,
  });

  @override
  State<_AnimatedToolCard> createState() => _AnimatedToolCardState();
}

class _AnimatedToolCardState extends State<_AnimatedToolCard> {
  double _scale = 1.0;
  double _shadowOpacity = 0.4;

  void _onTapDown(TapDownDetails _) => setState(() {
    _scale = 0.95;
    _shadowOpacity = 0.0;
  });

  void _onTapUp(TapUpDetails _) => setState(() {
    _scale = 1.0;
    _shadowOpacity = 0.4;
  });

  void _onTapCancel() => setState(() {
    _scale = 1.0;
    _shadowOpacity = 0.4;
  });

  void _showCustomToast(String message) {
    Get.showSnackbar(
      GetSnackBar(
        message: message,
        backgroundColor: const Color(0xFF333333),
        duration: const Duration(seconds: 2),
        snackPosition: SnackPosition.TOP,
        margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        borderRadius: 12.r,
        boxShadows: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 12.r,
            offset: Offset(0, 6.h),
          ),
        ],
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
        messageText: Text(
          message,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 16.sp,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.w),
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: (details) {
          _onTapUp(details);
          widget.onTap();
        },
        onTapCancel: _onTapCancel,

        child: TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 150),
          tween: Tween<double>(begin: 1.0, end: _scale),
          curve: Curves.easeOut,
          builder: (context, scale, child) {
            return Transform.scale(
              scale: scale,
              child: child,
            );
          },
          child: Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: widget.color.withOpacity(_shadowOpacity),
                  blurRadius: 12.r,
                  offset: Offset(0, 6.h),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(widget.icon, size: 34.sp, color: widget.color),
                Text(
                  widget.title,
                  style: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


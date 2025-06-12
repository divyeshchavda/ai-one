import 'package:ai_one/authentication/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _soundEnabled = true;
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Padding(
        padding: EdgeInsets.all(20.w),
        child: ListView(
          children: [
            Text(
              "Settings",
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 32.sp,
              ),
            ),
            SizedBox(height: 20.h),

            _buildSectionHeader("Account Settings"),
            _buildAnimatedTile(
              icon: Icons.lock_outline,
              title: "Change Password",
              color: const Color(0xFF7C4DFF),
              onTap: () async {
                final prefs = await SharedPreferences.getInstance();
                final emailreset = prefs.getString("email");
                await FirebaseAuth.instance.sendPasswordResetEmail(email: emailreset!);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.notifications_active, color: Colors.white),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "Password reset email sent!",
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    backgroundColor: Colors.deepPurpleAccent,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    duration: const Duration(seconds: 3),
                  ),
                );
              },
            ),
            _buildAnimatedTile(
              icon: Icons.privacy_tip_outlined,
              title: "Privacy Policy",
              color: const Color(0xFFFF9100),
              onTap: () {
                Uri url=Uri.parse("https://drive.google.com/file/d/1cI7_W3_CNXXbshrBnF9-bWhRgOTChn5V/view?usp=sharing");
                launchUrl(url);
              },
            ),

            SizedBox(height: 20.h),
            _buildSectionHeader("Notifications"),
            _buildSwitchTile(
              title: "Enable Notifications",
              value: _notificationsEnabled,
              onChanged: (val) => setState(() => _notificationsEnabled = val),
            ),

            SizedBox(height: 20.h),
            _buildSectionHeader("Sound Settings"),
            _buildSwitchTile(
              title: "Enable Sound Effects",
              value: _soundEnabled,
              onChanged: (val) => setState(() => _soundEnabled = val),
            ),

            SizedBox(height: 40.h),
            _buildAnimatedTile(
              icon: Icons.logout,
              title: "Logout",
              color: const Color(0xFFFF4081),
              onTap: () async {
                final SharedPreferences prefs = await SharedPreferences.getInstance();
                var method = prefs.get("method");

                if (method == "email") {
                  await FirebaseAuth.instance.signOut();
                  await prefs.clear();
                }

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 18.sp,
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(
        title,
        style: GoogleFonts.roboto(
          color: Colors.white,
          fontSize: 16.sp,
        ),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: const Color(0xFF39FF14),
      activeTrackColor: const Color(0xFF2E2E2E),
      inactiveThumbColor: Colors.grey,
    );
  }

  Widget _buildAnimatedTile({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return _AnimatedToolCard(
      icon: icon,
      title: title,
      color: color,
      onTap: onTap,
    );
  }
}

class _AnimatedToolCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _AnimatedToolCard({
    Key? key,
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  }) : super(key: key);

  @override
  State<_AnimatedToolCard> createState() => _AnimatedToolCardState();
}

class _AnimatedToolCardState extends State<_AnimatedToolCard> {
  double _scale = 1.0;
  double _shadowOpacity = 0.4;

  void _onTapDown(_) => setState(() {
    _scale = 0.95;
    _shadowOpacity = 0.0;
  });

  void _onTapUp(_) => setState(() {
    _scale = 1.0;
    _shadowOpacity = 0.4;
  });

  void _onTapCancel() => setState(() {
    _scale = 1.0;
    _shadowOpacity = 0.4;
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.w),
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        child: Padding(
          padding: EdgeInsets.only(bottom: 16.h),
          child: TweenAnimationBuilder(
            duration: const Duration(milliseconds: 100),
            tween: Tween<double>(begin: 1.0, end: _scale),
            builder: (context, scale, child) {
              return Transform.scale(scale: scale, child: child);
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
              child: Row(
                children: [
                  Icon(widget.icon, size: 30.sp, color: widget.color),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: GoogleFonts.poppins(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

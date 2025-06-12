import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  int xp = 0, currentStreak = 0, longestStreak = 0;
  String? avatarUrl;
  bool isUpdating = false;


  final List<Color> accentShadows = [
    Color(0xFF00E5FF),
    Color(0xFF7C4DFF),
    Color(0xFFFF9100),
    Color(0xFFFF4081),
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();

    super.dispose();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString("email");
    if (email == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection("details")
        .where("email", isEqualTo: email)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final data = snapshot.docs.first.data();
      setState(() {
        nameController.text = data["name"] ?? "";
        emailController.text = data["email"] ?? "";
        xp = data["xp"] ?? 0;
        currentStreak = data["currentStreak"] ?? 0;
        longestStreak = data["longestStreak"] ?? 0;
        avatarUrl = data["avatar"];
      });
    }
  }

  Future<void> _updateProfile() async {
    setState(() => isUpdating = true);
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString("email");
    if (email == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection("details")
        .where("email", isEqualTo: email)
        .get();

    if (snapshot.docs.isNotEmpty) {
      await snapshot.docs.first.reference.update({
        "name": nameController.text.trim(),
        "avatar": avatarUrl ?? "",
      });
      prefs.setString("name", nameController.text.trim());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully")),
      );
    }
    setState(() => isUpdating = false);
  }

  InputDecoration _fieldDecoration(String label, Color focusColor) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.poppins(color: Colors.white70),
      prefixIcon: Icon(label == "Name"
          ? Icons.person
          : Icons.email, color: Colors.white),
      filled: true,
      fillColor: const Color(0xFF1E1E1E),
      contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.r),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.r),
        borderSide: BorderSide(color: focusColor, width: 2.0),
      ),
    );
  }

  Widget _buildStatCard(String title, int value, Color glow) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 12.w),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: glow.withOpacity(0.25),
            blurRadius: 12.r,
            offset: Offset(0, 6.h),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            "$value",
            style: GoogleFonts.poppins(
              fontSize: 22.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            title,
            style: GoogleFonts.roboto(
              fontSize: 14.sp,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0A0F1C), Color(0xFF121212)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.all(22.w),
            children: [
              Text(
                "My Profile",
                style: GoogleFonts.poppins(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 20.h),
              Center(
                child: GestureDetector(
                  onTap: (){},
                  child: CircleAvatar(
                    radius: 50.r,
                    backgroundColor: Colors.grey.shade800,
                    backgroundImage: avatarUrl != null
                        ? NetworkImage(avatarUrl!)
                        : null,
                    child: avatarUrl == null
                        ? Icon(Icons.person,
                        size: 50.sp, color: Colors.white38)
                        : null,
                  ),
                ),
              ),
              SizedBox(height: 30.h),
              TextField(
                controller: nameController,
                style: const TextStyle(color: Colors.white),
                decoration: _fieldDecoration(
                    "Name", accentShadows[0]),
              ),
              SizedBox(height: 16.h),
              TextField(
                controller: emailController,
                readOnly: true,
                style: const TextStyle(color: Colors.white70),
                decoration: _fieldDecoration(
                    "Email", accentShadows[1]),
              ),
              SizedBox(height: 24.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatCard(
                      "     XP     ", xp, accentShadows[2]),
                  _buildStatCard(
                      "  Streak  ", currentStreak, accentShadows[3]),
                  _buildStatCard(
                      "Longest", longestStreak, accentShadows[0]),
                ],
              ),
              SizedBox(height: 30.h),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade900,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r)),
                  shadowColor: Colors.blue.withOpacity(0.6),
                  elevation: 8,
                ),
                onPressed: isUpdating ? null : _updateProfile,
                child: isUpdating
                    ? SizedBox(
                  height: 24.h,
                  width: 24.w,
                  child: CircularProgressIndicator(
                    color: Colors.black, strokeWidth: 2,
                  ),
                )
                    : Text(
                  "Save Changes",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:ai_one/Screens/home.dart';
import 'package:ai_one/authentication/forget_password.dart';
import 'package:ai_one/authentication/register.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../main.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}
class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _obscurePassword = true;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    fetchFirestoreData();
  }

  List<Map<String, dynamic>> dataList = [];

  Future<void> fetchFirestoreData() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('details')
          .get();
      setState(() {
        dataList = querySnapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
      });
    } catch (e) {
      print("❌ Error fetching Firestore data: $e");
      showCustomSnackbar(
          context, "Failed to fetch user data. Please try again later.");
    }
  }

  bool emailExists(String targetEmail) {
    return dataList.any((item) => item['email'] == targetEmail);
  }

  Future<void> saveUserData(String email, String method, String id) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("email", email);
    await prefs.setString("method", method);
    await prefs.setBool("isLoggedIn", true);
    print(prefs.get("email"));
    print(prefs.get("method"));
    print(prefs.get("isLoggedIn"));
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void showCustomSnackbar(BuildContext context, String message) {
    final snackBar = SnackBar(
      content: Row(
        children: [
          const Icon(Icons.notifications_active, color: Colors.white),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.deepPurpleAccent,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      duration: const Duration(seconds: 3),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> _login() async {
    String email = emailController.text;
    String password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      showCustomSnackbar(context, "Please enter both email and password.");
      return;
    }
    if (!emailExists(email)) {
      showCustomSnackbar(context, "Account does not exist! Please register.");
      return;
    }
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      User? user = userCredential.user;
      if (user != null) {
        await onSignInSuccess(user, 'email');
        Navigator.pushAndRemoveUntil(
          context, MaterialPageRoute(builder: (context) => MainScreen(),), (
            route) => false,);
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-credential') {
        showCustomSnackbar(context, "Incorrect password. Please try again.");
      } else if (e.code == 'too-many-requests') {
        showCustomSnackbar(
            context, "Too many requests. Please try again later.");
      } else {
        showCustomSnackbar(context, "Login failed: ${e.message}");
      }
    }
    passwordController.clear();
    emailController.clear();
  }

  Future<void> onSignInSuccess(User user, String method) async {
    var id;
    QuerySnapshot querySnapshot = await _firestore
        .collection('details')
        .where('email', isEqualTo: user.email)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final userDoc = querySnapshot.docs.first;
      final data = userDoc.data() as Map<String, dynamic>;
      id = data['id'] ?? "";
    } else {
      showCustomSnackbar(context, "User with the given email not found.");
      return;
    }

    showCustomSnackbar(context, "Logged in successfully!");
    await saveUserData(user.email!, method, id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Welcome Back 👋",
                    style: GoogleFonts.poppins(
                      fontSize: 30.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    "Please sign in to continue.",
                    style: GoogleFonts.roboto(
                      fontSize: 16.sp,
                      color: Colors.white70,
                    ),
                  ),
                  SizedBox(height: 40.h),

                  // Email Field
                  _styledTextField(
                    controller: emailController,
                    label: "Email",
                    icon: Icons.email_outlined,
                  ),
                  SizedBox(height: 20.h),

                  // Password Field
                  _styledTextField(
                    controller: passwordController,
                    label: "Password",
                    icon: Icons.lock_outline,
                    obscureText: _obscurePassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        color: Colors.white60,
                        size: 24.sp,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  SizedBox(height: 10.h),

                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => ResetPasswordScreen(),));
                      },
                      child: Text(
                        "Forgot Password?",
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF00E5FF),
                          fontWeight: FontWeight.w500,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 30.h),

                  // Login Button
                  GestureDetector(
                    onTap: _login,
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16.r),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF00C853), Color(0xFF00E5FF)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.1),
                            blurRadius: 15.r,
                            spreadRadius: 2.r,
                            offset: Offset(0, 3.h),
                          ),
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 12.r,
                            offset: Offset(0, 6.h),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          "Login",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18.sp,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),

                  // Register Redirect
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account?",
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 14.sp,
                        ),
                      ),
                      TextButton(
                        onPressed: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterScreen(),));
                        },
                        child: Text(
                          "Register",
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF7C4DFF),
                            fontWeight: FontWeight.bold,
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _styledTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Padding(
      padding: EdgeInsets.all(8.w),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.05),
              blurRadius: 12.r,
              offset: Offset(0, 6.h),
            ),
            BoxShadow(
              color: Colors.blue.withOpacity(0.8),
              blurRadius: 4.r,
              offset: Offset(0, 2.h),
            ),
          ],
        ),
        child: TextField(
          controller: controller,
          obscureText: obscureText,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 16.sp,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.transparent,
            labelText: label,
            labelStyle: GoogleFonts.roboto(
              color: Colors.white70,
              fontSize: 14.sp,
            ),
            prefixIcon: Icon(icon, color: Colors.white60, size: 24.sp),
            suffixIcon: suffixIcon,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.r),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
    );
  }
}



import 'dart:ui';

import 'package:ai_one/Screens/home.dart';
import 'package:ai_one/authentication/login.dart';
import 'package:ai_one/Screens/profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Screens/setting.dart';
import 'on_boarding.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'services/ads_service.dart';
import 'services/interstitial_ad_service.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await AdsService().initialize();
  await MobileAds.instance.initialize();
  
  // Initialize interstitial ad service
  final interstitialAdService = InterstitialAdService();
  await interstitialAdService.initialize();


  final prefs = await SharedPreferences.getInstance();
  final bool isOnboardingCompleted = prefs.getBool('onboarding_complete') ?? false;
  final User? user = FirebaseAuth.instance.currentUser;

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: ScreenUtilInit(
        designSize: Size(430, 932), // For Google Pixel 9 Pro XL
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return child!;
        },
        child: user != null
            ? MainScreen()
            : isOnboardingCompleted
            ? LoginScreen()
            : OnboardingScreen(),
      ),
    ),
  );
}


class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [HomePage(), SettingsScreen(), ProfilePage()];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25.r),
            topRight: Radius.circular(25.r),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 8.r,
              spreadRadius: 2.r,
              offset: Offset(0, -4.h),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: GNav(
            backgroundColor: Colors.transparent,
            color: Colors.white,
            activeColor: Colors.white,
            iconSize: 30.sp,
            gap: 10.w,
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
            duration: const Duration(milliseconds: 500),
            tabBackgroundColor: Colors.white.withOpacity(0.2),
            curve: Curves.easeInOut,
            rippleColor: Colors.white.withOpacity(0.2),
            tabs: [
              GButton(
                icon: Icons.home,
                text: 'Home',
                onPressed: () => _onItemTapped(0),
                iconColor: Colors.white,
                iconActiveColor: Colors.white,
              ),
              GButton(
                icon: Icons.settings,
                text: 'Settings',
                onPressed: () => _onItemTapped(1),
                iconColor: Colors.white,
                iconActiveColor: Colors.white,
              ),
              GButton(
                icon: Icons.account_circle,
                text: 'Profile',
                onPressed: () => _onItemTapped(2),
                iconColor: Colors.white,
                iconActiveColor: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}


import 'dart:async';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InterstitialAdService {
  static final InterstitialAdService _instance = InterstitialAdService._internal();
  factory InterstitialAdService() => _instance;
  InterstitialAdService._internal();

  InterstitialAd? _interstitialAd;
  bool _isAdLoaded = false;
  Timer? _timer;
  DateTime? _lastAdShownTime;
  static const int _adIntervalMinutes = 15;
  
  // Test video ad unit ID - replace with your actual video ad unit ID in production
  String _adUnitId = /*'ca-app-pub-3940256099942544/8691691433'*/ "ca-app-pub-5796676596026685/3399724308"; // Test video ad unit ID

  Future<void> initialize() async {
    await MobileAds.instance.initialize();
    _loadAd();
    _startTimer();
    _loadLastAdShownTime();
  }

  Future<void> _loadLastAdShownTime() async {
    final prefs = await SharedPreferences.getInstance();
    final lastAdTime = prefs.getInt('last_ad_shown_time');
    if (lastAdTime != null) {
      _lastAdShownTime = DateTime.fromMillisecondsSinceEpoch(lastAdTime);
    }
  }

  Future<void> _saveLastAdShownTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('last_ad_shown_time', DateTime.now().millisecondsSinceEpoch);
    _lastAdShownTime = DateTime.now();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      print("adad");
      _checkAndShowAd();
    });
  }

  void _loadAd() {
    InterstitialAd.load(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isAdLoaded = true;
          _setupFullScreenCallback();

        },
        onAdFailedToLoad: (error) {
          debugPrint('Interstitial video ad failed to load: ${error.message}');
          _isAdLoaded = false;
          _interstitialAd = null;

          // Retry loading after a delay
          Future.delayed(const Duration(minutes: 1), _loadAd);
        },
      ),
    );
  }

  void _setupFullScreenCallback() {
    _interstitialAd?.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        debugPrint('Interstitial video ad showed full screen content.');

      },
      onAdDismissedFullScreenContent: (ad) {
        debugPrint('Interstitial video ad dismissed full screen content.');

        ad.dispose();
        _isAdLoaded = false;
        _loadAd(); // Load the next ad
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('Failed to show interstitial video ad: ${error.message}');

        ad.dispose();
        _isAdLoaded = false;
        _loadAd(); // Try to load another ad
      },
      onAdImpression: (ad) {
        debugPrint('Interstitial video ad impression recorded.');

      },
    );
  }

  void _checkAndShowAd() {
    if (!_isAdLoaded || _interstitialAd == null) return;

    final now = DateTime.now();
    if (_lastAdShownTime == null ||
        now.difference(_lastAdShownTime!).inMinutes >= _adIntervalMinutes) {
      _showAd();
    }
  }

  void _showAd() {
    if (!_isAdLoaded || _interstitialAd == null) return;

    _interstitialAd?.show();
    _saveLastAdShownTime();
  }

  void dispose() {
    _timer?.cancel();
    _interstitialAd?.dispose();
  }

  // Method to manually show ad (can be used for testing)
  void showAdManually() {
    _showAd();
  }

  // Update ad unit ID for production
  void setAdUnitId(String adUnitId) {
    _adUnitId = adUnitId;
  }

  // Check if an ad is currently loaded
  bool get isAdLoaded => _isAdLoaded;

  // Get time until next ad can be shown
  int get minutesUntilNextAd {
    if (_lastAdShownTime == null) return 0;
    final now = DateTime.now();
    final difference = now.difference(_lastAdShownTime!).inMinutes;
    return _adIntervalMinutes - difference;
  }
} 
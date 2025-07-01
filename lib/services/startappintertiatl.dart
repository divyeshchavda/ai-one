import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:startapp_sdk/startapp.dart';

class StartAppAutoInterstitialService {
  static final StartAppAutoInterstitialService _instance = StartAppAutoInterstitialService._internal();
  factory StartAppAutoInterstitialService() => _instance;
  StartAppAutoInterstitialService._internal();

  final StartAppSdk _sdk = StartAppSdk();
  StartAppInterstitialAd? _interstitialAd;
  Timer? _timer;
  DateTime? _lastShown;
  static const int _intervalMinutes = 15;

  Future<void> initialize() async {
    // REMOVE THIS LINE IN PRODUCTION
    //  _sdk.setTestAdsEnabled(true);

    _loadLastShownTime();
    _startTimer();
    _loadAd();
  }

  Future<void> _loadLastShownTime() async {
    final prefs = await SharedPreferences.getInstance();
    final millis = prefs.getInt('startapp_last_ad_shown_time');
    if (millis != null) {
      _lastShown = DateTime.fromMillisecondsSinceEpoch(millis);
    }
  }

  Future<void> _saveLastShownTime() async {
    final prefs = await SharedPreferences.getInstance();
    _lastShown = DateTime.now();
    await prefs.setInt('startapp_last_ad_shown_time', _lastShown!.millisecondsSinceEpoch);
  }

  void _startTimer() {
    _timer?.cancel();
    print("Adad");
    _timer = Timer.periodic(const Duration(minutes: 1), (_) => _checkAndShowAd());
  }

  void _loadAd() {
    _sdk.loadInterstitialAd(
      prefs: const StartAppAdPreferences(adTag: "auto_interstitial"),
      onAdDisplayed: () {
        debugPrint("StartApp: Interstitial Ad Displayed");
      },
      onAdHidden: () {
        _disposeAd();
        _loadAd();
        _saveLastShownTime();
      },
      onAdNotDisplayed: () {
        _disposeAd();
        _loadAd();
      },
    ).then((ad) {
      _interstitialAd = ad;
      debugPrint("StartApp: Interstitial Ad loaded");
    }).onError((error, stack) {
      debugPrint("StartApp: Failed to load Interstitial Ad: $error");
    });
  }

  void _checkAndShowAd() {
    final now = DateTime.now();
    if (_interstitialAd == null) return;

    if (_lastShown == null || now.difference(_lastShown!).inMinutes >= _intervalMinutes) {
      _interstitialAd!.show().onError((e, _) {
        debugPrint("StartApp: Error showing ad: $e");
        _disposeAd();
        _loadAd();
        return false;
      });
    }
  }

  void _disposeAd() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
  }

  void dispose() {
    _timer?.cancel();
    _disposeAd();
  }
}

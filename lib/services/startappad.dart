import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:startapp_sdk/startapp.dart';

class StartAppAdService {
  static final StartAppAdService _instance = StartAppAdService._internal();
  factory StartAppAdService() => _instance;
  StartAppAdService._internal();

  final StartAppSdk _sdk = StartAppSdk();

  StartAppBannerAd? _bannerAd;
  StartAppInterstitialAd? _interstitialAd;
  StartAppRewardedVideoAd? _rewardedAd;
  StartAppNativeAd? _nativeAd;


  bool _isTest = true;

  Future<void> initialize({bool testMode = true}) async {
    // _isTest = testMode;
   // if (_isTest) _sdk.setTestAdsEnabled(true);
  }

  // ─────────────────────── BANNER ───────────────────────

  Future<StartAppBannerAd?> loadBannerAd() async {
    try {
      _bannerAd = await _sdk.loadBannerAd(
        StartAppBannerType.BANNER,
        prefs: const StartAppAdPreferences(adTag: 'home_banner'),
        onAdImpression: () => debugPrint('Banner ad impression'),
        onAdClicked: () => debugPrint('Banner ad clicked'),
      );
      return _bannerAd;
    } catch (e) {
      debugPrint('Banner Ad Error: $e');
      return null;
    }
  }

  Widget getBannerWidget() {
    return _bannerAd != null ? StartAppBanner(_bannerAd!) : const SizedBox();
  }

  // ───────────────────── INTERSTITIAL ─────────────────────

  Future<void> loadInterstitialAd() async {
    try {
      _interstitialAd = await _sdk.loadInterstitialAd(
        prefs: const StartAppAdPreferences(adTag: 'game_over'),
        onAdDisplayed: () => debugPrint('Interstitial shown'),
        onAdNotDisplayed: () {
          debugPrint('Interstitial failed to show');
          _interstitialAd?.dispose();
          _interstitialAd = null;
        },
        onAdClicked: () => debugPrint('Interstitial clicked'),
        onAdHidden: () {
          debugPrint('Interstitial hidden');
          _interstitialAd?.dispose();
          _interstitialAd = null;
        },
      );
    } catch (e) {
      debugPrint('Interstitial Ad Error: $e');
    }
  }

  void showInterstitialAd() {
    if (_interstitialAd != null) {
      _interstitialAd!.show();
    } else {
      debugPrint("Interstitial ad not loaded");
    }
  }

  // ───────────────────── REWARDED ─────────────────────

  Future<void> loadRewardedAd({
    required VoidCallback onReward,
  }) async {
    try {
      _rewardedAd = await _sdk.loadRewardedVideoAd(
        prefs: const StartAppAdPreferences(adTag: 'reward_ad'),
        onAdNotDisplayed: () {
          debugPrint('Rewarded ad not displayed');
          _rewardedAd?.dispose();
          _rewardedAd = null;
        },
        onAdHidden: () {
          debugPrint('Rewarded ad hidden');
          _rewardedAd?.dispose();
          _rewardedAd = null;
        },
        onVideoCompleted: () {
          debugPrint('Rewarded video completed – user should get reward');
          onReward();
        },
      );
    } catch (e) {
      debugPrint('Rewarded Ad Error: $e');
    }
  }

  void showRewardedAd() {
    if (_rewardedAd != null) {
      _rewardedAd!.show().onError((error, _) {
        debugPrint("Error showing Rewarded ad: $error");
        return false;
      });
    } else {
      debugPrint("Rewarded ad not loaded");
      showInterstitialAd();
    }
  }

  // ===================NATIVE AD=============================
  Future<StartAppNativeAd?> loadNativeAd() async {
    try {
      _nativeAd = await _sdk.loadNativeAd(
        prefs: const StartAppAdPreferences(adTag: 'native_card'),
        onAdImpression: () => debugPrint('Native ad impression'),
        onAdClicked: () => debugPrint('Native ad clicked'),
      );
      return _nativeAd;
    } catch (e) {
      debugPrint('Native Ad Error: $e');
      return null;
    }
  }
  Widget getNativeAdWidget() {
    if (_nativeAd != null) {
      return StartAppNative(
        _nativeAd!,
            (context, setState, nativeAd) {
          return Container(
            width: 280,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color:  const Color(0xFF1E1E1E),
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nativeAd.title!.length>25?nativeAd.title!.substring(0,25):nativeAd.title ?? '',
                  style: const TextStyle(fontWeight: FontWeight.bold,color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(nativeAd.description!.length>25?nativeAd.description!.substring(0,25):nativeAd.description ?? '',style: const TextStyle(color: Colors.white),),
                const SizedBox(height: 8),
                if (nativeAd.imageUrl != null)
                  Image.network(nativeAd.imageUrl!,height: 70,width: 70,),
                const SizedBox(height: 8),
                ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                  onPressed: () {},
                  child: Text(nativeAd.callToAction.toString() ?? 'Learn More',style: TextStyle(color: Colors.white),),
                ),
              ],
            ),
          );
        },
      );

    } else {
      return const SizedBox();
    }
  }


}

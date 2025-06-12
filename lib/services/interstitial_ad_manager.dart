import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ads_service.dart';

class InterstitialAdManager {
  static final InterstitialAdManager _instance = InterstitialAdManager._internal();
  factory InterstitialAdManager() => _instance;
  InterstitialAdManager._internal();

  InterstitialAd? _interstitialAd;
  int _numInterstitialLoadAttempts = 0;
  static const int maxFailedLoadAttempts = 3;

  void loadInterstitialAd() {
    AdsService().createInterstitialAd().then((ad) {
      _interstitialAd = ad;
      _numInterstitialLoadAttempts = 0;
      _interstitialAd?.setImmersiveMode(true);
    }).catchError((error) {
      _numInterstitialLoadAttempts += 1;
      _interstitialAd = null;
      if (_numInterstitialLoadAttempts < maxFailedLoadAttempts) {
        loadInterstitialAd();
      }
    });
  }

  void showInterstitialAd() {
    if (_interstitialAd == null) {
      loadInterstitialAd();
      return;
    }
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        ad.dispose();
        loadInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        ad.dispose();
        loadInterstitialAd();
      },
    );
    _interstitialAd!.show();
    _interstitialAd = null;
  }

  void dispose() {
    _interstitialAd?.dispose();
  }
} 
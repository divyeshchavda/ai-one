import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdsService {
  static final AdsService _instance = AdsService._internal();
  factory AdsService() => _instance;
  AdsService._internal();

  // Test Ad Unit IDs
  static const String _testBannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
  static const String _testInterstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712';
  static const String _testRewardedAdUnitId = 'ca-app-pub-3940256099942544/5224354917';

  // Real Ad Unit IDs (to be used later)
  static const String _realBannerAdUnitId = 'ca-app-pub-5796676596026685/8800224792';
  static const String _realInterstitialAdUnitId = 'YOUR_INTERSTITIAL_AD_UNIT_ID';
  static const String _realRewardedAdUnitId = 'YOUR_REWARDED_AD_UNIT_ID';

  // App ID
  static const String _appId = 'ca-app-pub-5796676596026685~9575100475';

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    await MobileAds.instance.initialize();
    _isInitialized = true;
  }

  BannerAd createBannerAd() {
    return BannerAd(
      adUnitId: _realBannerAdUnitId, // Use test ID for now
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {},
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    );
  }

  Future<InterstitialAd?> createInterstitialAd() async {
    InterstitialAd? interstitialAd;
    await InterstitialAd.load(
      adUnitId: _testInterstitialAdUnitId, // Use test ID for now
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          interstitialAd = ad;
        },
        onAdFailedToLoad: (error) {
          interstitialAd = null;
        },
      ),
    );
    return interstitialAd;
  }

  Future<RewardedAd?> createRewardedAd() async {
    RewardedAd? rewardedAd;
    await RewardedAd.load(
      adUnitId: _testRewardedAdUnitId, // Use test ID for now
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          rewardedAd = ad;
        },
        onAdFailedToLoad: (error) {
          rewardedAd = null;
        },
      ),
    );
    return rewardedAd;
  }
} 
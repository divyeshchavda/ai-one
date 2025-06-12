import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ads_service.dart';

class RewardedAdManager {
  static final RewardedAdManager _instance = RewardedAdManager._internal();
  factory RewardedAdManager() => _instance;
  RewardedAdManager._internal();

  RewardedAd? _rewardedAd;
  int _numRewardedLoadAttempts = 0;
  static const int maxFailedLoadAttempts = 3;

  void loadRewardedAd() {
    AdsService().createRewardedAd().then((ad) {
      _rewardedAd = ad;
      _numRewardedLoadAttempts = 0;
    }).catchError((error) {
      _numRewardedLoadAttempts += 1;
      _rewardedAd = null;
      if (_numRewardedLoadAttempts < maxFailedLoadAttempts) {
        loadRewardedAd();
      }
    });
  }

  Future<bool> showRewardedAd() async {
    if (_rewardedAd == null) {
      loadRewardedAd();
      return false;
    }

    bool rewardGranted = false;
    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (RewardedAd ad) {
        ad.dispose();
        loadRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
        ad.dispose();
        loadRewardedAd();
      },
    );

    await _rewardedAd!.show(
      onUserEarnedReward: (_, RewardItem reward) {
        rewardGranted = true;
      },
    );
    _rewardedAd = null;
    return rewardGranted;
  }

  void dispose() {
    _rewardedAd?.dispose();
  }
} 
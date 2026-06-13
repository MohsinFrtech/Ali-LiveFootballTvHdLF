import 'package:google_mobile_ads/google_mobile_ads.dart';

class AppOpenAdManager {
  AppOpenAd? _appOpenAd;
  bool _isShowingAd = false;

  void loadAd() {
    AppOpenAd.load(
      adUnitId: 'ca-app-pub-6410383161608967/2687882946',
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenAd = ad;
        },
        onAdFailedToLoad: (error) {
          _appOpenAd = null;
        },
      ),
   //   orientation: AppOpenAd.orientationPortrait,
    );
  }

  void showAdIfAvailable() {
    if (_appOpenAd == null || _isShowingAd) return;

    _appOpenAd!.fullScreenContentCallback =
        FullScreenContentCallback(
          onAdShowedFullScreenContent: (ad) {
            _isShowingAd = true;
          },
          onAdDismissedFullScreenContent: (ad) {
            _isShowingAd = false;
            ad.dispose();
            loadAd();
          },
          onAdFailedToShowFullScreenContent: (ad, error) {
            _isShowingAd = false;
            ad.dispose();
            loadAd();
          },
        );

    _appOpenAd!.show();
  }
}

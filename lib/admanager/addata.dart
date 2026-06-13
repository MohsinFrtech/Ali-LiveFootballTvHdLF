import 'package:audience_network/audience_network.dart' as fan;
import 'package:clever_ads_solutions/clever_ads_solutions.dart' hide InitializationStatus;
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:footscore/codeutils/appconstants.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart' hide AdError;
import '../datamodels/streammodel.dart';
import 'google_consent.dart';

class AdManager {
  String provider = "none";
  static InterstitialAd? _interstitialAd;
  static bool _isInterstitialAdLoaded = false;
  static CASInterstitial? _interstitial;
  final _consentManager = ConsentManager();
  static fan.InterstitialAd? _interstitialAdFacebook;
  static final AdRequest request = AdRequest(
    keywords: <String>['foo', 'bar'],
    contentUrl: 'http://foo.com/bar.html',
    nonPersonalizedAds: true,
  );
  static RewardedAd? _rewardedAdAdmob;
  static bool _isRewardedAdLoaded = false;
  static fan.RewardedAd? _rewardedAdCasiAi;
  static CASRewarded? _rewardedAd;
  static bool _isCasRewardedAdLoaded = false;

  //Function to check ad provider from cms....
  String checkAdProvider(List<AppAd> listAd, String location) {
    if (listAd.isNotEmpty) {
      provider = "none";

      for (var listItem in listAd) {
        if (listItem.enable == true) {
          if (listItem.ad_locations != null) {
            for (var adLocation in listItem.ad_locations!) {
              if (location.toLowerCase() == adLocation.title?.toLowerCase()) {
                if (listItem.ad_provider?.toLowerCase() == AppConstants.admob) {
                  provider = AppConstants.admob;
                  checkAdValue(listItem.ad_key, location, provider);
                } else if (listItem.ad_provider?.toLowerCase() ==
                    AppConstants.facebook) {
                  provider = AppConstants.facebook;
                  checkAdValue(listItem.ad_key, location, provider);
                } else if (listItem.ad_provider?.toLowerCase() ==
                    AppConstants.casai) {
                  provider = AppConstants.casai;
                  checkAdValue(listItem.ad_key, location, provider);
                } else {
                  provider = "none";
                }
              }
            }
          }
        }
      }
      return provider;
    } else {
      return "none";
    }
  }

  //Function to get Id's values from cms.....
  void checkAdValue(String? adkey, String location, String provider) {
    if (location.toLowerCase() == AppConstants.locationMiddle ||
        location.toLowerCase() == AppConstants.locationBefore ||
        location.toLowerCase() == AppConstants.locationAfter ||
        location.toLowerCase() == AppConstants.locationTap
    || location.toLowerCase() == AppConstants.moreLocation
    ) {
      if (provider.toLowerCase() == AppConstants.admob) {
        AppConstants.admobInterstitial = adkey.toString();
        loadAdAtParticularPosition(provider, location);
      } else if (provider.toLowerCase() == AppConstants.facebook) {
        AppConstants.facebookInterstitial = adkey.toString();
        loadAdAtParticularPosition(provider, location);
      } else if (provider.toLowerCase() == AppConstants.casai) {
        AppConstants.casAiId = adkey.toString();
        loadAdAtParticularPosition(provider, location);
      }
    }else if (location.toLowerCase() == AppConstants.rewardedLocation) {
      //
      if (provider.toLowerCase() == AppConstants.admob) {
        AppConstants.rewardedInterstitial = adkey.toString();
        loadAdAtParticularPosition(provider, location);
      } else if (provider.toLowerCase() == AppConstants.facebook) {
        AppConstants.rewardedFacebook = adkey.toString();
        loadAdAtParticularPosition(provider, location);
      } else if (provider.toLowerCase() == AppConstants.casai) {
        AppConstants.casAiId = adkey.toString();
        loadAdAtParticularPosition(provider, location);
      }
    }
    else if (location.toLowerCase() == AppConstants.location1 ||
        location.toLowerCase() == AppConstants.location2Top ||
        location.toLowerCase() == AppConstants.location2Bottom ||
        location.toLowerCase() == AppConstants.location2TopPermanent) {
      if (provider.toLowerCase() == AppConstants.admob) {
        AppConstants.admobBanner = adkey.toString();
      } else if (provider.toLowerCase() == AppConstants.facebook) {
        AppConstants.facebookBanner = adkey.toString();
      } else if (provider.toLowerCase() == AppConstants.casai) {
        AppConstants.casAiId = adkey.toString();
        loadAdAtParticularPosition(provider, location);
      }
    } else if (location.toLowerCase() == AppConstants.nativeLocation) {
      if (provider.toLowerCase() == AppConstants.admob) {
        AppConstants.admobNative = adkey.toString();
        AppConstants.nativeAdProvider = AppConstants.admob;
      } else if (provider.toLowerCase() == AppConstants.facebook) {
        AppConstants.facebookNative = adkey.toString();
        AppConstants.nativeAdProvider = AppConstants.facebook;
      }
    }
  }

  //Function to load ad at particular position....
  void loadAdAtParticularPosition(String provider, String adLocation) {
    if (provider.toLowerCase() == AppConstants.admob) {

      if (AppConstants.isInitAdmob) {
        loadAdBasesOnLocation(adLocation, provider);
      } else {
        //// admob not initialize .....
        initializeAdmobSdk().then(
              (value) => {
            AppConstants.isInitAdmob = true,
            loadAdBasesOnLocation(adLocation, provider),
          },
          onError: (error) {
            AppConstants.isInitAdmob = false;
            loadAdBasesOnLocation(adLocation, provider);
          },
        );
      }
    } else if (provider.toLowerCase() == AppConstants.facebook) {
      if (AppConstants.isInitFacebook) {
        loadAdBasesOnLocation(adLocation, provider);
      } else {
        loadFacebookSdk(adLocation, provider);
      }
    } else if (provider.toLowerCase() == AppConstants.casai) {
      if (AppConstants.isInitCasAi) {
         // loadAdBasesOnLocation(adLocation, provider);
      } else {
        _initializeCAS(adLocation, provider);
      }
    }
  }

  void _initializeCAS(String adLocation, String provider) {
    // CAS.settings.setDebugMode(true);
    CAS.settings.setTaggedAudience(Audience.notChildren);

    // Configure Consent flow
    final ConsentFlow consentFlow = ConsentFlow.create()
        .setOnDismissCallback(_onConsentFlowDismissed)
        .withPrivacyPolicy('https://future-visionadvertising.com/privacy-policy');
    // Initialize SDK
    CAS
        .buildManager()
        .withCasId(AppConstants.casAiId)
        // .withTestMode(kDebugMode)
        .withConsentFlow(consentFlow)
        .withCompletionListener(_onInitializationCompleted)
        .build();
    loadAdBasesOnLocation(adLocation, provider);
  }

  void _onInitializationCompleted(InitConfig initConfig) async {
    final String? error = initConfig.error;
    if (error != null) {
      AppConstants.isInitCasAi = false;
      return;
    }
    AppConstants.isInitCasAi = true;
  }

  late final ScreenAdContentCallback _contentCallback = ScreenAdContentCallback(
    onAdLoaded: (ad) async => {
      AppConstants.adLoadStatus = "loaded",
      debugPrint('${await ad.getFormat()} ad loaded: ${await ad.getSourceName()}'),
    },
    onAdFailedToLoad: (format, error) => {
      AppConstants.adLoadStatus = "not loaded",
      debugPrint('$format ad failed to load: $error'),
    },
    onAdShowed: (ad) async => {
      debugPrint('${await ad.getFormat()} ad showed: ${await ad.getSourceName()}'),
    },
    onAdFailedToShow: (format, error) => {
      debugPrint('$format ad failed to show: $error'),
    },
    onAdClicked: (ad) async => {
      debugPrint('${await ad.getFormat()} ad clicked: ${await ad.getSourceName()}'),
    },
    onAdDismissed: (ad) async => {
      debugPrint(
        '${await ad.getFormat()} ad dismissed: ${await ad.getSourceName()}',
      ),
    },
  );

  void _showInterstitialCasAi(
    ValueChanged<String> callback,
    String locaName,
  ) async {
    // You can show ads without checking for isLoaded,
    // expecting an error in onAdFailedToShow.
    if (_interstitial == null) {
      callback.call("finish");
      return;
    }

    if (_interstitial != null) {
      try {
        _interstitial?.contentCallback = ScreenAdContentCallback(
          onAdShowed: (ad) async {
            if (locaName == AppConstants.locationAfter) {
              Future.delayed(const Duration(seconds: 2), () {
                callback.call("finish");

                // moveToNextScreen();
              });
              debugPrint(
                '${await ad.getFormat()} ad showed after: ${await ad.getSourceName()}',
              );
            } else {
              debugPrint(
                '${await ad.getFormat()} ad showed: ${await ad.getSourceName()}',
              );
            }
          },
          onAdFailedToShow: (format, error) {
            callback.call("finish");
            debugPrint('$format ad failed to show: $error');
          },
          onAdClicked: (ad) async {
            debugPrint(
              '${await ad.getFormat()} ad clicked: ${await ad.getSourceName()}',
            );
          },
          onAdDismissed: (ad) async {
            debugPrint(
              '${await ad.getFormat()} ad dismissed: ${await ad.getSourceName()}',
            );
            if (locaName == AppConstants.locationAfter) {
            } else {
              callback.call("finish");
            }
          },

          // onAdShowed: (ad) async => {
          //   print(
          //     '${await ad.getFormat()} ad showed: ${await ad.getSourceName()}',
          //   ),
          // },
          // onAdFailedToShow: (format, error) => {
          //   callback.call("finish"),
          //   print('$format ad failed to show: $error'),
          // },
          // onAdClicked: (ad) async => {
          //   print(
          //     '${await ad.getFormat()} ad clicked: ${await ad.getSourceName()}',
          //   ),
          // },
          // onAdDismissed: (ad) async => {
          //   callback.call("finish"),
          //   print(
          //     '${await ad.getFormat()} ad dismissed: ${await ad.getSourceName()}',
          //   ),
          //
          // },
        );
        _interstitial?.show();
        if (await _interstitial!.isLoaded()) {

        } else {
          if (locaName == AppConstants.locationAfter) {
          } else {
            callback.call("finish");
            debugPrint('Interstitial ad not ready to show');
          }
        }
      } catch (e) {
        debugPrint("Interstitial not initialized 2 $e");
        callback.call("finish");
        // initInterstitialCasAd();
      }
    }
  }

  final OnAdImpressionListener _impressionListener = OnAdImpressionListener(
    (ad) async => {debugPrint("")},
  );

  bool _useAutoLoad = true;

  void initInterstitialCasAd() {
    _interstitial = CASInterstitial.create(AppConstants.casAiId);
    _interstitial?.contentCallback = _contentCallback;
    _interstitial?.impressionListener = _impressionListener;
    _interstitial?.setAutoloadEnabled(_useAutoLoad); // false by default
    // _interstitial?.setAutoshowEnabled(true); // false by default
    _interstitial?.setMinInterval(0);

    // by default
    if (!_useAutoLoad) {
      _interstitial?.load();
    }
  }

  void _onConsentFlowDismissed(int status) {
    switch (status) {
      case ConsentFlow.statusObtained:
        // Consent obtained
        break;
    }
    debugPrint('Consent flow dismissed: $status');
  }

  Future<void> loadFacebookSdk(String adLocation, String provider) async {
    fan.AudienceNetwork.init(
      // testingId: "b602d594afd2b0b327e07a06f36ca6a7e42546d0",
      // testMode: true,
    ).then((_) {
      debugPrint("comes in facebook");
      AppConstants.isInitFacebook = true;
      loadAdBasesOnLocation(adLocation, provider);
    });
    // var result = await FacebookAudienceNetwork.init(
    //   testingId: "", //optional
    //   iOSAdvertiserTrackingEnabled: true,
    // );
    // debugPrint("comes in facebook ${result}");
    //
    // if (result != null) {
    //   if (result == true) {
    //     AppConstants.isInitFacebook = true;
    //     loadAdBasesOnLocation(adLocation, provider);
    //   }
    // }

  }

  void loadAdBasesOnLocation(String adLocation, String provider) {
    if (adLocation.toLowerCase() == AppConstants.location1 ||
        adLocation.toLowerCase() == AppConstants.location2Top ||
        adLocation.toLowerCase() == AppConstants.location2Bottom) {
      if (provider.toLowerCase() == AppConstants.admob) {}
    }else if (adLocation.toLowerCase() == AppConstants.rewardedLocation) {
      if (provider.toLowerCase() == AppConstants.admob) {
        _createRewardedAdAdmob();
      } else if (provider.toLowerCase() == AppConstants.facebook) {
        _loadRewardedVideoAdFacebook();
      } else if (provider.toLowerCase() == AppConstants.casai) {
        _createRewardedAd(true);
      }
    }
    else {
      if (provider.toLowerCase() == AppConstants.admob) {
        loadAdMobInterstitial();
      } else if (provider.toLowerCase() == AppConstants.facebook) {
        _loadFacebookInterstitialAd();
      } else if (provider.toLowerCase() == AppConstants.casai) {
        initInterstitialCasAd();
      }
    }
  }

  void _createRewardedAdAdmob() {
    RewardedAd.load(
      adUnitId: AppConstants.rewardedInterstitial,
      request: request,
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          print('$ad loaded.');
          _rewardedAdAdmob = ad;
        },
        onAdFailedToLoad: (LoadAdError error) {
          print('RewardedAd failed to load: $error');
          _rewardedAdAdmob = null;
        },
      ),
    );
  }

  void _createRewardedAd(bool autoReload) {
    _rewardedAd = CASRewarded.createAndLoad(
      autoReload: autoReload,
      onAdLoaded: (AdScreenInstance ad) {
        print('$ad loaded');
        _isCasRewardedAdLoaded = true;
      },
      onAdFailedToLoad: (AdInstance ad, AdError error) {
        print('$ad failed to load: ${error.message}.');
        if (autoReload) {
          // just wait for the automatic reload
        } else {
          ad.dispose();
          Future.delayed(const Duration(seconds: 10), () {
            _rewardedAd?.load();
          });
        }
      },
      onAdFailedToShow: (AdInstance ad, AdError error) {
        print('$ad failed to show: ${error.message}.');
        if (autoReload) {
          // just wait for the automatic reload
        } else {
          _rewardedAd?.load();
        }
      },
      onAdShowed: (AdScreenInstance ad) {
        print('$ad showed');
      },
      onAdImpression: (AdInstance ad, AdContentInfo contentInfo) {
        print('$ad impression creative id: ${contentInfo.creativeId}');
      },
      onAdClicked: (AdInstance ad) {
        print('$ad clicked');
      },
      onAdDismissed: (AdScreenInstance ad) {
        print('$ad dismissed');
        if (autoReload) {
          // just wait for the automatic reload
        } else {
          _rewardedAd?.load();
        }
      },
    );
  }

  void _loadRewardedVideoAdFacebook() {

    debugPrint('rewarded ad');
    final rewardedAdCas = fan.RewardedAd("YOUR_PLACEMENT_ID");
    rewardedAdCas.listener = fan.RewardedAdListener(
      onLoaded: () {
        _isRewardedAdLoaded = true;
        debugPrint('rewarded ad loaded');
        _rewardedAdCasiAi = rewardedAdCas;
      },
      onError: (code, message) {
        print('rewarded ad error\ncode = $code\nmessage = $message');
      },
      onVideoClosed: () {
        // load next ad already
        rewardedAdCas.destroy();
        _isRewardedAdLoaded = false;
      },
    );
    rewardedAdCas.load();
  }



  void _loadFacebookInterstitialAd() {
    final interstitialAd = fan.InterstitialAd(AppConstants.facebookInterstitial);
    interstitialAd.listener = fan.InterstitialAdListener(
      onLoaded: () {
        _interstitialAdFacebook = interstitialAd;
        _isInterstitialAdLoaded = true;
        AppConstants.adLoadStatus = "loaded";
        print('interstitial ad loaded ${_interstitialAdFacebook}');

      },
      onError: (code, message) {
        print('interstitial ad error\ncode = $code\nmessage = $message');
        AppConstants.adLoadStatus = "not loaded";
      },
      onDismissed: () {
        interstitialAd.destroy();
        _isInterstitialAdLoaded = false;
        AppConstants.adLoadStatus = "not loaded";
      },
    );

    interstitialAd.load();

    //   FacebookInterstitialAd.loadInterstitialAd(
    //   // placementId: "YOUR_PLACEMENT_ID",
    //   placementId: AppConstants.facebookInterstitial,
    //   listener: (result, value) {
    //     if (result == InterstitialAdResult.LOADED) {
    //       _isInterstitialAdLoaded = true;
    //       AppConstants.adLoadStatus = "not loaded";
    //       _showFacebookInterstitialAd();
    //     }
    //
    //     if (result == InterstitialAdResult.ERROR) {
    //       _isInterstitialAdLoaded = false;
    //       AppConstants.adLoadStatus = "not loaded";
    //     }
    //
    //     if (result == InterstitialAdResult.DISMISSED &&
    //         value["invalidated"] == true) {
    //       _isInterstitialAdLoaded = false;
    //       AppConstants.adLoadStatus = "not loaded";
    //     }
    //   },
    // );
  }


  Future<void> _showFacebookInterstitialAd(ValueChanged<String> callback) async {
    // final interstitialAd = _interstitialAdFacebook;
    if (_interstitialAdFacebook != null && _isInterstitialAdLoaded == true) {
      _interstitialAdFacebook?.listener = fan.InterstitialAdListener(
        onDismissed: () {
          _interstitialAdFacebook?.destroy();
          _isInterstitialAdLoaded = false;
          AppConstants.adLoadStatus = "not loaded";
          callback.call("finish");
        },
      );
      _interstitialAdFacebook?.show();
    } else {
      callback.call("finish");
      print("Interstial Ad not yet loaded! $_interstitialAdFacebook $_isInterstitialAdLoaded");
    }
  }

  void showRewardedAds(
      String adProviderName, ValueChanged<String> callback, String locName) {
    if (adProviderName.toLowerCase() == AppConstants.admob) {

      if (_rewardedAdAdmob == null) {
        callback.call("finish");
        print('Warning: attempt to show rewarded before loaded.');
        return;
      }
      _rewardedAdAdmob?.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (RewardedAd ad) =>
            print('ad onAdShowedFullScreenContent.'),
        onAdDismissedFullScreenContent: (RewardedAd ad) {
          callback.call("finish");
          print('$ad onAdDismissedFullScreenContent.');
          ad.dispose();
        },

      );
      _rewardedAdAdmob?.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
          callback.call("finish");
          print('$ad with reward $RewardItem(${reward.amount}, ${reward.type})');
        },
      );
      _rewardedAdAdmob = null;

    } else if (adProviderName.toLowerCase() == AppConstants.casai) {
      if (_isCasRewardedAdLoaded = true) {
        _rewardedAd?.onUserEarnedReward = (AdScreenInstance ad) {
          _isCasRewardedAdLoaded = false;
          print('Reward the user for watching the $ad');
          callback.call("finish");
        };
        _rewardedAd?.show();
      } else {
        callback.call("finish");
      }
    } else if (adProviderName.toLowerCase() == AppConstants.facebook) {
      if (_rewardedAdCasiAi != null && _isRewardedAdLoaded) {
        _rewardedAdCasiAi?.show();
        callback.call("finish");
      } else {
        callback.call("finish");
        print("Rewarded Ad not yet loaded!");
      }
    }
  }

  void checkAdLoadedOrNot(
    ValueChanged<String> callback,
    String providerName,
    String locationName,
  ) {
    debugPrint("adloadedcheck $providerName");
    if (providerName != "none") {
      showAds(providerName, callback, locationName);
    } else {
      callback.call("finish");
    }
  }

  void showAds(
    String adProviderName,
    ValueChanged<String> callback,
    String locName,
  ) {
    if (adProviderName.toLowerCase() == AppConstants.admob) {
      showInterstitialAd(callback);
    } else if (adProviderName.toLowerCase() == AppConstants.casai) {
      _showInterstitialCasAi(callback, locName);
    } else if (adProviderName.toLowerCase() == AppConstants.facebook) {
      _showFacebookInterstitialAd(callback);
    }
  }

  void showInterstitialAd(ValueChanged<String> callback) {
    if (_interstitialAd != null) {
      _interstitialAd?.fullScreenContentCallback = FullScreenContentCallback(
        // Called when the ad showed the full screen content.
        onAdShowedFullScreenContent: (ad) {},
        // Called when an impression occurs on the ad.
        onAdImpression: (ad) {},
        // Called when the ad failed to show full screen content.
        onAdFailedToShowFullScreenContent: (ad, err) {
          AppConstants.adLoadStatus = "none";
          // Dispose the ad here to free resources.
          ad.dispose();
          callback.call("finish");
        },
        // Called when the ad dismissed full screen content.
        onAdDismissedFullScreenContent: (ad) {
          // Dispose the ad here to free resources.
          ad.dispose();
          AppConstants.adLoadStatus = "none";
          callback.call("finish");
        },
        // Called when a click is recorded for an ad.
        onAdClicked: (ad) {
          AppConstants.adLoadStatus = "none";
        },
      );

      _interstitialAd?.show();
    }
  }

  void loadAdMobInterstitial() {
    InterstitialAd.load(
      adUnitId: AppConstants.admobInterstitial,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        // Called when an ad is successfully received.
        onAdLoaded: (ad) {
          // Keep a reference to the ad so you can show it later.
          _interstitialAd = ad;
          AppConstants.adLoadStatus = "loaded";
          debugPrint('InterstitialAd successfully loaded: $ad');
        },
        // Called when an ad request failed.
        onAdFailedToLoad: (LoadAdError error) {
          _interstitialAd = null;
          AppConstants.adLoadStatus = "not loaded";
          debugPrint('InterstitialAd failed to load: $error');
        },
      ),
    );
  }

  Future<InitializationStatus> initializeAdmobSdk() {
    return MobileAds.instance.initialize();
  }
}

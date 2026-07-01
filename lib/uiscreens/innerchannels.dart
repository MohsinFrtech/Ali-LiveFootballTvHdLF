import 'dart:io';

import 'package:encrypt/encrypt.dart';
import 'package:flutter/material.dart' hide Key;
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:footscore/admanager/addata.dart';
import 'package:footscore/codeutils/appconstants.dart';
import 'package:footscore/codeutils/directplay.dart';
import 'package:footscore/datamodels/streammodel.dart';
import 'package:footscore/routing/approutes.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../viewmodels/streamcontroller.dart';
import 'package:audience_network/audience_network.dart' as fan;

class InnerChannelClass extends StatefulWidget {
  const InnerChannelClass({super.key});

  @override
  State<InnerChannelClass> createState() => _InnerChannelClassState();
}

class _InnerChannelClassState extends State<InnerChannelClass> with SingleTickerProviderStateMixin{
  final StreamingApiController _streamingController = Get.find();
  EventStreaming? selectedEvent;
  List<Channel> liveChannels = [];
  var nativePosition = false;
  NativeAd? _admobNativeAd;
  final RxBool _nativeAdAdmobValue = RxBool(false);
  final AdManager _adManager = AdManager();
  String beforeProvider = "none";
  int position = 0;
  late AnimationController _animationController;
  late Animation<Offset> _rightToLeftAnimation;

  @override
  void initState() {
    if (_streamingController.initialized) {
      beforeProvider = _streamingController.loadAdAtLocation(
        AppConstants.locationBefore,
      );

      _streamingController.loadAdAtLocation(AppConstants.nativeLocation);
    }
    if (AppConstants.nativeAdProvider.toLowerCase() == AppConstants.admob) {
      admobNativeAd();
    }
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 900), // Adjust duration as needed
      vsync: this,
    );
    _rightToLeftAnimation = Tween<Offset>(
      begin: const Offset(-1.0, 0.0), // Starts off-screen to the left
      end: Offset.zero, // Ends at its original position
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic, // A smooth easing curve
    ));

    _animationController.forward();
    var arguments = Get.arguments;
    selectedEvent = arguments['selectedEvent'];
    if (selectedEvent?.channels != null) {
      for (var channel in selectedEvent!.channels!) {
        bool eventBelongsCountry = false;
        if (channel.live == true) {
          if (channel.countryCodes != null &&
              channel.countryCodes!.isNotEmpty) {
            for (var code in channel.countryCodes!) {
              if (code.toLowerCase() ==
                  AppConstants.countryCode.toLowerCase()) {
                eventBelongsCountry = true;
                break;
              }
            }

            if (eventBelongsCountry) {
              liveChannels.add(channel);
            }
          } else {
            liveChannels.add(channel);
          }
        }
      }
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.of(context).size.width > 600;

    return PopScope(
      canPop: true,
      child: Scaffold(
        backgroundColor: Color(0xff0b3bbf),
        body: Stack(
          children: [
            Container(color:  Color(0xff0b3bbf)),
            SafeArea(
              top: false,
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.only(bottom: 20.0),
                    decoration: const BoxDecoration(
                      color: Color(0xff00327a),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(0.0),
                        bottomRight: Radius.circular(0.0),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 50.0, bottom: 20.0),
                      child: Row(
                        children: [
                          // Padding(
                          //   padding: const EdgeInsets.only(left: 10),
                          //   child: GestureDetector(
                          //     onTap: () {
                          //       // Constants.current = "streaming";
                          //       Get.back();
                          //     },
                          //     child: SvgPicture.asset(
                          //       height: isTablet ? 40 : 30,
                          //       width: isTablet ?  40 : 30,
                          //       "images/back.svg",
                          //       colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
                          //     ),
                          //   ),
                          // ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: GestureDetector(
                              onTap: () {
                                Get.back();
                              },
                              child: Container(
                                height: isTablet ? 50 : 40,
                                width: isTablet ? 50 : 40,
                                decoration: const BoxDecoration(
                                  color: Colors.black,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: SvgPicture.asset(
                                    "images/back.svg",
                                    height: isTablet ? 20 : 16,
                                    width: isTablet ? 20 : 16,
                                    colorFilter: const ColorFilter.mode(
                                      Colors.white,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 20),
                            child: Text(
                              selectedEvent?.name.toString() ?? "",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isTablet ? 22 : 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.separated(
                      padding: EdgeInsets.zero,
                      itemCount: liveChannels.length,
                      shrinkWrap: true,
                      physics: const ScrollPhysics(),
                      itemBuilder: (BuildContext context, int index) {
                        Channel channel = liveChannels[index];
                        return GestureDetector(
                          onTap: () {
                            position = index;
                            for (int i = 0; i < liveChannels.length; i++) {
                              if (position == i) {
                                liveChannels[i].sSelected?.value = true;
                              } else {
                                liveChannels[i].sSelected?.value = false;
                              }
                            }
                            if (AppConstants.adLoadStatus.toLowerCase() !=
                                "none") {
                              if (AppConstants.adLoadStatus.toLowerCase() ==
                                  "loaded") {
                                _adManager.checkAdLoadedOrNot(
                                  (value) {
                                    if (value.toLowerCase() == "finish") {
                                      navigateToNextScreen(channel);
                                    }
                                  },
                                  beforeProvider,
                                  "",
                                );
                              } else {
                                navigateToNextScreen(channel);
                              }
                            } else {
                              navigateToNextScreen(channel);
                            }
                          },
                          child: Obx(
                            () => SlideTransition(
                              position: _rightToLeftAnimation,
                            child: Card(
                              color: channel.sSelected!.value
                                  ? Colors.blueAccent.shade700
                                  : const Color(0xff00327a),
                              margin: EdgeInsets.only(
                                left: 10.0,
                                right: 10.0,
                                bottom: 10.0,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: Container(
                                margin: EdgeInsets.all(5.0),

                                child: Row(
                                  children: [
                                    Card(
                                      color: const Color(0xff00327a),
                                      elevation: 10.0,
                                      margin: EdgeInsets.all(5.0),
                                      child: Container(
                                        height: isTablet ? 150 : 120,
                                        width: isTablet ? 150 : 120,
                                        margin: EdgeInsets.all(2.0),
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                            top: 0,
                                          ),
                                          child:
                                          channel.image_url != null
                                              ? Image.network(
                                            height: isTablet ? 150 : 120,
                                            width: isTablet ? 150 : 120,
                                            fit: BoxFit.fill,
                                            channel.image_url.toString(),
                                            loadingBuilder:
                                                (
                                                BuildContext context,
                                                Widget child,
                                                ImageChunkEvent?
                                                loadingProgress,
                                                ) {
                                              if (loadingProgress ==
                                                  null) {
                                                return child; // Return the child widget if loading is complete
                                              }
                                              return Image(
                                                height: isTablet ? 150 : 120,
                                                width: isTablet ? 150 : 120,
                                                fit: BoxFit.fill,
                                                image: const AssetImage(
                                                  "images/placeholder.png",
                                                ),
                                              ); // Return a loading indicator while the image is being loaded
                                            },
                                            errorBuilder:
                                                (
                                                _,
                                                Object exception,
                                                StackTrace? stackTrace,
                                                ) {
                                              return Image.asset(
                                                height: isTablet ? 150 : 120,
                                                width: isTablet ? 150 : 120,
                                                "images/placeholder.png",
                                                fit: BoxFit.fill,
                                              );
                                            },
                                          )
                                              : Image.asset(
                                            height: isTablet ? 150 : 120,
                                            width: isTablet ? 150 : 120,
                                            "images/placeholder.png",
                                            fit: BoxFit.fill,
                                          ),
                                        ),
                                      ),
                                    ),

                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                          top: 5,
                                          bottom: 20,
                                          left: 10,
                                        ),
                                        child: Text(
                                          channel.name?.toString() ?? "",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: isTablet ? 22 : 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),)

                          ),
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) {
                        var t = index % 5;
                        if (t == 2) {
                          if (index == 2) {
                            nativePosition = false;
                          } else {
                            nativePosition = true;
                          }
                        } else {
                          if (index == 1) {
                            nativePosition = true;
                          } else {
                            nativePosition = false;
                          }
                        }

                        if (nativePosition == true) {
                          debugPrint('Native ad ready2 ${AppConstants.nativeAdProvider}');
                          if (AppConstants.nativeAdProvider.toLowerCase() ==
                              AppConstants.admob) {
                          } else if (AppConstants.nativeAdProvider
                                  .toLowerCase() ==
                              AppConstants.facebook) {
                            debugPrint('Native ad ready');
                            return ConstrainedBox(
                              constraints: const BoxConstraints(),
                              child: _facebookNativeAd(),
                            );
                          }

                          if (_admobNativeAd != null) {
                            return Obx(
                              () => Visibility(
                                visible: _nativeAdAdmobValue.value,
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    minWidth: 320,
                                    // minimum recommended width
                                    minHeight: 350,
                                    // minimum recommended height
                                    maxWidth: 400,
                                    maxHeight: 450,
                                  ),
                                  child: AdWidget(ad: _admobNativeAd!),
                                ),
                              ),
                            );
                          } else {
                            return Container();
                          }
                        } else {
                          return ConstrainedBox(
                            constraints: const BoxConstraints(),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void navigateToNextScreen(Channel channel) {
    if (channel.channel_type?.toLowerCase() == AppConstants.flussonicType) {
      if (AppConstants.valueToEncrypt != null) {
        if (AppConstants.valueToEncrypt.isNotEmpty) {
          final key = Key.fromUtf8("Cric${AppConstants.keyFrom}fine");

          final iv = IV.fromUtf8("1234567890123456");
          final encrypter = Encrypter(AES(key));
          final decrypted = encrypter.decrypt64(
            AppConstants.valueToEncrypt,
            iv: iv,
          );
          AppConstants.decryptedKey = decrypted;
        }
      }

      String value2 = DirectPlay.generateUserVal(
        channel.url.toString(),
        "?token=",
        AppConstants.userNetworkIp,
        AppConstants.decryptedKey,
      );
      String linkToPlay = channel.url.toString() + value2;

      ///Initial channel time value from cms....
      if(channel.initial_time!=null) {
        if(channel.initial_time!.isNotEmpty) {
          AppConstants.initialTimerValue = int.parse(channel.initial_time!);
        }
      }
      var channelTimeInMillis =0;

      /// if channel date is not empty.....
      if (channel.date != null) {
        if(channel.date!.isNotEmpty){
          channelTimeInMillis = channelDateToMilliSec(channel.date);
        }
      }

      Get.toNamed(
        Routes.playerScreen,
        arguments: {"url": linkToPlay,"baseUrl":channel.url.toString(), "channelType": AppConstants.flussonicType,
          "timeValue" : channelTimeInMillis},
      )?.then(
        (value) =>
            _streamingController.loadAdAtLocation(AppConstants.locationBefore),
      );


    }
    else if (channel.channel_type?.toLowerCase() == AppConstants.expireFlussonic) {
      if (AppConstants.valueToEncrypt != null) {
        if (AppConstants.valueToEncrypt.isNotEmpty) {
          final key = Key.fromUtf8("Cric${AppConstants.keyFrom}fine");

          final iv = IV.fromUtf8("1234567890123456");
          final encrypter = Encrypter(AES(key));
          final decrypted = encrypter.decrypt64(
            AppConstants.valueToEncrypt,
            iv: iv,
          );
          AppConstants.decryptedKey = decrypted;
        }
      }

      String value2 = DirectPlay.generateUserVal(
        channel.url.toString(),
        "?token=",
        AppConstants.userNetworkIp,
        AppConstants.decryptedKey,
      );
      String linkToPlay = channel.url.toString() + value2;

      ///Initial channel time value from cms....
      if(channel.initial_time!=null) {
        if(channel.initial_time!.isNotEmpty) {
          AppConstants.initialTimerValue = int.parse(channel.initial_time!);
        }
      }
      var channelTimeInMillis =0;

      /// if channel date is not empty.....
      if (channel.date != null) {
        if(channel.date!.isNotEmpty){
          channelTimeInMillis = channelDateToMilliSec(channel.date);
        }
      }

      Get.toNamed(
        Routes.playerScreen,
        arguments: {"url": linkToPlay,"baseUrl":channel.url.toString(), "channelType": AppConstants.expireFlussonic,
          "timeValue" : channelTimeInMillis},
      )?.then(
            (value) =>
            _streamingController.loadAdAtLocation(AppConstants.locationBefore),
      );


    }
    else if (channel.channel_type?.toLowerCase() == AppConstants.playerApp) {
      var timeValueInMillis = 0;
      Get.toNamed(
        Routes.playerScreen,
        arguments: {"url": "","baseUrl":channel.url.toString(), "channelType": AppConstants.playerApp,
          "timeValue" : timeValueInMillis},
      )?.then(
            (value) =>
            _streamingController.loadAdAtLocation(AppConstants.locationBefore),
      );
    }
    else if (channel.channel_type?.toLowerCase() == AppConstants.appTypeApp) {
      String url = channel.url.toString();
      Uri googleUrl = Uri.parse(url);
      openChannelLink(googleUrl);
    }else if (channel.channel_type?.toLowerCase() == AppConstants.simpleFlussonic) {

      ///Initial channel time value from cms....
      if(channel.initial_time!=null) {
        if(channel.initial_time!.isNotEmpty) {
          AppConstants.initialTimerValue = int.parse(channel.initial_time!);
        }
      }
      var channelTimeInMillis =0;

      /// if channel date is not empty.....
      if (channel.date != null) {
        if(channel.date!.isNotEmpty){
          channelTimeInMillis = channelDateToMilliSec(channel.date);
        }
      }
      Get.toNamed(
        Routes.playerScreen,
        arguments: {"url": channel.url.toString(),"baseUrl":channel.url.toString(), "channelType": AppConstants.simpleFlussonic,
          "timeValue" : channelTimeInMillis},
      )?.then(
            (value) =>
            _streamingController.loadAdAtLocation(AppConstants.locationBefore),
      );
    }else if (channel.channel_type?.toLowerCase() == AppConstants.referer) {

      ///Initial channel time value from cms....
      if(channel.initial_time!=null) {
        if(channel.initial_time!.isNotEmpty) {
          AppConstants.initialTimerValue = int.parse(channel.initial_time!);
        }
      }
      var channelTimeInMillis =0;

      /// if channel date is not empty.....
      if (channel.date != null) {
        if(channel.date!.isNotEmpty){
          channelTimeInMillis = channelDateToMilliSec(channel.date);
        }
      }

      final configs = channel?.channel_configurations; // Or channel_configurations based on your class model

      if (configs != null && configs.isNotEmpty) {
        for (var config in configs) {
          if (config?.key != null && config!.key!.isNotEmpty &&
              config.value != null && config.value!.isNotEmpty) {

            // Case-insensitive check equivalent to .equals("referer", true)
            if (config.key!.toLowerCase() == 'referer') {
              AppConstants.refererValue = config.value.toString();
            }
          }
        }
      }

      Get.toNamed(
        Routes.playerScreen,
        arguments: {"url": channel.url.toString(),"baseUrl":channel.url.toString(), "channelType": AppConstants.referer,
          "timeValue" : channelTimeInMillis},
      )?.then(
            (value) =>
            _streamingController.loadAdAtLocation(AppConstants.locationBefore),
      );
    }
  }

  int channelDateToMilliSec(String? channelDate) {
    try {
      if (channelDate == null) {
        return 0;
      }
      final format = DateFormat("yyyy/MM/dd HH:mm");
      final DateTime utcDateTime = format.parseUtc(channelDate);
      final DateTime localDateTime = utcDateTime.toLocal();
      return localDateTime.millisecondsSinceEpoch;
    } catch (e) {
      return 0;
    }
  }


  void openChannelLink(Uri url) async {
    try{
      if (url.isScheme('http') || url.isScheme('https')) {
        if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
          throw Exception('Could not launch $url');
        }
      }
    }
    catch(e){
      debugPrint("Exception ${e}");
    }

  }

  Widget _facebookNativeAd() {
    return fan.NativeAd(
      placementId: AppConstants.facebookNative,
      adType: fan.NativeAdType.NATIVE_AD_VERTICAL,
      width: double.infinity,
      height: 300,
      backgroundColor: Colors.blue,
      titleColor: Colors.white,
      descriptionColor: Colors.white,
      buttonColor: Colors.deepPurple,
      buttonTitleColor: Colors.white,
      buttonBorderColor: Colors.white,
      listener: fan.NativeAdListener(
        onError: (code, message) =>
            print('native ad error\ncode: $code\nmessage:$message'),
        onLoaded: () => print('native ad loaded'),
        onMediaDownloaded: () => 'native ad media downloaded',
      ),
      keepExpandedWhileLoading: true,
      expandAnimationDuraion: 1000,
    );
    //   FacebookNativeAd(
    //   placementId: AppConstants.facebookNative,
    //   adType: NativeAdType.NATIVE_AD_VERTICAL,
    //   width: double.infinity,
    //   height: 300,
    //   backgroundColor: Colors.blue,
    //   titleColor: Colors.white,
    //   descriptionColor: Colors.white,
    //   buttonColor: Colors.deepPurple,
    //   buttonTitleColor: Colors.white,
    //   buttonBorderColor: Colors.white,
    //   listener: (result, value) {},
    //   keepExpandedWhileLoading: true,
    //   expandAnimationDuraion: 1000,
    // );
  }

  void admobNativeAd() {
    final String adId = Platform.isAndroid
        ? AppConstants.admobNative
        : AppConstants.admobNative;
    _admobNativeAd = NativeAd(
      adUnitId: adId,
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          _nativeAdAdmobValue.value = true;
        },
        onAdFailedToLoad: (ad, error) {
          _nativeAdAdmobValue.value = false;
          ad.dispose();
        },
      ),
      request: const AdRequest(),
      // Styling
      nativeTemplateStyle: NativeTemplateStyle(
        // Required: Choose a template.
        templateType: TemplateType.medium,
        // Optional: Customize the ad's style.
        mainBackgroundColor: Colors.lightBlue,
        cornerRadius: 10.0,
        callToActionTextStyle: NativeTemplateTextStyle(
          textColor: Colors.cyan,
          backgroundColor: Colors.red,
          style: NativeTemplateFontStyle.monospace,
          size: 16.0,
        ),
        primaryTextStyle: NativeTemplateTextStyle(
          textColor: Colors.red,
          backgroundColor: Colors.cyan,
          style: NativeTemplateFontStyle.italic,
          size: 16.0,
        ),
        secondaryTextStyle: NativeTemplateTextStyle(
          textColor: Colors.green,
          backgroundColor: Colors.black,
          style: NativeTemplateFontStyle.bold,
          size: 16.0,
        ),
        tertiaryTextStyle: NativeTemplateTextStyle(
          textColor: Colors.brown,
          backgroundColor: Colors.amber,
          style: NativeTemplateFontStyle.normal,
          size: 16.0,
        ),
      ),
    )..load();
  }
}

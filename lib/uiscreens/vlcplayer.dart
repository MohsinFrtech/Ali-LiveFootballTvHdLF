import 'dart:async';
import 'dart:io';
import 'package:auto_orientation_v2/auto_orientation_v2.dart';
import 'package:clever_ads_solutions/clever_ads_solutions.dart' as cas;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_timer_countdown/flutter_timer_countdown.dart';
import 'package:footscore/admanager/addata.dart';
import 'package:footscore/codeutils/appconstants.dart';
import 'package:footscore/viewmodels/streamcontroller.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:audience_network/audience_network.dart' as fan;

import '../codeutils/directplay.dart';

class VlcPlayerClass extends StatefulWidget {
  const VlcPlayerClass({super.key});

  @override
  State<VlcPlayerClass> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<VlcPlayerClass>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  String? channel_url = Get.arguments?['url'];
  String? channelType = Get.arguments?['channelType'];

  String finalUrlToPlay = "";
  Rx<bool> lockScreen = Rx(true);
  Rx<BoxFit> fitValue = Rx(BoxFit.fill);
  Rx<bool> boxVisible = Rx(false);
  RxString valueConfi = RxString("fill");
  var counter = 0;
  final StreamingApiController _streamingContrller = Get.find();
  final AdManager _adManager = AdManager();
  BannerAd? _bannerAdPermanent;
  BannerAd? _bannerAdBottom;
  BannerAd? _bannerAdTop;
  bool _hasExpiry = false;

  final RxBool _bannerAdPermanentValue = RxBool(false);
  final RxBool _facebookBannerPermanent = RxBool(false);
  final RxBool _bannerAdBottomValue = RxBool(false);
  final RxBool _bannerAdTopValue = RxBool(false);

  final RxBool _facebookBannerBottom = RxBool(false);
  final RxBool _facebookBannerTop = RxBool(false);

  final RxBool _showIndicator = RxBool(false);
  final RxBool _isStuck = RxBool(true);

  final RxBool _lockValue = RxBool(true);
  final RxBool _bannerCasiAiTopPermanent = RxBool(false);
  final RxBool _bannerCasiAiBottom = RxBool(false);
  final RxBool _bannerCasiAiOnlyTop = RxBool(false);

  String locationAfterProvider = "none";
  Rx<BoxFit> fitValue2 = Rx(BoxFit.none);

  final GlobalKey<cas.BannerWidgetState> _bannerKey = GlobalKey();
  final GlobalKey<cas.BannerWidgetState> _bannerKey2 = GlobalKey();
  final GlobalKey<cas.BannerWidgetState> _bannerKey3 = GlobalKey();
  bool _isPlayingActionTaken = false; // Add this boolean flag
  RxString showTimerScreenOrNot = RxString("player");
  int? channelTimeValueInMillis = Get.arguments?['timeValue'];
  final RxBool showTimerScreen = RxBool(false);
  final RxInt timerHours = RxInt(0);
  final RxInt timerMinutes = RxInt(0);
  final RxInt timerSeconds = RxInt(0);
  RxDouble screenWidth = 0.0.obs;
  RxDouble screenHeight = 0.0.obs;
  MethodChannel? _channel;

  String baseUrl = Get.arguments?['baseUrl'];
  DateTime? _firstErrorTime;
  int _errorCount = 0;
  bool _isShowingErrorDialog = false;
  Key _viewKey = UniqueKey();
  final RxInt _gravityIndex = RxInt(0);
  final RxBool _optionsVisibility = RxBool(true);
  final RxBool _playerConfigDialog = RxBool(false);
  int? _viewId;

  Animation<double>? _pulseAnim;
  AnimationController? _pulseController;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    if (_streamingContrller.initialized) {
      locationAfterProvider = _streamingContrller.loadAdAtLocation(
        AppConstants.locationAfter,
      );

      //check for location permanent.....
      var adProviderPermanent = _streamingContrller.loadAdAtLocation(
        AppConstants.location2TopPermanent,
      );
      if (adProviderPermanent.toLowerCase() != "none") {
        if (adProviderPermanent.toLowerCase() == AppConstants.admob) {
          loadAdmobBannerPermanent();
        } else if (adProviderPermanent.toLowerCase() == AppConstants.facebook) {
          loadFacebookBannerPermanent();
        } else if (adProviderPermanent.toLowerCase() == AppConstants.casai) {
          _bannerCasiAiTopPermanent.value = true;
        }
      }
      var location2Bottom = _streamingContrller.loadAdAtLocation(
        AppConstants.location2Bottom,
      );
      if (location2Bottom.toLowerCase() != "none") {
        if (location2Bottom.toLowerCase() == AppConstants.admob) {
          loadAdmobBannerBottom();
        } else if (location2Bottom.toLowerCase() == AppConstants.facebook) {
          _facebookBannerBottom.value = true;
        } else if (location2Bottom.toLowerCase() == AppConstants.casai) {
          _bannerCasiAiBottom.value = true;
        }
      }

      var location2Top = _streamingContrller.loadAdAtLocation(
        AppConstants.location2Top,
      );
      if (location2Top.toLowerCase() != "none") {
        if (location2Top.toLowerCase() == AppConstants.admob) {
          loadAdmobBannerTop();
        } else if (location2Top.toLowerCase() == AppConstants.facebook) {
          _facebookBannerTop.value = true;
        } else if (location2Top.toLowerCase() == AppConstants.casai) {
          _bannerCasiAiOnlyTop.value = true;
        }
      }
    }

    ///check for player configuration...
    if (AppConstants.playerSplashBelongsCountry) {
      if (AppConstants.playerCheck) {
        if (AppConstants.playerTypeCount > 0) {
          if (AppConstants.actualCountCheck == AppConstants.playerTypeCount) {
            setUpTimerValue();
          } else {
            initializeDialogAndClose();
          }
        } else {
          //show player config...
          initializeDialogAndClose();
        }
      } else {
        setUpTimerValue();
      }
    } else {
      setUpTimerValue();
    }
    liveIconAnimation();
    toggleControllers();
    super.initState();
  }

  void toggleControllers() {
    Future.delayed(const Duration(seconds: 8), () {
      if (mounted) {
        if (_optionsVisibility.value == true) {
          _optionsVisibility.value = false;
        }
      }
    });
  }

  void initializeDialogAndClose() {
    if (AppConstants.playerTypeCount > 0) {
      AppConstants.actualCountCheck++;
    }
    _playerConfigDialog.value = true;
    _showIndicator.value = false;
    _optionsVisibility.value = false;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _viewId != null) {
      // Tell the native player to resume
      MethodChannel('ios_native_video_player_$_viewId').invokeMethod('play');
    }
  }

  void setUpTimerValue() {
    if (channelTimeValueInMillis != null) {
      if (channelTimeValueInMillis! > 0) {
        final (hour, min, sec) = calculateTimeDifference(
          channelTimeValueInMillis!,
        );
        if (hour == 0 && min <= AppConstants.initialTimerValue) {
          /// if hour is 0 and match minutes is less than from cms value .... setupplayer()....
          playFlussonicChannel();
        } else {
          if (AppConstants.initialTimerValue >= 60) {
            /// if timer is greater than 60 means one hour....
            final int convertedHour = AppConstants.initialTimerValue ~/ 60;
            final int convertedMinutes = AppConstants.initialTimerValue % 60;
            if (hour <= convertedHour) {
              if (hour == convertedHour) {
                if (min <= convertedMinutes) {
                  playFlussonicChannel();
                } else {
                  var minDiff = min - convertedMinutes;

                  ///means timer remaining....
                  showTimerScreen.value = true;
                  timerHours.value = 0;
                  timerMinutes.value = minDiff;
                  timerSeconds.value = sec;
                  showTimerScreenOrNot.value = "timer";
                }
              } else {
                playFlussonicChannel();
              }
            } else {
              ///means timer remaining....
              var hourDiff = hour - convertedHour;
              var minutDiff = 0;
              if (min <= convertedMinutes) {
                minutDiff = convertedMinutes - min;
              } else {
                minutDiff = min - convertedMinutes;
              }

              showTimerScreen.value = true;
              timerHours.value = hourDiff;
              timerMinutes.value = minutDiff;
              timerSeconds.value = sec;
              showTimerScreenOrNot.value = "timer";
            }
          } else {
            if (hour > 0) {
              //show timer.....
              if (min >= 0 && min <= AppConstants.initialTimerValue) {
                var mintDiff = 0;
                var finalHourValue = 0;
                var hoursInMin = hour * 60;
                if (hoursInMin <= 60) {
                  finalHourValue = 0;
                  mintDiff = (60 - AppConstants.initialTimerValue);
                  mintDiff = mintDiff + min;
                } else {
                  finalHourValue = hoursInMin - AppConstants.initialTimerValue;
                  mintDiff = finalHourValue % 60;
                  finalHourValue = finalHourValue ~/ 60;
                }

                ///means timer remaining....
                showTimerScreen.value = true;
                timerHours.value = finalHourValue;
                timerMinutes.value = mintDiff;
                timerSeconds.value = sec;
                showTimerScreenOrNot.value = "timer";
              } else {
                /// if match minutes greater than initial time....
                var hoursInMin = hour * 60;
                var finalHourValue = hoursInMin ~/ 60;
                var finalMin = min - AppConstants.initialTimerValue;

                ///means timer remaining....
                showTimerScreen.value = true;
                timerHours.value = finalHourValue;
                timerMinutes.value = finalMin;
                timerSeconds.value = sec;
                showTimerScreenOrNot.value = "timer";
              }
            } else {
              if (hour == 0 && min <= AppConstants.initialTimerValue) {
                playFlussonicChannel();
              } else {
                var mintDiff = 0;
                if (min <= AppConstants.initialTimerValue) {
                  mintDiff = AppConstants.initialTimerValue - min;
                } else {
                  mintDiff = min - AppConstants.initialTimerValue;
                }

                ///means timer remaining....
                showTimerScreen.value = true;
                timerHours.value = hour;
                timerMinutes.value = mintDiff;
                timerSeconds.value = sec;
                showTimerScreenOrNot.value = "timer";
              }
            }
          }
        }
      } else {
        playFlussonicChannel();
      }
    } else {
      playFlussonicChannel();
    }
  }

  ///calculate time difference...
  (int, int, int) calculateTimeDifference(int timeValueCms) {
    final currentDate = DateTime.now();
    final DateTime channelDateTime = DateTime.fromMillisecondsSinceEpoch(
      timeValueCms,
    );
    final Duration different = currentDate.difference(channelDateTime);
    if (different.isNegative) {
      // Use the 'abs()' method to get a positive duration for calculation.
      final Duration positiveDifferent = different.abs();

      // Extract the individual time components from the Duration object.
      final int elapsedDays = positiveDifferent.inDays;
      final int elapsedHours = positiveDifferent.inHours % 24;
      final int elapsedMinutes = positiveDifferent.inMinutes % 60;
      final int elapsedSeconds = positiveDifferent.inSeconds % 60;

      // You can now use these variables as needed.
      debugPrint(
        'Time until channelDate: $elapsedDays days, $elapsedHours hours, $elapsedMinutes minutes, and $elapsedSeconds seconds',
      );

      return (elapsedHours, elapsedMinutes, elapsedSeconds);
    } else {
      return (0, 0, 0);
    }
  }

  //Setup flussonic channel....
  void playFlussonicChannel() {
    if (channelType == AppConstants.flussonicType) {
      if (channel_url?.toString() != "none") {
        finalUrlToPlay = channel_url.toString();
        _hasExpiry = false;
        setUpPlayer();
      }
    } else if (channelType == AppConstants.expireFlussonic) {
      finalUrlToPlay = channel_url.toString();
      _hasExpiry = true;
    } else if (channelType == AppConstants.playerApp) {
      _hasExpiry = false;
      showPlayerTypeDialog();
    }else if (channelType == AppConstants.referer) {
      finalUrlToPlay = channel_url.toString();
      _hasExpiry = false;
    }
  }

  void showPlayerTypeDialog() {
    AppConstants.playerButtonText = "Install";
    AppConstants.playerDes =
        "Streaming player is not available to play the streaming , please install the player.";
    AppConstants.playerTypeLink = baseUrl;
    _playerConfigDialog.value = true;
    _showIndicator.value = false;
    _optionsVisibility.value = false;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    var textTheme = Theme.of(context).textTheme;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return WillPopScope(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            Obx(
              () => showTimerScreenOrNot.value == "player"
                  ? Center(
                      child: Container(
                        width: size.width,
                        height: isLandscape ? size.height : 250,
                        child: buildNativePlayer(),
                      ),
                    )
                  : Container(),
            ),
            OrientationBuilder(
              builder: (context, orientaion) {
                if (orientaion == Orientation.landscape) {
                  // In landscape, enter immersive mode and lock to landscape
                  return Obx(
                    () => showTimerScreenOrNot.value == "player"
                        ? Stack(
                            children: [
                                 if (_bannerAdTop != null)
                                Obx(
                                      () => Visibility(
                                    visible: _bannerAdTopValue.value,
                                    child: bannerAdTopAdmob(
                                      _bannerAdTop!,
                                      Alignment.topRight,
                                    ),
                                  ),
                                ),
                              // Obx(
                              //       () => Visibility(
                              //     visible: _facebookBannerTop.value,
                              //     child: Positioned(
                              //       top: 10,
                              //       right: 10,
                              //       child: Container(
                              //         height: 50,
                              //         width: 320,
                              //         alignment: Alignment(0.5, 1),
                              //         //
                              //         child: fan.BannerAd(
                              //           placementId:
                              //           AppConstants.facebookBanner,
                              //           bannerSize: fan.BannerSize.STANDARD,
                              //           listener: fan.BannerAdListener(
                              //             onError: (code, message) => {
                              //               _facebookBannerTop.value = false,
                              //               print(
                              //                 'banner ad error\ncode: $code\nmessage:$message',
                              //               ),
                              //             },
                              //             onLoaded: () => {
                              //               _facebookBannerTop.value = true,
                              //               print('banner ad loaded'),
                              //             },
                              //           ),
                              //         ),
                              //       ),
                              //     ),
                              //   ),
                              // ),
                              Visibility(
                                visible: _optionsVisibility.value,
                                child: Positioned(
                                  bottom: 45,
                                  left: 15,
                                  // Added a little padding from the screen edges
                                  right: 15,
                                  child: Visibility(
                                    visible: _optionsVisibility.value,
                                    child: Row(
                                      // Changed Column to Row for side-by-side layout
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        // Left Side: Takes up equal half
                                        Expanded(
                                          child: _LiveBadge(
                                            pulseAnim: _pulseAnim!,
                                          ),
                                        ),

                                        // Right Side: Takes up equal half
                                        Expanded(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              IconButton(
                                                icon: Icon(
                                                  // Dynamically change the icon based on the current state
                                                  _gravityIndex == 0
                                                      ? Icons.aspect_ratio
                                                      : _gravityIndex == 1
                                                      ? Icons
                                                            .fit_screen_outlined
                                                      : Icons.fit_screen,
                                                  color: Colors.white,
                                                  size: 30,
                                                ),
                                                onPressed: () async {
                                                  _gravityIndex.value =
                                                      (_gravityIndex.value +
                                                          1) %
                                                      3;

                                                  // Map the index number to the corresponding string token your iOS Swift code expects
                                                  String mode;
                                                  if (_gravityIndex == 0) {
                                                    mode =
                                                        'stretch'; // Maps to native .resize
                                                  } else if (_gravityIndex ==
                                                      1) {
                                                    mode =
                                                        'fill'; // Maps to native .resizeAspectFill
                                                  } else {
                                                    mode =
                                                        'fit'; // Maps to native .resizeAspect
                                                  }

                                                  try {
                                                    // Fire the message down to your iOS native layer
                                                    await _channel
                                                        ?.invokeMethod(
                                                          'setVideoGravity',
                                                          mode,
                                                        );
                                                  } catch (e) {
                                                    print(
                                                      "Failed to change native video aspect ratio: $e",
                                                    );
                                                  }
                                                },
                                              ),
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.fullscreen_exit,
                                                  color: Colors.white,
                                                  size: 30,
                                                ),
                                                onPressed: () {
                                                  bool isPortrait =
                                                      MediaQuery.of(
                                                        context,
                                                      ).orientation ==
                                                      Orientation.portrait;
                                                  if (isPortrait) {
                                                    AutoOrientation.landscapeAutoMode();
                                                  } else {
                                                    AutoOrientation.portraitAutoMode();
                                                  }
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 40,
                                left: 20,
                                child: GestureDetector(
                                  onTap: () {
                                    SystemChrome.setEnabledSystemUIMode(
                                      SystemUiMode.manual,
                                      overlays: SystemUiOverlay.values,
                                    );

                                    disposePlayerAndResources();

                                    if (AppConstants.adLoadStatus
                                            .toLowerCase() !=
                                        "none") {
                                      if (AppConstants.adLoadStatus
                                              .toLowerCase() ==
                                          "loaded") {
                                        _adManager.checkAdLoadedOrNot(
                                          (value) {
                                            if (value.toLowerCase() ==
                                                "finish") {
                                              Get.back();
                                            }
                                          },
                                          locationAfterProvider,
                                          AppConstants.locationAfter,
                                        );
                                      } else {
                                        Get.back();
                                      }
                                    } else {
                                      Get.back();
                                    }
                                  },
                                  child: SvgPicture.asset(
                                    "images/back.svg",
                                    colorFilter: ColorFilter.mode(
                                      Colors.white,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                ),
                              ),
                              // Obx(
                              //       () => Visibility(
                              //     visible: _bannerCasiAiOnlyTop.value,
                              //     child: Positioned(
                              //       top: 15,
                              //       right: 15,
                              //       child: SizedBox(
                              //         child: _buildBannerAdWidget3(430),
                              //       ),
                              //     ),
                              //   ),
                              // ),
                              // Obx(
                              //       () => Visibility(
                              //     visible: _playerConfigDialog.value,
                              //     child: Container(
                              //       margin: const EdgeInsets.only(top: 20),
                              //
                              //       child: Dialog(
                              //         shape: const RoundedRectangleBorder(
                              //           borderRadius: BorderRadius.all(
                              //             Radius.circular(10.0),
                              //           ),
                              //         ),
                              //         insetPadding: const EdgeInsets.all(10),
                              //         child: SizedBox(
                              //           width: MediaQuery.of(context).size.width,
                              //           child: Column(
                              //             mainAxisSize: MainAxisSize.min,
                              //             children: [
                              //               const SizedBox(height: 20),
                              //               const Padding(
                              //                 padding: EdgeInsets.all(10.0),
                              //                 child: Image(
                              //                   height: 90,
                              //                   width: 90,
                              //                   image: AssetImage(
                              //                     "images/appicon.png",
                              //                   ),
                              //                 ),
                              //               ),
                              //               const SizedBox(height: 5),
                              //               Text(
                              //                 "Player",
                              //                 style: textTheme.titleLarge?.copyWith(
                              //                   color: Colors.black,
                              //                   fontWeight: FontWeight.bold,
                              //                   fontSize: 20,
                              //                 ),
                              //               ),
                              //               const SizedBox(height: 5),
                              //               Padding(
                              //                 padding: const EdgeInsets.only(
                              //                   left: 10.0,
                              //                   right: 10.0,
                              //                 ),
                              //                 child: Text(
                              //                   AppConstants.playerDes,
                              //                   textAlign: TextAlign.center,
                              //                   style: textTheme.titleLarge
                              //                       ?.copyWith(
                              //                     color: Colors.black,
                              //                     fontSize: 17,
                              //                   ),
                              //                 ),
                              //               ),
                              //               const SizedBox(height: 20),
                              //               Row(
                              //                 mainAxisAlignment:
                              //                 MainAxisAlignment.spaceEvenly,
                              //                 children: [
                              //                   Expanded(
                              //                     child: Padding(
                              //                       padding: const EdgeInsets.only(
                              //                         left: 35,
                              //                         right: 35,
                              //                         top: 10.0,
                              //                         bottom: 10.0,
                              //                       ),
                              //                       child: ElevatedButton(
                              //                         style:
                              //                         ElevatedButton.styleFrom(
                              //                           backgroundColor:
                              //                           const Color(
                              //                             0xff40afd1,
                              //                           ),
                              //                         ),
                              //                         onPressed: () {
                              //                           ///
                              //                           Uri googleUrl = Uri.parse(
                              //                             AppConstants
                              //                                 .playerTypeLink,
                              //                           );
                              //                           _launchInBrowserView(
                              //                             googleUrl,
                              //                           );
                              //                         },
                              //                         child: Text(
                              //                           AppConstants
                              //                               .playerButtonText,
                              //                           style: textTheme.bodyLarge
                              //                               ?.copyWith(
                              //                             color: Colors.white,
                              //                             fontWeight:
                              //                             FontWeight.bold,
                              //                           ),
                              //                         ),
                              //                       ),
                              //                     ),
                              //                   ),
                              //                 ],
                              //               ),
                              //               const SizedBox(height: 20),
                              //             ],
                              //           ),
                              //         ),
                              //       ),
                              //     ),
                              //   ),
                              // ),
                            ],
                          )
                        : Visibility(
                            visible: showTimerScreen.value,
                            child: Stack(
                              children: [
                                SizedBox.expand(
                                  child: FittedBox(
                                    fit: fitValue.value,
                                    child: SizedBox(
                                      width: size.width,
                                      height: size.height,
                                      child: const Image(
                                        image: AssetImage(
                                          "images/landscape.png",
                                        ),
                                        fit: BoxFit.fill,
                                        height: double.infinity,
                                      ),
                                    ),
                                  ),
                                ),
                                Center(
                                  child: Obx(
                                    () => TimerCountdown(
                                      timeTextStyle: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                      colonsTextStyle: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      descriptionTextStyle: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      format: CountDownTimerFormat
                                          .hoursMinutesSeconds,
                                      endTime: DateTime.now().add(
                                        Duration(
                                          hours: timerHours.value,
                                          minutes: timerMinutes.value,
                                          seconds: timerSeconds.value,
                                        ),
                                      ),
                                      onTick: (time) {},
                                      onEnd: () {
                                        showTimerScreen.value = false;
                                        playFlussonicChannel();
                                        Future.delayed(
                                          const Duration(milliseconds: 900),
                                          () {
                                            showTimerScreenOrNot.value =
                                                "player";
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 40,
                                  left: 20,
                                  child: GestureDetector(
                                    onTap: () {
                                      SystemChrome.setEnabledSystemUIMode(
                                        SystemUiMode.manual,
                                        overlays: SystemUiOverlay.values,
                                      );

                                      if (AppConstants.adLoadStatus
                                              .toLowerCase() !=
                                          "none") {
                                        if (AppConstants.adLoadStatus
                                                .toLowerCase() ==
                                            "loaded") {
                                          _adManager.checkAdLoadedOrNot(
                                            (value) {
                                              if (value.toLowerCase() ==
                                                  "finish") {
                                                Get.back();
                                              }
                                            },
                                            locationAfterProvider,
                                            AppConstants.locationAfter,
                                          );
                                        } else {
                                          Get.back();
                                        }
                                      } else {
                                        Get.back();
                                      }
                                    },
                                    child: SvgPicture.asset(
                                      "images/back.svg",
                                      colorFilter: ColorFilter.mode(
                                        Colors.white,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                  );
                } else {
                  // In portrait, show a standard, non-immersive view.....
                  return Obx(
                    () => showTimerScreenOrNot.value == "player"
                        ? Stack(
                            children: [

                              orientaion == Orientation.portrait
                                  ? Visibility(
                                      visible: _optionsVisibility.value,
                                      child: Positioned(
                                        bottom: 60,
                                        left: 0,
                                        // Ensure your layout has clear horizontal bounds
                                        right: 10,
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // 1. Wrap the badge in Expanded
                                            Expanded(
                                              child: _LiveBadge(
                                                pulseAnim: _pulseAnim!,
                                              ),
                                            ),

                                            // 2. Wrap the second element in Expanded
                                            Expanded(
                                              child: Row(
                                                // Aligns the icon to the right side of its equal space partition
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  IconButton(
                                                    icon: const Icon(
                                                      Icons.fullscreen,
                                                      color: Colors.white,
                                                      size: 30,
                                                    ),
                                                    onPressed: () async {
                                                      bool isPortrait =
                                                          MediaQuery.of(
                                                            context,
                                                          ).orientation ==
                                                          Orientation.portrait;

                                                      if (isPortrait) {
                                                        // Forces landscape but keeps the hardware sensor listening
                                                        AutoOrientation.landscapeAutoMode();
                                                      } else {
                                                        // Forces portrait but keeps the hardware sensor listening
                                                        AutoOrientation.portraitAutoMode();
                                                      }
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  : Container(),
                              orientaion == Orientation.portrait
                                  ? Positioned(
                                      top: 50,
                                      left: 10,
                                      child: GestureDetector(
                                        onTap: () {
                                          SystemChrome.setEnabledSystemUIMode(
                                            SystemUiMode.manual,
                                            overlays: SystemUiOverlay.values,
                                          );

                                          ///here dispose ...
                                          disposePlayerAndResources();
                                          if (AppConstants.adLoadStatus
                                                  .toLowerCase() !=
                                              "none") {
                                            if (AppConstants.adLoadStatus
                                                    .toLowerCase() ==
                                                "loaded") {
                                              _adManager.checkAdLoadedOrNot(
                                                (value) {
                                                  if (value.toLowerCase() ==
                                                      "finish") {
                                                    Get.back();
                                                  }
                                                },
                                                locationAfterProvider,
                                                AppConstants.locationAfter,
                                              );
                                            } else {
                                              Get.back();
                                            }
                                          } else {
                                            Get.back();
                                          }
                                        },
                                        child: SvgPicture.asset(
                                          "images/back.svg",
                                          colorFilter: ColorFilter.mode(
                                            Colors.white,
                                            BlendMode.srcIn,
                                          ),
                                        ),
                                      ),
                                    )
                                  : Container(),
                              orientaion == Orientation.portrait
                                  ? _bannerAdPermanent != null
                                        ? Obx(
                                            () => Visibility(
                                              visible:
                                                  _bannerAdPermanentValue.value,
                                              child: bannerAdWidgetAdmob(
                                                _bannerAdPermanent!,
                                                Alignment.topRight,
                                              ),
                                            ),
                                          )
                                        : Container()
                                  : Container(),
                              orientaion == Orientation.portrait
                                  ? _bannerAdBottom != null
                                        ? Obx(
                                            () => Visibility(
                                              visible:
                                                  _bannerAdBottomValue.value,
                                              child: bannerAdWidgetAdmobBottom(
                                                _bannerAdBottom!,
                                                Alignment.bottomRight,
                                              ),
                                            ),
                                          )
                                        : Container()
                                  : Container(),
                              Obx(
                                () => Visibility(
                                  visible: _facebookBannerPermanent.value,
                                  child: Positioned(
                                    top: 50,
                                    right: 10,
                                    child: Container(
                                      height: 50,
                                      width: 320,
                                      alignment: Alignment(0.5, 1),
                                      child: fan.BannerAd(
                                        placementId:
                                            AppConstants.facebookBanner,
                                        bannerSize: fan.BannerSize.STANDARD,
                                        listener: fan.BannerAdListener(
                                          onError: (code, message) => {
                                            _facebookBannerPermanent.value =
                                                false,
                                            print(
                                              'banner ad error\ncode: $code\nmessage:$message',
                                            ),
                                          },
                                          onLoaded: () => {
                                            _facebookBannerPermanent.value =
                                                true,
                                            print('banner ad loaded'),
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              orientaion == Orientation.portrait
                                  ? Obx(
                                      () => Visibility(
                                        visible:
                                            _bannerCasiAiTopPermanent.value,
                                        child: Positioned(
                                          top: 140,
                                          right: 10,
                                          child: SizedBox(
                                            width: MediaQuery.of(
                                              context,
                                            ).size.width,
                                            child: _buildBannerAdWidget(
                                              MediaQuery.of(context).size.width,
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  : Container(),
                              Obx(
                                () => Visibility(
                                  visible: _facebookBannerBottom.value,
                                  child: Positioned(
                                    bottom: 170,
                                    right: 10,
                                    child: Container(
                                      height: 50,
                                      width: 320,
                                      alignment: Alignment(0.5, 1),
                                      child: fan.BannerAd(
                                        placementId:
                                            AppConstants.facebookBanner,
                                        bannerSize: fan.BannerSize.STANDARD,
                                        listener: fan.BannerAdListener(
                                          onError: (code, message) => {
                                            _facebookBannerBottom.value = false,
                                            print(
                                              'banner ad error\ncode: $code\nmessage:$message',
                                            ),
                                          },
                                          onLoaded: () => {
                                            _facebookBannerBottom.value = true,
                                            print('banner ad loaded'),
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              orientaion == Orientation.portrait
                                  ? Obx(
                                      () => Visibility(
                                        visible: _bannerCasiAiBottom.value,
                                        child: Positioned(
                                          bottom: 170,
                                          right: 10,
                                          child: SizedBox(
                                            width: MediaQuery.of(
                                              context,
                                            ).size.width,
                                            child: _buildBannerAdWidget2(
                                              MediaQuery.of(context).size.width,
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  : Container(),
                              Obx(
                                () => Visibility(
                                  visible: _playerConfigDialog.value,
                                  child: Container(
                                    margin: const EdgeInsets.only(top: 100),
                                    // color: Color(0xff2e3c58)
                                    //     .withValues(alpha: 0.5),
                                    child: Dialog(
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(10.0),
                                        ),
                                      ),
                                      insetPadding: const EdgeInsets.all(10),
                                      child: SizedBox(
                                        width: MediaQuery.of(
                                          context,
                                        ).size.width,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const SizedBox(height: 20),
                                            const Padding(
                                              padding: EdgeInsets.all(10.0),
                                              child: Image(
                                                height: 90,
                                                width: 90,
                                                image: AssetImage(
                                                  "images/appicon.png",
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            Text(
                                              "Player",
                                              style: textTheme.titleLarge
                                                  ?.copyWith(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 20,
                                                  ),
                                            ),
                                            const SizedBox(height: 20),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                left: 10.0,
                                                right: 10.0,
                                              ),
                                              child: Text(
                                                AppConstants.playerDes,
                                                textAlign: TextAlign.center,
                                                style: textTheme.titleLarge
                                                    ?.copyWith(
                                                      color: Colors.black,
                                                      fontSize: 17,
                                                    ),
                                              ),
                                            ),
                                            const SizedBox(height: 20),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Expanded(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                          left: 35,
                                                          right: 35,
                                                          top: 10.0,
                                                          bottom: 10.0,
                                                        ),
                                                    child: ElevatedButton(
                                                      style:
                                                          ElevatedButton.styleFrom(
                                                            backgroundColor:
                                                                const Color(
                                                                  0xff40afd1,
                                                                ),
                                                          ),
                                                      onPressed: () {
                                                        Uri
                                                        googleUrl = Uri.parse(
                                                          AppConstants
                                                              .playerTypeLink,
                                                        );
                                                        _launchInBrowserView(
                                                          googleUrl,
                                                        );
                                                      },
                                                      child: Text(
                                                        AppConstants
                                                            .playerButtonText,
                                                        style: textTheme
                                                            .bodyLarge
                                                            ?.copyWith(
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 20),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Visibility(
                            visible: showTimerScreen.value,
                            child: Stack(
                              children: [
                                const Image(
                                  image: AssetImage("images/portrait.png"),
                                  fit: BoxFit.fill,
                                  height: double.infinity,
                                ),
                                Center(
                                  child: Obx(
                                    () => TimerCountdown(
                                      timeTextStyle: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                      colonsTextStyle: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      descriptionTextStyle: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      format: CountDownTimerFormat
                                          .hoursMinutesSeconds,
                                      endTime: DateTime.now().add(
                                        Duration(
                                          hours: timerHours.value,
                                          minutes: timerMinutes.value,
                                          seconds: timerSeconds.value,
                                        ),
                                      ),
                                      onTick: (time) {
                                        // Here in timer....
                                      },
                                      onEnd: () {
                                        showTimerScreen.value = false;
                                        playFlussonicChannel();
                                        Future.delayed(
                                          const Duration(milliseconds: 900),
                                          () {
                                            showTimerScreenOrNot.value =
                                                "player";
                                          },
                                        );
                                        debugPrint("Timer finished");
                                      },
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 50,
                                  left: 10,
                                  child: GestureDetector(
                                    onTap: () {
                                      SystemChrome.setEnabledSystemUIMode(
                                        SystemUiMode.manual,
                                        overlays: SystemUiOverlay.values,
                                      );
                                      try {
                                        if (AppConstants.adLoadStatus
                                                .toLowerCase() !=
                                            "none") {
                                          if (AppConstants.adLoadStatus
                                                  .toLowerCase() ==
                                              "loaded") {
                                            _adManager.checkAdLoadedOrNot(
                                              (value) {
                                                debugPrint("valuefinish");
                                                if (value.toLowerCase() ==
                                                    "finish") {
                                                  Get.back();
                                                }
                                              },
                                              locationAfterProvider,
                                              AppConstants.locationAfter,
                                            );
                                          } else {
                                            Get.back();
                                          }
                                        } else {
                                          Get.back();
                                        }
                                      } catch (e) {
                                        debugPrint("Exception");
                                      }
                                    },
                                    child: SvgPicture.asset(
                                      "images/back.svg",
                                      colorFilter: ColorFilter.mode(
                                        Colors.white,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                  ),
                                ),
                                orientaion == Orientation.portrait
                                    ? _bannerAdPermanent != null
                                          ? Obx(
                                              () => Visibility(
                                                visible: _bannerAdPermanentValue
                                                    .value,
                                                child: bannerAdWidgetAdmob(
                                                  _bannerAdPermanent!,
                                                  Alignment.topRight,
                                                ),
                                              ),
                                            )
                                          : Container()
                                    : Container(),
                                orientaion == Orientation.portrait
                                    ? Obx(
                                        () => Visibility(
                                          visible:
                                              _bannerCasiAiTopPermanent.value,
                                          child: Positioned(
                                            top: 80,
                                            right: 10,
                                            child: SizedBox(
                                              width: MediaQuery.of(
                                                context,
                                              ).size.width,
                                              child: _buildBannerAdWidget(
                                                MediaQuery.of(
                                                  context,
                                                ).size.width,
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                    : Container(),
                              ],
                            ),
                          ),
                  );
                }
              },
            ),
            isLandscape
                ?
            Obx(
                  () => showTimerScreenOrNot.value == "player"
                  ?
              Visibility(
                visible: _facebookBannerTop.value,
                child: Positioned(
                  top: 10,
                  right: 140,
                  child: Container(
                    height: 50,
                    width: 320,
                    alignment: Alignment(0.5, 1),
                    //
                    child: fan.BannerAd(
                      placementId:
                      AppConstants.facebookBanner,
                      bannerSize: fan.BannerSize.STANDARD,
                      listener: fan.BannerAdListener(
                        onError: (code, message) => {
                          _facebookBannerTop.value = false,
                          print(
                            'banner ad error\ncode: $code\nmessage:$message',
                          ),
                        },
                        onLoaded: () => {
                          _facebookBannerTop.value = true,
                          print('banner ad loaded'),
                        },
                      ),
                    ),
                  ),
                ),
              ):Container(),
            ):Container(),
            isLandscape
                ? Obx(
                  () => showTimerScreenOrNot.value == "player"
                  ?
              Visibility(
                visible: _bannerCasiAiOnlyTop.value,
                child: Positioned(
                  top: 10,
                  right: 140,
                  child: SizedBox(child: _buildBannerAdWidget3(430)),
                ),
              ):Container(),
            )
                : Container(),
            isLandscape
                ? Obx(
                  () => showTimerScreenOrNot.value == "player"
                  ?
              Visibility(
                visible: _playerConfigDialog.value,
                child: Container(
                  margin: const EdgeInsets.only(top: 20),

                  child: Dialog(
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(10.0),
                      ),
                    ),
                    insetPadding: const EdgeInsets.all(10),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 20),
                          const Padding(
                            padding: EdgeInsets.all(10.0),
                            child: Image(
                              height: 90,
                              width: 90,
                              image: AssetImage("images/appicon.png"),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            "Player",
                            style: textTheme.titleLarge?.copyWith(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 10.0,
                              right: 10.0,
                            ),
                            child: Text(
                              AppConstants.playerDes,
                              textAlign: TextAlign.center,
                              style: textTheme.titleLarge?.copyWith(
                                color: Colors.black,
                                fontSize: 17,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    left: 35,
                                    right: 35,
                                    top: 10.0,
                                    bottom: 10.0,
                                  ),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(
                                        0xff40afd1,
                                      ),
                                    ),
                                    onPressed: () {
                                      ///
                                      Uri googleUrl = Uri.parse(
                                        AppConstants.playerTypeLink,
                                      );
                                      _launchInBrowserView(googleUrl);
                                    },
                                    child: Text(
                                      AppConstants.playerButtonText,
                                      style: textTheme.bodyLarge
                                          ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ):Container(),
            ) : Container(),
            GestureDetector(
              child: Container(
                margin: EdgeInsets.only(top: 120.0, bottom: 100.0),
                color: Colors.transparent,
                width: size.width,
                height: size.height,
              ),
              onTap: () {
                if (_optionsVisibility.value == true) {
                  _optionsVisibility.value = false;
                } else {
                  _optionsVisibility.value = true;
                  toggleControllersAgain();
                }
              },
            ),
            Obx(()=> showTimerScreenOrNot.value == "player" ?
            Positioned(
              top: isLandscape ? 30 : 90,
              right:isLandscape ?15: 5,
              child: IconButton(
                icon: const Icon(
                  Icons
                      .tv, // Or your preferred casting asset icon
                  color: Colors.white,
                  size: 25,
                ),
                onPressed: () async {
                  try {
                    // Replace with your active dynamic viewId reference matching the channel setup
                    try {
                      // Fire the message down to your iOS native layer
                      await _channel?.invokeMethod(
                        'triggerAirPlay',
                      );
                    } catch (e) {
                      print(
                        "Failed to change native video aspect ratio: $e",
                      );
                    }
                  } catch (e) {
                    print(
                      "Failed to launch Safari-style AirPlay overlay: $e",
                    );
                  }
                },
              ),
            ):Container(),
            )
          ],
        ),
      ),
      onWillPop: () {
        SystemChrome.setEnabledSystemUIMode(
          SystemUiMode.manual,
          overlays: SystemUiOverlay.values,
        );
        disposePlayerAndResources();
        if (AppConstants.adLoadStatus.toLowerCase() != "none") {
          if (AppConstants.adLoadStatus.toLowerCase() == "loaded") {
            _adManager.checkAdLoadedOrNot(
              (value) {
                if (value.toLowerCase() == "finish") {
                  Get.back();
                }
              },
              locationAfterProvider,
              AppConstants.locationAfter,
            );
          } else {
            Get.back();
          }
        } else {
          Get.back();
        }

        //we need to return a future
        return Future.value(false);
      },
    );
  }

  String viewType = "ios_native_video_player";

  Widget buildNativePlayer() {
    if (_hasExpiry) {
      viewType = "ios_advanced_video_player";
    } else {
      viewType = "ios_native_video_player";
    }
    return UiKitView(
      key: _viewKey,
      viewType: viewType,
      creationParams: {"url": finalUrlToPlay,
        "referer": AppConstants.refererValue ?? "",
      },
      creationParamsCodec: const StandardMessageCodec(),
      onPlatformViewCreated: (int id) {
        _viewId = id;
        if (_hasExpiry) {
          _channel = MethodChannel('ios_advanced_video_player_$id');
        } else {
          _channel = MethodChannel('ios_native_video_player_$id');
        }

        // testExpiryLogic();

        _channel?.setMethodCallHandler((call) async {
          switch (call.method) {
            case "requestExpiryExtraction":
              if (_hasExpiry) {
                final String? streamUrl = call.arguments["url"];
                if (streamUrl == null) return;
                try {
                  final Dio _dio = Dio();
                  // Use your existing Dio instance here instead of creating a new one
                  final response = await _dio.get(streamUrl);
                  final String content = response.data.toString();

                  final regExp = RegExp(r"exp(?:=|%3D)(\d+)");
                  final match = regExp.firstMatch(content);

                  if (match != null) {
                    double timestamp = double.parse(match.group(1)!);
                    // Inform Native of the expiry timestamp to start the timer
                    debugPrint(
                      "Token expiring or buffer empty. Refreshing... ${timestamp}",
                    );
                    await _channel?.invokeMethod('updateExpiry', {
                      'timestamp': timestamp,
                    });
                  }
                } catch (e) {
                  debugPrint("Background extraction failed: $e");
                  final double fallbackTimestamp =
                      (DateTime.now().millisecondsSinceEpoch / 1000) + 60;

                  // Send this fallback to Native so the timer starts regardless
                  await _channel?.invokeMethod('updateExpiry', {
                    'timestamp': fallbackTimestamp,
                  });
                }
                break;
              } else {
                break;
              }
            case "requestRefresh":
              debugPrint("Token expiring or buffer empty. Refreshing...");
              if (_hasExpiry) {
                _performSmoothRefresh();
                break;
              } else {
                break;
              }
            case "onError":
              debugPrint("Native Error: ${call.arguments}");
              final now = DateTime.now();
              _firstErrorTime ??= now;
              _errorCount++;

              final totalElapsedSeconds = now
                  .difference(_firstErrorTime!)
                  .inSeconds;
              debugPrint(
                "⚠️ Stream error loop count: $_errorCount. Total elapsed time: ${totalElapsedSeconds}s",
              );

              if ((_errorCount >= 60 || totalElapsedSeconds >= 60) &&
                  !_isShowingErrorDialog) {
                debugPrint(
                  "💀 Stream has completely failed for 1 minute. Showing error alert.",
                );
                _channel?.invokeMethod('pause');
                _showDeadStreamDialog();
              } else {
                againSetUpPlayer();
              }
              break;

            case "onStuck":
              debugPrint("Player stuck, handling buffering UI...");
              _performSmoothRefresh();
              break;
          }
        });
      },
    );
  }

  void toggleControllersAgain() {
    Future.delayed(const Duration(seconds: 7), () {
      if (mounted) {
        if (_optionsVisibility.value == true) {
          _optionsVisibility.value = false;
        }
      }
    });
  }

  void _showDeadStreamDialog() {
    setState(() {
      _isShowingErrorDialog = true;
    });

    showDialog(
      context: context,
      barrierDismissible: false, // Force explicit action
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Playback Error"),
          content: const Text(
            "The live stream is currently unavailable or has lost connection. Would you like to try reconnecting?",
          ),
          actions: [
            TextButton(
              child: const Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
                _resetErrorCounters();

                disposePlayerAndResources();
                if (AppConstants.adLoadStatus.toLowerCase() != "none") {
                  if (AppConstants.adLoadStatus.toLowerCase() == "loaded") {
                    _adManager.checkAdLoadedOrNot(
                      (value) {
                        if (value.toLowerCase() == "finish") {
                          Get.back();
                        }
                      },
                      locationAfterProvider,
                      AppConstants.locationAfter,
                    );
                  } else {
                    Get.back();
                  }
                } else {
                  Get.back();
                }
              },
            ),
            ElevatedButton(
              child: const Text("Retry Connection"),
              onPressed: () {
                Navigator.of(context).pop();
                _resetErrorCounters();

                // Hard restart sequence
                againSetUpPlayer();
              },
            ),
          ],
        );
      },
    );
  }

  void _resetErrorCounters() {
    _firstErrorTime = null;
    _errorCount = 0;
    _isShowingErrorDialog = false;
  }

  Future<void> _performSmoothRefresh() async {
    debugPrint("Pre-emptively refreshing token...");
    try {
      String value2 = DirectPlay.generateUserVal(
        baseUrl,
        "?token=",
        AppConstants.userNetworkIp,
        AppConstants.decryptedKey,
      );
      String finalval = baseUrl + value2;
      finalUrlToPlay = finalval;
      await _channel?.invokeMethod('updateUrl', {'url': finalUrlToPlay,
        'referer': AppConstants.refererValue ?? "",});
    } catch (e) {
      debugPrint("Proactive refresh failed: $e");
    }
  }

  Future<void> _launchInBrowserView(Uri url) async {
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint("Could not launch");
    }
    Get.back();
  }

  Future<void> setUpPlayer() async {
    try {} catch (e) {
      debugPrint("Exceptiontack $e");
    }
  }

  void againSetUpPlayer() {
    Future.delayed(Duration(seconds: 3), () {
      String value2 = DirectPlay.generateUserVal(
        baseUrl,
        "?token=",
        AppConstants.userNetworkIp,
        AppConstants.decryptedKey,
      );
      String finalval = baseUrl + value2;
      finalUrlToPlay = finalval;
      if (!mounted) return;
      setState(() {
        // Changing the Key kills the old iOS view and calls 'init' in Swift again
        _viewKey = UniqueKey();
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Future.delayed(const Duration(seconds: 1), () {
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: [SystemUiOverlay.bottom],
      );
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      // moveToNextScreen();
    });
  }

  Future<void> disposePlayerAndResources() async {
    try {

      if (_channel != null) {
        await _channel?.invokeMethod('pause');   // Stop the sound immediately
        await _channel?.invokeMethod('release'); // Completely destroy the player instance
      }

      // if (_pulseController != null) {
      //   _pulseController?.stop();
      //   _pulseController!.dispose();
      //   _pulseController =
      //       null; // This prevents a second call from doing anything
      // }
    } catch (e) {
      debugPrint("Exception $e");
    }
  }

  final _bannerListener = cas.AdViewListener(
    onAdViewLoaded: () => {},
    onAdViewFailed: (message) => {debugPrint("Banner failed $message")},
    onAdViewClicked: () => {debugPrint("Banner ad loaded!")},
  );

  final cas.OnAdImpressionListener
  _impressionListener = cas.OnAdImpressionListener(
    (ad) async => {
      debugPrint(
        '${await ad.getFormat()} ad impression: ${await ad.getSourceName()}',
      ),
    },
  );

  Widget _buildBannerAdWidget(double maxWidth) {
    return cas.BannerWidget(
      key: _bannerKey,
      casId: AppConstants.casAiId,
      adListener: _bannerListener,
      onImpressionListener: _impressionListener,
      // AdSize.banner by default
      size: cas.AdSize.getAdaptiveBanner(maxWidth),
      // true by default
      isAutoloadEnabled: true,
      // 30 sec by default
      refreshInterval: 30,
    );
  }

  Widget _buildBannerAdWidget2(double maxWidth) {
    return cas.BannerWidget(
      key: _bannerKey2,
      casId: AppConstants.casAiId,
      adListener: _bannerListener,
      onImpressionListener: _impressionListener,
      // AdSize.banner by default
      size: cas.AdSize.getAdaptiveBanner(maxWidth),
      // true by default
      isAutoloadEnabled: true,
      // 30 sec by default
      refreshInterval: 30,
    );
  }

  Widget _buildBannerAdWidget3(double maxWidth) {
    return cas.BannerWidget(
      key: _bannerKey3,
      casId: AppConstants.casAiId,
      adListener: _bannerListener,
      onImpressionListener: _impressionListener,
      // AdSize.banner by default
      size: cas.AdSize.getAdaptiveBanner(maxWidth),
      // true by default
      isAutoloadEnabled: true,
      // 30 sec by default
      refreshInterval: 30,
    );
  }

  @override
  void dispose() {
    try {
      WidgetsBinding.instance.removeObserver(this);
      disposePlayerAndResources();
      if (_pulseController != null) {
        _pulseController?.stop();
        _pulseController!.dispose();
        _pulseController =
        null; // This prevents a second call from doing anything
      }
    } catch (e) {
      debugPrint("Exception $e");
    }
    super.dispose();
  }

  Widget bannerAdWidgetAdmob(BannerAd banner, Alignment position) {
    return StatefulBuilder(
      builder: (context, setState) => Align(
        alignment: position,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (banner != null)
              Padding(
                padding: const EdgeInsets.only(top: 50),
                child: SizedBox(
                  width: banner.size.width.toDouble(),
                  height: banner.size.height.toDouble(),
                  child: AdWidget(ad: banner),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget bannerAdTopAdmob(BannerAd banner, Alignment position) {
    return StatefulBuilder(
      builder: (context, setState) => Align(
        alignment: position,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (banner != null)
              Padding(
                padding: const EdgeInsets.only(top: 5, right: 140),
                child: SizedBox(
                  width: banner.size.width.toDouble(),
                  height: banner.size.height.toDouble(),
                  child: AdWidget(ad: banner),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget bannerAdWidgetAdmobBottom(BannerAd banner, Alignment position) {
    return StatefulBuilder(
      builder: (context, setState) => Align(
        alignment: position,
        child: Padding(
          padding: EdgeInsets.only(bottom: 170),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (banner != null)
                SizedBox(
                  width: banner.size.width.toDouble(),
                  height: banner.size.height.toDouble(),
                  child: AdWidget(ad: banner),
                ),
            ],
          ),
        ),
      ),
    );
  }

  //load admob banner permanent position....
  void loadAdmobBannerPermanent() {
    // Loads a banner ad.
    _bannerAdPermanent = BannerAd(
      adUnitId: AppConstants.admobBanner,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        // Called when an ad is successfully received.
        onAdLoaded: (ad) {
          _bannerAdPermanentValue.value = true;
        },
        // Called when an ad request failed.
        onAdFailedToLoad: (ad, err) {
          _bannerAdPermanentValue.value = false;
          ad.dispose();
        },
      ),
    )..load();
  }

  //load admob banner bottom position
  void loadAdmobBannerBottom() {
    // Loads a banner ad.
    _bannerAdBottom = BannerAd(
      adUnitId: AppConstants.admobBanner,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        // Called when an ad is successfully received.
        onAdLoaded: (ad) {
          _bannerAdBottomValue.value = true;
        },
        // Called when an ad request failed.
        onAdFailedToLoad: (ad, err) {
          _bannerAdBottomValue.value = false;
          // Dispose the ad here to free resources.
          ad.dispose();
        },
      ),
    )..load();
  }

  void loadAdmobBannerTop() {
    // Loads a banner ad.
    _bannerAdTop = BannerAd(
      adUnitId: AppConstants.admobBanner,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        // Called when an ad is successfully received.
        onAdLoaded: (ad) {
          _bannerAdTopValue.value = true;
        },
        // Called when an ad request failed.
        onAdFailedToLoad: (ad, err) {
          _bannerAdTopValue.value = false;
          // Dispose the ad here to free resources.
          ad.dispose();
        },
      ),
    )..load();
  }

  //Load facebook banner permanent...
  void loadFacebookBannerPermanent() {
    _facebookBannerPermanent.value = true;
  }

  void liveIconAnimation() {
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController!, curve: Curves.easeInOut),
    );
  }
}

class _LiveBadge extends StatelessWidget {
  final Animation<double> pulseAnim;

  const _LiveBadge({required this.pulseAnim});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 15),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: pulseAnim,
            builder: (_, __) => Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: Color.lerp(Colors.red, Colors.red, pulseAnim.value),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(
                      0xFFFF3D6B,
                    ).withOpacity(pulseAnim.value * 0.7),
                    blurRadius: 6,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 6),
          const Text(
            'LIVE',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Colors.red,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

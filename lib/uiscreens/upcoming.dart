import 'dart:io';

import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:audience_network/audience_network.dart' as fan;

import '../admanager/addata.dart';
import '../codeutils/appconstants.dart';
import '../datamodels/football.dart';
import '../datamodels/sortedlist.dart';
import '../routing/approutes.dart';
import '../viewmodels/footcontroller.dart';
import '../viewmodels/streamcontroller.dart';

class UpcomingFootballMatches extends StatefulWidget {
  const UpcomingFootballMatches({super.key});

  @override
  State<UpcomingFootballMatches> createState() =>
      _UpcomingFootballMatchesState();
}

class _UpcomingFootballMatchesState extends State<UpcomingFootballMatches> {
  FootballController? footballController;
  String beforeProvider = "none";
  final StreamingApiController apiController = Get.find();
  final AdManager _adManager = AdManager();
  NativeAd? _nativeAd;
  final RxBool _nativeAdAdmobValue = RxBool(false);
  @override
  void initState() {
    bool controllerCheck = Get.isRegistered<FootballController>();
    if (controllerCheck) {
      footballController = Get.find();
    } else {
      footballController = Get.put(FootballController());
    }
    apiController.loadAdAtLocation(
      AppConstants.nativeLocation,
    );
    if (AppConstants.nativeAdProvider.toLowerCase() == AppConstants.admob) {
      loadNativeAd();
    }

    if (apiController.initialized) {
      beforeProvider = apiController.loadAdAtLocation(AppConstants.locationBefore);
    }

    footballController?.upcomingMatches();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    var nativePosition = false;
    bool isTablet = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      backgroundColor: Color(0xff0b3bbf),
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                clipBehavior: Clip.none, // allow shadow to draw outside
                margin: const EdgeInsets.only(bottom: 0.3),
                decoration: const BoxDecoration(
                  color: Color(0xff00327a),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 60.0, bottom: 20.0),
                  child: Row(
                    children: [
                      Spacer(),
                      Text(
                        "Upcoming Matches",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isTablet ? 22 : 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Spacer(),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Text(
                  "Upcoming",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isTablet ? 20 : 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: Obx(
                      () => Visibility(
                    visible: footballController!.showUpcomingMatches.value,
                    child: ListView.separated(
                      padding: EdgeInsets.only(top: 10.0),
                      itemBuilder: (BuildContext context, int index) {
                        SortedFootballClass match =
                        footballController!.upcomingListLeague[index];
                        return Padding(
                          padding: const EdgeInsets.only(
                            left: 10.0,
                            right: 10.0,
                            bottom: 10.0,
                          ),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            color: Colors.white,
                            child: Column(
                              children: [
                                Container(
                                  // decoration: BoxDecoration(
                                  //   color: const Color(0xff00327a),
                                  //   // Set the border radius on the container
                                  //   borderRadius: BorderRadius.circular(10.0),
                                  // ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xff00327a),
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(10.0),
                                      topRight: Radius.circular(10.0),
                                    ),
                                  ),
                                  width: screenSize.width,
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          left: 5.0,
                                          top: 5.0,
                                          bottom: 5.0,
                                        ),
                                        child: Image.network(
                                          match.league.logo?.toString() ??
                                              "",
                                          height: isTablet ? 35 : 25,
                                          width: isTablet ? 35 : 25,
                                          loadingBuilder:
                                              (
                                              BuildContext context,
                                              Widget child,
                                              ImageChunkEvent?
                                              loadingProgress,
                                              ) {
                                            if (loadingProgress == null) {
                                              return child; // Return the child widget if loading is complete
                                            }
                                            return Image(
                                              height: isTablet ? 35 : 25,
                                              width: isTablet ? 35 : 25,
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
                                              height: isTablet ? 35 : 25,
                                              width: isTablet ? 35 : 25,
                                              "images/placeholder.png",
                                              fit: BoxFit.fill,
                                            );
                                          },
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          left: 10.0,
                                        ),
                                        child: Text(
                                          match.league.name ?? "",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: isTablet ? 18 : 13,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                ListView.builder(
                                  padding: EdgeInsets.only(top: 10.0),
                                  itemCount: match.matchesList.length,
                                  shrinkWrap: true,
                                  physics:
                                  const NeverScrollableScrollPhysics(),
                                  itemBuilder: (BuildContext context, int index) {
                                    FootballData footballMatch =
                                    match.matchesList[index];
                                    return InkWell(
                                      child:Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              left: 10.0,
                                              right: 10.0,
                                              bottom: 5.0,
                                            ),
                                            child: Text(
                                              footballMatch.status?.long ?? "",
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: isTablet ? 18 : 13
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              left: 10.0,
                                              bottom: 15.0,
                                            ),
                                            child: Row(
                                              children: [
                                                Image.network(
                                                  footballMatch
                                                      .homeTeam
                                                      ?.logo ??
                                                      "",
                                                  height: isTablet ? 35 : 25,
                                                  width: isTablet ? 35 : 25,
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
                                                      height: isTablet ? 35 : 25,
                                                      width: isTablet ? 35 : 25,
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
                                                      height: isTablet ? 35 : 25,
                                                      width: isTablet ? 35 : 25,
                                                      "images/placeholder.png",
                                                      fit: BoxFit.fill,
                                                    );
                                                  },
                                                ),
                                                Padding(
                                                  padding:
                                                  const EdgeInsets.only(
                                                    left: 10.0,
                                                  ),
                                                  child: Text(
                                                    footballMatch.homeTeam
                                                        ?.name ??
                                                        "",
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                      FontWeight.bold,
                                                      fontSize: isTablet ? 18 : 14,
                                                    ),
                                                  ),
                                                ),
                                                Spacer(flex: 1),
                                                Padding(
                                                  padding:
                                                  const EdgeInsets.only(
                                                    left: 0.0,
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                    const EdgeInsets.only(
                                                      right: 10.0,
                                                    ),
                                                    child: Text(
                                                      footballMatch.goals !=
                                                          null
                                                          ? footballMatch.goals
                                                          ?.home !=
                                                          null
                                                          ? footballMatch
                                                          .goals!
                                                          .home
                                                          .toString()
                                                          : ""
                                                          : "",
                                                      style: TextStyle(
                                                        color: Colors.black,
                                                        fontWeight:
                                                        FontWeight.bold,
                                                        fontSize: isTablet ? 18 : 14,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              left: 10.0,
                                            ),
                                            child: Row(
                                              children: [
                                                Image.network(
                                                  footballMatch
                                                      .awayTeam
                                                      ?.logo ??
                                                      "",
                                                  height: isTablet ? 35 : 25,
                                                  width: isTablet ? 35 : 25,
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
                                                      height: isTablet ? 35 : 25,
                                                      width: isTablet ? 35 : 25,
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
                                                      height: isTablet ? 35 : 25,
                                                      width: isTablet ? 35 : 25,
                                                      "images/placeholder.png",
                                                      fit: BoxFit.fill,
                                                    );
                                                  },
                                                ),
                                                Padding(
                                                  padding:
                                                  const EdgeInsets.only(
                                                    left: 10.0,
                                                  ),
                                                  child: Text(
                                                    footballMatch.awayTeam
                                                        ?.name ??
                                                        "",
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                      FontWeight.bold,
                                                      fontSize: isTablet ? 18 : 14,
                                                    ),
                                                  ),
                                                ),
                                                Spacer(flex: 1),
                                                Padding(
                                                  padding:
                                                  const EdgeInsets.only(
                                                    left: 0.0,
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                    const EdgeInsets.only(
                                                      right: 10.0,
                                                    ),
                                                    child: Text(
                                                      footballMatch.goals !=
                                                          null
                                                          ? footballMatch.goals
                                                          ?.away !=
                                                          null
                                                          ? footballMatch
                                                          .goals!
                                                          .away
                                                          .toString()
                                                          : ""
                                                          : "",
                                                      style: TextStyle(
                                                        color: Colors.black,
                                                        fontWeight:
                                                        FontWeight.bold,
                                                        fontSize: isTablet ? 18 : 14,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              top: 10.0,
                                              right: 10.0,
                                              bottom: 5.0,
                                            ),
                                            child: Row(
                                              children: [
                                                Spacer(flex: 1),
                                                Text(
                                                  footballMatch.venue?.name !=
                                                      null
                                                      ? footballMatch
                                                      .venue!
                                                      .name
                                                      .toString()
                                                      : match.league.round ??
                                                      "",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: isTablet ? 18 : 14,
                                                  ),
                                                ),
                                                Spacer(flex: 1),
                                              ],
                                            ),
                                          ),
                                          index != match.matchesList.length - 1
                                              ? Padding(
                                            padding:
                                            const EdgeInsets.only(
                                              left: 5.0,
                                              right: 5.0,
                                              bottom: 10.0,
                                            ),
                                            child: DottedLine(
                                              direction: Axis.horizontal,
                                              lineThickness: 1.0,
                                              dashLength: 8.0,
                                              dashGapLength: 5.0,
                                              dashColor: Colors.black,
                                            ),
                                          )
                                              : Container(),
                                        ],
                                      ),
                                      onTap: (){
                                        if (AppConstants.adLoadStatus.toLowerCase() !=
                                            "none") {
                                          if (AppConstants.adLoadStatus
                                              .toLowerCase() ==
                                              "loaded") {
                                            _adManager.checkAdLoadedOrNot(
                                                    (value) {
                                                  if (value.toLowerCase() == "finish") {
                                                    navigateToNextScreen(footballMatch);
                                                  }
                                                }, beforeProvider,"");
                                          } else {
                                            navigateToNextScreen(footballMatch);
                                          }
                                        } else {
                                          navigateToNextScreen(footballMatch);
                                        }
                                      },
                                    );
                                  },
                                ),
                              ],
                            ),
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
                          if (AppConstants.nativeAdProvider.toLowerCase() ==
                              AppConstants.admob) {
                          } else if (AppConstants.nativeAdProvider.toLowerCase() ==
                              AppConstants.facebook) {
                            return ConstrainedBox(
                              constraints: const BoxConstraints(),
                              child: _facebookNativeAd(),
                            );
                          }
                          if (_nativeAd != null) {
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
                                  child: AdWidget(ad: _nativeAd!),
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
                      itemCount: footballController!.upcomingListLeague.length,
                      shrinkWrap: true,
                      physics: const AlwaysScrollableScrollPhysics(),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Obx(
            () => Center(
              child: Visibility(
                visible: footballController!.upcomingProgress.value,
                child: const CircularProgressIndicator(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
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
  }

  void loadNativeAd() {
    final String adUnitId =
    Platform.isAndroid ? AppConstants.admobNative : AppConstants.admobNative;
    _nativeAd = NativeAd(
        adUnitId: adUnitId,
        listener: NativeAdListener(
          onAdLoaded: (ad) {
            _nativeAdAdmobValue.value = true;
            debugPrint('Native loaded succes.');
          },
          onAdFailedToLoad: (ad, error) {
            _nativeAdAdmobValue.value = false;
            // Dispose the ad here to free resources.
            debugPrint('$NativeAd failed to load: $error');
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
                size: 16.0),
            primaryTextStyle: NativeTemplateTextStyle(
                textColor: Colors.red,
                backgroundColor: Colors.cyan,
                style: NativeTemplateFontStyle.italic,
                size: 16.0),
            secondaryTextStyle: NativeTemplateTextStyle(
                textColor: Colors.green,
                backgroundColor: Colors.black,
                style: NativeTemplateFontStyle.bold,
                size: 16.0),
            tertiaryTextStyle: NativeTemplateTextStyle(
                textColor: Colors.brown,
                backgroundColor: Colors.amber,
                style: NativeTemplateFontStyle.normal,
                size: 16.0)))
      ..load();
  }

  void navigateToNextScreen(FootballData footballMatch) {
    Get.toNamed(Routes.footballMatchDetail,
        arguments: {"footballMatch": footballMatch})?.then((value) =>
        apiController.loadAdAtLocation(AppConstants.locationBefore)
    );
  }
}

import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/foundation.dart';
import 'package:footscore/codeutils/apidata.dart';
import 'package:footscore/codeutils/appconstants.dart';
import 'package:get/get.dart';
import 'package:encrypt/encrypt.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../admanager/addata.dart';
import '../codeutils/dataparsing.dart';
import '../codeutils/shareddata.dart';
import '../database/databasehelper.dart';
import '../datamodels/StreamingValue.dart';
import '../datamodels/appconfiguration.dart';
import '../datamodels/fav_event_class.dart';
import '../datamodels/streammodel.dart';
import '../files/f1.dart';
import '../files/f10.dart';
import '../files/f11.dart';
import '../files/f12.dart';
import '../files/f13.dart';
import '../files/f14.dart';
import '../files/f15.dart';
import '../files/f16.dart';
import '../files/f17.dart';
import '../files/f18.dart';
import '../files/f19.dart';
import '../files/f2.dart';
import '../files/f20.dart';
import '../files/f21.dart';
import '../files/f22.dart';
import '../files/f23.dart';
import '../files/f24.dart';
import '../files/f25.dart';
import '../files/f3.dart';
import '../files/f4.dart';
import '../files/f5.dart';
import '../files/f6.dart';
import '../files/f7.dart';
import '../files/f8.dart';
import '../files/f9.dart';

class StreamingApiController extends GetxController {
  final Dio _dio = Dio();
  final AdManager _adController = AdManager();

  RxList<EventStreaming> finalEventList = RxList();
  RxBool isLiveEvents = RxBool(false);
  RxBool isAppLive = RxBool(false);
  RxBool isLoadingEvents = RxBool(true);
  RxBool streamingApiError = RxBool(false);
  RxList<FavouriteEvent> favoriteLeagues = RxList();

  String replaceChar = "mint";
  PackageInfo? appInfo;

  String adProvider = "none";
  final RxList<AppAd> adsList = RxList<AppAd>();
  RxBool showAppRatingDialog = RxBool(false);
  SharedPreferenceResource dataResource = SharedPreferenceResource();
  AppConfiguration appConfiguration = AppConfiguration();
  RxBool showSplashConfig = RxBool(false);
  RxBool appUpdateShowOrNot = RxBool(false);
  RxInt splashTimerValue = RxInt(0);
  Rxn<StreamModel> streamModel = Rxn<StreamModel>();

  @override
  void onInit() {
    dataResource.getSharedInstance();
    getAllFavoriteLeagues();
    fetchStreamingApiEvents();
    callIpApi();
    super.onInit();
  }



  Future<void> callIpApi() async {
    try{
      var ipApiResponse = await _dio.get(StreamingApiData.ipApiUrl);
      if (ipApiResponse.statusCode == 200) {
        AppConstants.userNetworkIp = ipApiResponse.data.toString();
      }
    }
    on DioException catch (e){
      debugPrint("Exception $e");
    }

  }

  Future<void> fetchStreamingApiEvents() async {
    try {
      appInfo = await PackageInfo.fromPlatform();
      AppConstants.dynamicBuildNumber = appInfo!.buildNumber;

      var parameterList = {
        "id": StreamingApiData.streamAppId,
        "auth_token": StreamingApiData.streamApiToken,
        "build_no": AppConstants.dynamicBuildNumber,
      };

      var response = await _dio.post(
        StreamingApiData.streamApiBaseUrl,
        options: Options(
          headers: {HttpHeaders.contentTypeHeader: "application/json"},
        ),
        data: parameterList,
      );

      if (response.statusCode == 200) {
        ///////
        var appOpening = dataResource.getOpeningCount();
        if (appOpening == null) {
          dataResource.appOpeningCount(1);
        } else {
          int? x = dataResource.getOpeningCount();
          x = (x! + 1);
          dataResource.appOpeningCount(x);
        }

        var results = StreamingValueModel.fromJson(response.data);
        String? decryptVal;
        final seperationBasedOnLetter = results.data.split('_____');

        if (seperationBasedOnLetter != null &&
            seperationBasedOnLetter.isNotEmpty) {
          decryptVal = decryptData(seperationBasedOnLetter.last);
        }
        if(decryptVal!=null && decryptVal.isNotEmpty){
          streamingApiError.value = false;
          accessFilesAndData(seperationBasedOnLetter.first, decryptVal!);
        }
        else{
          streamingApiError.value = true;
        }
      }
    } on DioException catch (e) {
      isAppLive.value = false;
      isLoadingEvents.value = false;
      streamingApiError.value = true;
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
      } else if (e.type == DioExceptionType.connectionError &&
          e.error is SocketException) {
      } else {
        debugPrint("Unhandled Dio error: ${e.message}");
      }
    }
  }

  int? fullSize;

  (List<String>, List<String>, List<String>) arraySeperation(
    String valueParams,
  ) {
    final myValue = valueParams;
    final mainArray = myValue.split('');
    final mainArraySize = mainArray.length;
    fullSize = mainArraySize;

    // Calculate split points using integer division.
    final splitPoint1 = (mainArraySize + 1) ~/ 3;

    // Perform slicing using sublist().
    final array1 = mainArray.sublist(0, splitPoint1);
    final arr2 = mainArray.sublist(splitPoint1);
    final array2 = arr2.sublist(0, (arr2.length + 1) ~/ 2);
    final array3 = arr2.sublist((arr2.length + 1) ~/ 2);

    return (array1, array2, array3);
  }

  Future<void> accessFilesAndData(String? org, String fitX) async {
    try {
      var appBelongsCountry = true;

      var ml1 = StringBuffer();
      String sendValue = fitX;
      int addValue = 0;
      final (array1, _, array3) = arraySeperation(sendValue);

      for (int a1 = 0; a1 < array3.length; a1++) {
        final fileNumberString = array1[a1];
        final stringToPickString = array1[a1];

        addValue += 3;

        final fileNumber = int.tryParse(fileNumberString);
        final stringToPick = int.tryParse(stringToPickString);
        final array3Value = int.tryParse(array3[a1]);

        if (fileNumber != null &&
            stringToPick != null &&
            array3Value != null &&
            fileNumber >= 1 &&
            fileNumber <= 39 &&
            stringToPick >= 0 &&
            stringToPick <= 9 &&
            array3Value >= 0 &&
            array3Value <= 9) {
          final finalX = addValue + array3Value;

          if (finalX >= 0 && finalX <= 39) {
            final numberFile = getFiles(fileNumber);
            final indexValueWithInFile = numberFile?[stringToPick];

            if (indexValueWithInFile != null &&
                finalX < indexValueWithInFile.length) {
              final finalVal = indexValueWithInFile[finalX];
              ml1.write(finalVal);
            }
          }
        }
      }

      var decryptValue = parseData(org!, ml1.toString());

      if (decryptValue != null) {
        Map<String, dynamic> data = jsonDecode(decryptValue);
        var againProcessing = await compute(
          (message) => StreamModel.fromJson(message),
          data,
        );

        if (againProcessing != null) {
          streamModel.value = againProcessing;

          // To check application configuration....
          if (againProcessing.application_configurations != null) {
            if (againProcessing.application_configurations!.isNotEmpty) {
              applicationConfiguration(
                againProcessing.application_configurations,
                againProcessing,
              );
            }
          }

          //To check ads.....
          if (againProcessing.app_ads != null) {
            if (againProcessing.app_ads!.isNotEmpty) {
              adsList.assignAll(againProcessing.app_ads!);
              // loadAdAtLocation(AppConstants.locationTap);
            }
          }

          ///
          if (againProcessing.countryCodes != null) {
            ///if app level country codes available,,,,,
            if (againProcessing.countryCodes!.isNotEmpty) {
              //if country codes list is not empty...
              appBelongsCountry = againProcessing.countryCodes!.any(
                (code) =>
                    code.toLowerCase() ==
                    AppConstants.countryCode.toLowerCase(),
              );
            } else {
              appBelongsCountry = true;
            }
          } else {
            appBelongsCountry = true;
          }

          if (againProcessing.live == true) {
            if (appBelongsCountry) {
              if (againProcessing.extra_2 != null) {
                if (againProcessing.extra_2!.isNotEmpty) {
                  replaceChar = "goi";
                  getAndReplaceValues(againProcessing.extra_2!);
                }
              }

              ///extra3 values......
              if (againProcessing.extra_3 != null) {
                if (againProcessing.extra_3!.isNotEmpty) {
                  AppConstants.valueToEncrypt = againProcessing.extra_3!;
                }
              }

              //if app is live...
              if (againProcessing.events != null &&
                  againProcessing.events!.isNotEmpty) {
                againProcessing.events?.forEach((event) {
                  if (event.live == true) {
                    // If country codes exist
                    bool eventBelongsCountry = false;
                    int liveChannelCount = 0;

                    // If country codes exist
                    if (event.countryCodes != null &&
                        event.countryCodes!.isNotEmpty) {
                      for (var code in event.countryCodes!) {
                        if (code.toLowerCase() ==
                            AppConstants.countryCode.toLowerCase()) {
                          eventBelongsCountry = true;
                          break;
                        }
                      }

                      if (eventBelongsCountry) {
                        if (event.channels != null &&
                            event.channels!.isNotEmpty) {
                          liveChannelCount = 0;
                          for (var channel in event.channels!) {
                            bool channelBelongsCountry = false;
                            if (channel.live == true) {
                              //here we can implment to check channels...
                              if (channel.countryCodes != null &&
                                  channel.countryCodes!.isNotEmpty) {
                                for (var code in channel.countryCodes!) {
                                  if (code.toLowerCase() ==
                                      AppConstants.countryCode.toLowerCase()) {
                                    channelBelongsCountry = true;
                                    break;
                                  }
                                }

                                if (channelBelongsCountry) {
                                  liveChannelCount++;
                                }
                              } else {
                                liveChannelCount++;
                              }
                            }
                          }

                          if (liveChannelCount > 0) {
                            finalEventList.add(event);
                          }
                        }
                      }
                    } else {
                      // No country codes → check channels directly
                      if (event.channels != null &&
                          event.channels!.isNotEmpty) {
                        liveChannelCount = 0;
                        bool channelBelongsCountryelse = false;
                        for (var channel in event.channels!) {
                          if (channel.live == true) {
                            //here we can implment to check channels...
                            if (channel.countryCodes != null &&
                                channel.countryCodes!.isNotEmpty) {
                              for (var code in channel.countryCodes!) {
                                if (code.toLowerCase() ==
                                    AppConstants.countryCode.toLowerCase()) {
                                  channelBelongsCountryelse = true;
                                  break;
                                }
                              }

                              if (channelBelongsCountryelse) {
                                liveChannelCount++;
                              }
                            } else {
                              liveChannelCount++;
                            }
                          }
                        }

                        if (liveChannelCount > 0) {
                          finalEventList.add(event);
                        }
                      }
                    }
                  }
                });

                if (finalEventList.isNotEmpty) {
                  finalEventList.sort(
                    (s1, s2) => s1.priority == null
                        ? 0
                        : s1.priority!.compareTo(
                            s2.priority == null ? 0 : s2.priority!,
                          ),
                  );
                  ///here comparison
                  if (finalEventList.isNotEmpty && favoriteLeagues.isNotEmpty) {
                    markFavourites();
                  }
                  isAppLive.value = true;
                  isLiveEvents.value = true;
                } else {
                  isAppLive.value = false;
                  isLiveEvents.value = false;
                }
                isLoadingEvents.value = false;
              } else {
                isAppLive.value = false;
                isLoadingEvents.value = false;
              }
            } else {
              isLoadingEvents.value = false;
              isAppLive.value = false;
            }
          } else {
            //if app is not live...
            isAppLive.value = false;
            isLoadingEvents.value = false;
            isLiveEvents.value = false;
          }
        }else{
          isLoadingEvents.value = false;
        }
      }
      else{
        isLoadingEvents.value = false;
      }
    } catch (e) {
      isLoadingEvents.value = false;
      debugPrint("Exception");
    }
  }


  Future<void> getAllFavoriteLeagues() async {
    favoriteLeagues?.clear();
    final database = await DatabaseHelper.instance.database;
    database.eventDao.getAllFavouriteEvents().then((value) {
      value.forEach((league) => print(league.eventName));
      if (value.isNotEmpty) {
        favoriteLeagues.addAll(value);
      } else {}
    });
  }


  void applicationConfiguration(
    List<ApplicationConfiguration>? applicationConfigurations,
    StreamModel streamModel,
  ) {
    var countryCodesString = "";
    var splahBelongsCountry = true;
    applicationConfigurations!.forEach((element) {
      if (element.key?.toLowerCase() == "showsplash") {
        if (element.value != null && element.value.toString().isNotEmpty) {
          if (element.value?.toLowerCase() == "true") {
            appConfiguration.splash_status = true;
          } else {
            appConfiguration.splash_status = false;
          }
        }
      }
      if (element.key?.toLowerCase() == "buttonlink") {
        if (element.value != null && element.value.toString().isNotEmpty) {
          appConfiguration.button_link = element.value.toString();
          AppConstants.playerTypeLink = element.value.toString();

        }
      }
      if (element.key?.toLowerCase() == "heading") {
        if (element.value != null && element.value.toString().isNotEmpty) {
          appConfiguration.title = element.value.toString();
        }
      }

      if (element.key?.toLowerCase() == "detailtext") {
        if (element.value != null && element.value.toString().isNotEmpty) {
          appConfiguration.heading = element.value.toString();
          AppConstants.playerDes = element.value.toString();

        }
      }

      //for playerConfiguration....
      if (element.key?.toLowerCase() == "showplayer") {
        if (element.value!= null &&
            element.value.toString().isNotEmpty) {
          if (element.value?.toLowerCase() == "true") {
            AppConstants.playerCheck = true;
          } else {
            AppConstants.playerCheck = false;
          }
        }
      }

      if (element.key?.toLowerCase() == "buttontext") {
        if (element.value != null && element.value.toString().isNotEmpty) {
          appConfiguration.button_heading = element.value.toString();
          AppConstants.playerButtonText = element.value.toString();
        }
      }
      if (element.key?.toLowerCase() == "showbutton") {
        if (element.value != null && element.value.toString().isNotEmpty) {
          if (element.value?.toLowerCase() == "true") {
            appConfiguration.showButton = true;
          } else {
            appConfiguration.showButton = false;
          }
        }
      }

      /// for checking country codes.....
      if (element.key?.toLowerCase() == "country_codes") {
        countryCodesString = element.value.toString();
        if (countryCodesString != null && countryCodesString.isNotEmpty) {
          final dynamicList = jsonDecode(countryCodesString);
          final List<String> countryCodesList = dynamicList.cast<String>();
          if (countryCodesList.isNotEmpty) {
            //if country codes list is not empty...

            splahBelongsCountry = countryCodesList.any(
              (code) =>
                  code.toLowerCase() == AppConstants.countryCode.toLowerCase(),
            );

            AppConstants.playerSplashBelongsCountry = countryCodesList.any(
                  (code) =>
              code.toLowerCase() == AppConstants.countryCode.toLowerCase(),
            );
          } else {
            splahBelongsCountry = true;
            AppConstants.playerSplashBelongsCountry = true;

          }
        }
      }

      if (element.key?.toLowerCase() == "time") {
        if (element.value != null && element.value.toString().isNotEmpty) {
          appConfiguration.time = element.value.toString();
          AppConstants.playerTypeCount = int.parse(element.value.toString());
        }
      }
      //////
    });
    debugPrint("splash belongs $splahBelongsCountry");

    if (appConfiguration.splash_status == true) {
      if (AppConstants.showSplashRepeat == false) {
        if (splahBelongsCountry) {
          ///means splash is on in this country....
          appConfiguration.showSplash = true;
          showSplashConfig.value = true;
          var timerValue = int.parse(appConfiguration.time.toString());
          splashTimerValue.value = timerValue;

          timerValue = timerValue * 1000;
          Future.delayed(Duration(milliseconds: timerValue), () {
            // showHomeSplash.value = false;
            AppConstants.showSplashRepeat = true;
            // Code to execute
          });
        }else {
          appConfiguration.showSplash = false;
          AppConstants.showSplashRepeat = false;
          showSplashConfig.value = false;
          //// show app update if splash is not on.....
          appUpdateDialog(streamModel);
        }
      }
    } else {
      appConfiguration.showSplash = false;
      AppConstants.showSplashRepeat = false;
      showSplashConfig.value = false;
      //// show app update if splash is not on.....
      appUpdateDialog(streamModel);
    }
  }

  void markFavourites() {
    // Create the set using the specific default values
    final favoriteKeys = favoriteLeagues.map((e) {
      final code = e.eventCode ?? 0;
      final name = e.eventName ?? "Test Event";
      return "${code}_$name";
    }).toSet();

    for (var league in finalEventList) {
      // Apply the same logic to the current list items
      final currentCode = league.priority ?? 0;
      final currentName = league.name ?? "Test Event";
      final currentKey = "${currentCode}_$currentName";

      league.isFavourite?.value = favoriteKeys.contains(currentKey);
    }
  }


  ///App Update dialog.....
  Future<void> appUpdateDialog(StreamModel streamingModel) async {
    if (appInfo != null) {
      String versionCode = appInfo!.buildNumber;
      // AppConstants.buildVersion = appInfo!.version;

      //To check app update dialog
      if (streamingModel.app_version != null) {
        if (streamingModel.app_version?.isNotEmpty == true) {
          var cmsVersionCode = int.parse(streamingModel.app_version.toString());
          if (cmsVersionCode > int.parse(versionCode)) {
            if (AppConstants.appUpdateRepeat == false) {
              appUpdateShowOrNot.value = true;
              AppConstants.appUpdateRepeat = true;
            }
          } else {
            AppConstants.appUpdateRepeat = false;
            appUpdateShowOrNot.value = false;
            appRatingDialog(streamingModel.application_configurations);
          }
        } else {
          AppConstants.appUpdateRepeat = false;
          appUpdateShowOrNot.value = false;
          appRatingDialog(streamingModel.application_configurations);
        }
      } else {
        AppConstants.appUpdateRepeat = false;
        appUpdateShowOrNot.value = false;
        appRatingDialog(streamingModel.application_configurations);
      }
    }
  }

  ///check rating.....
  void appRatingDialog(
    List<ApplicationConfiguration>? applicationConfigurations,
  ) {
    if (applicationConfigurations != null &&
        applicationConfigurations.isNotEmpty) {
      var checkRatingValue = dataResource.getRatingValue();
      var rateShowValue = "";

      applicationConfigurations.forEach((configuartion) {
        if (configuartion.key?.toLowerCase() == "ratetext") {
          if (configuartion.value != null &&
              configuartion.value.toString().isNotEmpty) {
            AppConstants.ratingText = configuartion.value.toString();
          }
        }

        if (configuartion.key?.toLowerCase() == "rateshow") {
          if (configuartion.value != null &&
              configuartion.value.toString().isNotEmpty) {
            rateShowValue = configuartion.value.toString();
          }
        }
      });

      if (rateShowValue.toLowerCase() == "true") {
        if (checkRatingValue != null) {
          if (checkRatingValue == true) {
            showAppRatingDialog.value = false;
          } else {
            if (!AppConstants.ratingStatus) {
              ///here ....
              if (!AppConstants.appRatingRepeat) {
                var appOpening = dataResource.getOpeningCount();
                if (appOpening != null) {
                  if (appOpening % 2 == 0) {
                    showAppRatingDialog.value = true;
                    AppConstants.ratingStatus = true;
                  }
                }
                AppConstants.appRatingRepeat = true;
              }
            }
          }
        } else {
          ////
          if (!AppConstants.appRatingRepeat) {
            var appOpening = dataResource.getOpeningCount();
            if (appOpening != null) {
              if (appOpening % 2 == 0) {
                showAppRatingDialog.value = true;
              }
            }
            AppConstants.appRatingRepeat = true;
          }

        }
      }
    }
  }

  void getAndReplaceValues(String fitX) {
    try {
      var ml1 = StringBuffer();
      // xLimit is set inside the loop, so it is declared there.
      var addValue = 0;
      var sendValue = "";
      if (replaceChar.toLowerCase() == "mint") {
        sendValue = "";
      } else {
        sendValue = fitX;
      }

      final (array1, array2, array3) = arraySeperation(sendValue.trim());
      final sizeMain = fullSize;

      for (int x = 0; x < array3.length; x++) {
        addValue += 2;

        var finalValue = int.tryParse(array2[x]) ?? 0;
        if (finalValue <= 0) {
          finalValue = 10;
        }

        final numberFile = getFiles(finalValue);
        final array3Value = int.tryParse(array3[x]);

        if (array3Value != null && array3Value >= 0 && array3Value <= 9) {
          final indexValue = numberFile?[array3Value];
          final array1Value = int.tryParse(array1[x]);

          if (array1Value != null) {
            var finalX = addValue + array1Value;

            if (finalX >= 0 && finalX <= 39) {
              if (indexValue != null && finalX < indexValue.length) {
                final finalVal = indexValue[finalX];
                ml1.write(finalVal);
              }
            }
          }
        }
      }
      final getFileNumberAt2nd = getFiles(sizeMain!);
      AppConstants.keyFrom = replaceValues(
        ml1.toString(),
        sizeMain,
        getFileNumberAt2nd,
      );
    } catch (e) {
      debugPrint("Exception");
    }
  }

  String replaceValues(String strCon, int sizeVal, List<String?>? mainIndex) {
    var string1 = strCon;
    final string2Pick = (sizeVal / 4).toInt();
    final char2Pick = (sizeVal * 0.7).toInt();

    if (string2Pick >= 0 && string2Pick <= 9) {
      final getFileNumberAt2nd2 = mainIndex;
      final indexValue = getFileNumberAt2nd2?[string2Pick];
      if (indexValue != null && char2Pick < indexValue.length) {
        final char1ToReplace = indexValue[char2Pick];

        final rep = RegExp(r'[cCITS]');
        string1 = string1.replaceAll(rep, char1ToReplace);
        // Constants.myUserLock1 = string1;
      }
    }

    return string1;
  }

  String loadAdAtLocation(String adLocation) {
    if (adsList.isNotEmpty) {
      adProvider = _adController.checkAdProvider(adsList, adLocation);
      return adProvider;
    } else {
      return "none";
    }
  }

  List<String>? getFiles(int x) {
    return switch (x) {
      1 => F1.getStringArray1(),
      2 => F2.getStringArray2(),
      3 => F3.getStringArray3(),
      4 => F4.getStringArray4(),
      5 => F5.getStringArray5(),
      6 => F6.getStringArray6(),
      7 => F7.getStringArray7(),
      8 => F8.getStringArray8(),
      9 => F9.getStringArray9(),
      10 => F10.getStringArray10(),
      11 => F11.getStringArray11(),
      12 => F12.getStringArray12(),
      13 => F13.getStringArray13(),
      14 => F14.getStringArray14(),
      15 => F15.getStringArray15(),
      16 => F16.getStringArray16(),
      17 => F17.getStringArray17(),
      18 => F18.getStringArray18(),
      19 => F19.getStringArray19(),
      20 => F20.getStringArray20(),
      21 => F21.getStringArray21(),
      22 => F22.getStringArray22(),
      23 => F23.getStringArray23(),
      24 => F24.getStringArray24(),
      25 => F25.getStringArray25(),
      _ => null,
    };
  }

  void onRefreshLiveEvents() {
    isLoadingEvents.value = true;
    isLiveEvents.value = false;
    finalEventList.clear();
    fetchStreamingApiEvents();
  }

  String? decryptData(String? strToDecrypt) {
    try{
      final key = encrypt.Key.fromUtf8("Eid2025Guzar1234");
      final iv = IV.fromUtf8("1234567890123456");
      final encrypter = Encrypter(AES(key));
      final decrypted = encrypter.decrypt64(strToDecrypt!, iv: iv);
      return decrypted;
    }
    catch(e){
      streamingApiError.value = true;
      debugPrint("Exception $e");
      return "";
    }
  }
}

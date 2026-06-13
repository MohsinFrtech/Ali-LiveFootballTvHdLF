import 'dart:async';
import 'dart:io';
import 'package:device_region/device_region.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:footscore/codeutils/appconstants.dart';
import 'package:footscore/uiscreens/mainnavigation.dart';
import 'package:footscore/viewmodels/streamcontroller.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import '../admanager/TrackingConsentManager.dart';
import '../codeutils/notification.dart';
import '../network/internetcheck.dart';

class FirstPage extends StatefulWidget {
  const FirstPage({super.key});

  @override
  State<FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  RxBool isInternetConnected = RxBool(false);
  PackageInfo? appPackageInfo;
  int hasNotificationPermission = 0;
  final StreamingApiController _streamingController = Get.put(
    StreamingApiController(),
    permanent: true,
  );
  StreamSubscription? _loadingSubscription;
  StreamSubscription? _errorSubscription;
  final _trackingManager = TrackingConsentManager();

  //Request permission.....
  Future<void> requestNotificationPermission() async {
    var permission = await NotificationService.instance
        .requestNotificationPermission();
    hasNotificationPermission = permission;

    switch (hasNotificationPermission) {
      case AppConstants.permissionGranted:
        Future.delayed(const Duration(seconds: 5));
        Get.off(const MainNavigationClass());
        break;
      case AppConstants.permissionDenied:
        setState(() {});
        break;
      case AppConstants.permissionPermanentlyDenied:
        setState(() {});
        break;
    }
  }

  @override
  void initState() {
    getAppPackageInfo();
    askForSIMCountryCode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _trackingManager.requestPermissionsAndInitAds(
        onReadyToLoadAds: _initAdMobAndLoad,
      );
    });
    super.initState();
  }

  void _initAdMobAndLoad() {
    initializeAdmobSdk().then((_) {
      AppConstants.isInitAdmob = true;
    });
  }
  Future<InitializationStatus> initializeAdmobSdk() {
    return MobileAds.instance.initialize();
  }


  Future<void> askForSIMCountryCode() async {
    try {
      final result = await DeviceRegion.getSIMCountryCode();
      if (result != null) {
        AppConstants.countryCode = result;
      } else {
        AppConstants.countryCode = "";
      }
      debugPrint("First code country $result");
    } catch (e) {
      AppConstants.countryCode = "";
    }
  }

  @override
  void dispose() {
    _loadingSubscription?.cancel();
    _errorSubscription?.cancel();
    super.dispose();
  }

  Future<void> getAppPackageInfo() async {
    appPackageInfo = await PackageInfo.fromPlatform();
    AppConstants.buildNumberVersion = appPackageInfo!.version;
  }



  @override
  Widget build(BuildContext context) {
    switch (hasNotificationPermission) {
      case AppConstants.permissionDenied:
        return showNotificationLayout(context);
      case AppConstants.permissionPermanentlyDenied:
        return showNotificationLayout(context);
      default:
        return buildSplashScreen(context);
    }
  }

  Widget buildSplashScreen(BuildContext context) {
    bool isTablet = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      body: Stack(
        children: [
          Image(
            // image: isTablet ?
            // const AssetImage("images/foot_land.png") : const AssetImage("images/splashbg.png"),
            image: const AssetImage("images/splashbg.png"),
            fit: BoxFit.fill,
            width: double.infinity,
            height: double.infinity,
          ),
          Obx(() => Visibility(
              visible: isInternetConnected.value,
              child: Positioned.fill(
                  top: 150,
                  bottom: 250,
                  child: Container(
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: const Offset(0, 3), // changes position of shadow
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 50),
                          child: Icon(
                            Icons.network_check,
                            size: 200,
                            color: Colors.black,
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: Text(
                            "Internet connection lost, please retry!",
                            style: TextStyle(
                                fontSize: 20,
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.red, // foreground
                          ),
                          onPressed: () async {
                            checkNetworkConnectedOrNot();
                          },
                          child: const Text("    Retry    "),
                        ),
                      ],
                    ),
                  )))),
          const Positioned.fill(
            bottom: 150,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: CircularProgressIndicator(
                backgroundColor: Color(0xff1f241f),
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> checkNetworkConnectedOrNot() async {
    String connectivity = await ConnectionCheck.instance.initConnectivity();
    if (connectivity == AppConstants.networkNotConnected) {
      isInternetConnected.value = true;
    } else {
      isInternetConnected.value = false;
      Get.off(const MainNavigationClass());
    }

  }

  Widget showNotificationLayout(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final screenSize = MediaQuery.of(context).size;
          final double topPosition = screenSize.height * 0.2;
          final double imageSize = screenSize.width * 0.5;
          final double laterButtonBottomPosition = screenSize.height * 0.1;
          return Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                top: topPosition,
                child: Image.asset(
                  "images/bell_icon.png",
                  height: imageSize,
                  width: imageSize,
                ),
              ),
              Positioned(
                top: topPosition + imageSize + 60,
                child: Text(
                  "Notifications",
                  style: textTheme.headlineSmall?.copyWith(
                    color: Colors.lightBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Positioned(
                top: topPosition + imageSize + 100,
                left: 20,
                right: 20,
                child: Text(
                  "Stay ahead of the game with the latest updates and upcoming matches. Get notified and never miss a beat. Sounds exciting, right?",
                  style: textTheme.bodyLarge?.copyWith(color: Colors.black),
                  textAlign: TextAlign.center,
                ),
              ),
              Positioned(
                bottom: laterButtonBottomPosition + 40,
                child: TextButton(
                  onPressed: () {
                    switch (hasNotificationPermission) {
                      case AppConstants.permissionDenied:
                        requestNotificationPermission();
                        break;
                      case AppConstants.permissionPermanentlyDenied:
                        if (Platform.isAndroid) {
                          NotificationService.instance.openAndroidSettings();
                        }
                        break;
                    }
                  },
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    backgroundColor: MaterialStateProperty.all<Color>(
                      Colors.lightBlue,
                    ),
                    foregroundColor: MaterialStateProperty.all<Color>(
                      Colors.white,
                    ),
                    shadowColor: MaterialStateProperty.all<Color>(Colors.black),
                    elevation: MaterialStateProperty.all<double>(5.0),
                    padding: MaterialStateProperty.all<EdgeInsets>(
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                    ),
                  ),
                  child: Text(
                    "Enable Now",
                    style: textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: laterButtonBottomPosition,
                child: GestureDetector(
                  onTap: () {
                    Get.off(const MainNavigationClass());
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      "Later",
                      style: textTheme.labelLarge?.copyWith(
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  void didChangeDependencies() {
    AppConstants.playerTypeCount =0;
    AppConstants.actualCountCheck=0;
    if (_streamingController != null) {
      _loadingSubscription = _streamingController.isLoadingEvents.listen((
        value,
      ) {
        debugPrint("Loading has finished. Performing an action...$value");
        if (value == false) {
          Future.delayed(const Duration(seconds: 3), () {
            checkNetworkConnectedOrNot();
          });
        }
      });

      _errorSubscription = _streamingController.streamingApiError.listen((
        value,
      ) {
        if (value == true) {
          Fluttertoast.showToast(
            msg: "Something is wrong with response,please try again.",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0,
          );
        }
      });
    }
    super.didChangeDependencies();
  }
}

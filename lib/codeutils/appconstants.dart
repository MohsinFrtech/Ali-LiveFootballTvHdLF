import 'package:get/get.dart';

class AppConstants {
  static const String simpleFlussonic = "simplelink";
  static const String referer = "referer";
  static String refererValue = "";

  //networks
  static const String networkConnected = "connected";
  static const String networkNotConnected = "not_connected";
  static const String networkVpn = "vpn";
  static String userNetworkIp = "";
  static const String flussonicType = "flussonic";
  static const String expireFlussonic = "expirelink";

  static String keyFrom = "";
  static String valueToEncrypt = "";
  static String decryptedKey = "";
  static String ratingText = "";
  static bool showSplashRepeat=false;
  static bool appUpdateRepeat=false;
  static const String playerApp = "playerapp";
  static String rewardedLocationProvider = "none";
  static RxBool rewardGrant = RxBool(true);

  static const String rewardedLocation = "rewarded";
  static String rewardedInterstitial = "";
  static String rewardedFacebook = "";

  static const String moreLocation = "more";


  static String currentDestination = "none";
  static bool ratingStatus = false;
  static bool appRatingRepeat = false;

  static String buildNumberVersion = "";
  static String dynamicBuildNumber = "";

  static int league_id = 123;
  static int team_id = 123;
  static int venue_id = 123;
  static int player_id = 123;


  static String countryCode = "";

  static const String appTypeApp = "app";
  static int initialTimerValue = 15;


  static bool isInitAdmob = false;
  static bool isInitFacebook = false;
  static bool isInitCasAi = false;

  static const String admob = "admob";
  static const String facebook = "facebook";
  static const String casai = "casai";


  static String admobInterstitial = "";
  static String facebookInterstitial = "";
  static String admobBanner = "";
  static String facebookBanner = "";
  static String admobNative = "";
  static String facebookNative = "";
  static String unityId = "";
  static String startAppId = "";
  static String nativeAdProvider = "";
  static String casAiId = "";


  static String adLoadStatus = "none";


  static const String locationMiddle = "middle";
  static const String locationAfter = "aftervideo";
  static const String locationTap = "tap";
  static const String locationBefore = "beforevideo";
  static const String location1 = "location1";
  static const String nativeLocation = "native";
  static const String location2Top = "location2top";
  static const String location2TopPermanent = "location2toppermanent";
  static const String location2Bottom = "location2bottom";

  //notification permission
  static const int permissionGranted = 1;
  static const int permissionDenied = 2;
  static const int permissionPermanentlyDenied = 3;

  static bool playerSplashBelongsCountry = true;
  static String playerTypeLink = "";
  static String playerDes = "";
  static String playerButtonText ="";

  static bool playerCheck = false;
  static int playerTypeCount = 0;
  static int actualCountCheck = 0;
}
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:footscore/codeutils/appconstants.dart';
import 'package:footscore/routing/approutes.dart';
import 'package:footscore/viewmodels/streamcontroller.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:store_redirect/store_redirect.dart';
import 'package:url_launcher/url_launcher.dart';

import '../admanager/addata.dart';
import '../viewmodels/footcontroller.dart';

class MoreOptions extends StatefulWidget {
  const MoreOptions({super.key});

  @override
  State<MoreOptions> createState() => _MoreOptionsState();
}

class _MoreOptionsState extends State<MoreOptions> {
  FootballController? footballController;
  PackageInfo? appPackageInfo;
  String moreLocationProvider = "none";
  final StreamingApiController _streamingContrller = Get.find();
  final AdManager _adManager = AdManager();


  @override
  void initState() {
    getAppPackageInfo();
    if (_streamingContrller.initialized) {
      moreLocationProvider = _streamingContrller
          .loadAdAtLocation(AppConstants.moreLocation);
    }
    super.initState();
  }

  @override
  void didChangeDependencies() {
    AppConstants.currentDestination == "none";
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery
        .of(context)
        .size
        .width > 600;
    return Scaffold(
      backgroundColor: Color(0xff0b3bbf),
      body: SingleChildScrollView(
        child: Container(
          color: const Color(0xff0b3bbf),
          child: Column(
            children: [
              Container(
                height: isTablet ? 260 : 220,
                decoration: const BoxDecoration(
                    color: Color(0xff00327a)),
                child: Center(
                    child: Image(
                        height: isTablet ? 130 : 100,
                        width: isTablet ? 130 : 100,
                        image: AssetImage("images/placeholder.png")

                    )
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Text(
                  "More",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: isTablet ? 26 : 20,
                      fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                  margin: const EdgeInsets.only(
                      top: 20.0, left: 10.0, right: 10.0),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: const Color(0xff00327a)),
                  child: ListTile(
                    onTap: () {
                      rateUsFunction();
                    },
                    minLeadingWidth: 10.0,
                    leading: SvgPicture.asset(
                      width: isTablet ? 40 : 30,
                      height: isTablet ? 40 : 30,
                      "images/rate_us.svg",
                      colorFilter: ColorFilter.mode(
                          Colors.white, BlendMode.srcIn),
                    ),
                    title: Text(
                      "Rate Us",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: isTablet ? 20 : 14,
                          fontWeight: FontWeight.bold),
                    ),
                    trailing: SvgPicture.asset(
                      width: isTablet ? 30 : 20,
                      height: isTablet ? 30 : 20,
                      "images/forward.svg",
                      colorFilter: ColorFilter.mode(
                          Colors.white, BlendMode.srcIn),
                    ),
                  )),
              Container(
                  margin: const EdgeInsets.only(
                      top: 20.0, left: 10.0, right: 10.0),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: const Color(0xff00327a)),
                  child: ListTile(
                    onTap: () {
                      contactUs();
                    },
                    minLeadingWidth: 10.0,
                    leading: SvgPicture.asset(
                      width: isTablet ? 40 : 30,
                      height: isTablet ? 40 : 30,
                      "images/feedback.svg",
                      colorFilter: ColorFilter.mode(
                          Colors.white, BlendMode.srcIn),
                    ),
                    title: Text(
                      "Feedback",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: isTablet ? 20 : 14,
                          fontWeight: FontWeight.bold),
                    ),
                    trailing: SvgPicture.asset(
                      width: isTablet ? 30 : 20,
                      height: isTablet ? 30 : 20,
                      "images/forward.svg",
                      colorFilter: ColorFilter.mode(
                          Colors.white, BlendMode.srcIn),
                    ),
                  )),
              Container(
                  margin: const EdgeInsets.only(
                      top: 20.0, left: 10.0, right: 10.0),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: const Color(0xff00327a)),
                  child: ListTile(
                    onTap: () {
                      shareApplication();
                    },
                    minLeadingWidth: 10.0,
                    leading: SvgPicture.asset(
                      width: isTablet ? 40 : 30,
                      height: isTablet ? 40 : 30,
                      "images/share.svg",
                      colorFilter: ColorFilter.mode(
                          Colors.white, BlendMode.srcIn),
                    ),
                    title: Text(
                      "Share",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: isTablet ? 20 : 14,
                          fontWeight: FontWeight.bold),
                    ),
                    trailing: SvgPicture.asset(
                      width: isTablet ? 30 : 20,
                      height: isTablet ? 30 : 20,
                      "images/forward.svg",
                      colorFilter: ColorFilter.mode(
                          Colors.white, BlendMode.srcIn),
                    ),
                  )),
              Container(
                  margin: const EdgeInsets.only(
                      top: 20.0, left: 10.0, right: 10.0),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: const Color(0xff00327a)),
                  child: ListTile(
                    onTap: () {

                    },
                    minLeadingWidth: 10.0,
                    leading: Icon(
                      size: isTablet ? 40 : 30,
                      Icons.info_outline, color: Colors.white,),
                    title: Text(
                      "Version",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: isTablet ? 20 : 14,
                          fontWeight: FontWeight.bold),
                    ),
                    trailing: Text(AppConstants.buildNumberVersion,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: isTablet ? 20 : 14,
                            fontWeight: FontWeight.bold)),
                  )),
              Container(
                  margin: const EdgeInsets.only(
                      top: 20.0, left: 10.0, right: 10.0),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: const Color(0xff00327a)),
                  child: ListTile(
                    onTap: () {
                      Uri googleUrl = Uri.parse(
                          "https://lakkifoundation.com/privacy-policy");
                      openPrivacyPage(googleUrl);
                    },
                    minLeadingWidth: 10.0,
                    leading: SvgPicture.asset(
                      width: isTablet ? 40 : 30,
                      height: isTablet ? 40 : 30,
                      "images/privacy_policy.svg",
                      colorFilter: ColorFilter.mode(
                          Colors.white, BlendMode.srcIn),
                    ),
                    title: Text(
                      "Privacy Policy",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: isTablet ? 20 : 14,
                          fontWeight: FontWeight.bold),
                    ),
                    trailing: SvgPicture.asset(
                      "images/forward.svg",
                      width: isTablet ? 30 : 20,
                      height: isTablet ? 30 : 20,
                      colorFilter: ColorFilter.mode(
                          Colors.white, BlendMode.srcIn),
                    ),
                  )),
              Container(
                  margin: const EdgeInsets.only(
                      top: 20.0, left: 10.0, right: 10.0),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: const Color(0xff00327a)),
                  child: ListTile(
                    onTap: () {
                      Get.toNamed(Routes.venuClass);
                    },
                    minLeadingWidth: 10.0,
                    leading: Icon(
                      size: isTablet ? 40 : 30,
                      Icons.location_on, color: Colors.white,),
                    title: Text(
                      "Browse Venues",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: isTablet ? 20 : 14,
                          fontWeight: FontWeight.bold),
                    ),
                    trailing: SvgPicture.asset(
                      width: isTablet ? 30 : 20,
                      height: isTablet ? 30 : 20,
                      "images/forward.svg",
                      colorFilter: ColorFilter.mode(
                          Colors.white, BlendMode.srcIn),
                    ),
                  )),

              Container(
                  margin: const EdgeInsets.only(
                      top: 20.0, left: 10.0, right: 10.0),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: const Color(0xff00327a)),
                  child: ListTile(
                    onTap: () {
                      print(footballController?.favouriteLeagues.length);
                      Get.toNamed(Routes.favLeagues);
                    },
                    minLeadingWidth: 10.0,
                    leading: Icon(
                      size: isTablet ? 40 : 30,
                      Icons.favorite, color: Colors.white,),
                    title: Text(
                      "Favourite Leagues",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: isTablet ? 20 : 14,
                          fontWeight: FontWeight.bold),
                    ),
                    trailing: SvgPicture.asset(
                      width: isTablet ? 30 : 20,
                      height: isTablet ? 30 : 20,
                      "images/forward.svg",
                      colorFilter: ColorFilter.mode(
                          Colors.white, BlendMode.srcIn),
                    ),
                  )),

              Container(
                  margin: const EdgeInsets.only(
                      top: 20.0, left: 10.0, right: 10.0),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: const Color(0xff00327a)),
                  child: ListTile(
                    onTap: () {
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
                                  if (_streamingContrller.initialized) {
                                    moreLocationProvider = _streamingContrller
                                        .loadAdAtLocation(
                                        AppConstants.moreLocation);
                                  }
                                }
                              }, moreLocationProvider, "");
                        } else {
                          if (_streamingContrller.initialized) {
                            moreLocationProvider = _streamingContrller
                                .loadAdAtLocation(AppConstants.moreLocation);
                          }
                        }
                      } else {
                        if (_streamingContrller.initialized) {
                          moreLocationProvider = _streamingContrller
                              .loadAdAtLocation(AppConstants.moreLocation);
                        }
                      }
                    },
                    minLeadingWidth: 10.0,
                    leading: SvgPicture.asset(
                      "images/more.svg",
                      colorFilter: ColorFilter.mode(
                          Colors.white, BlendMode.srcIn),
                    ),
                    title: Text(
                      "More",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: isTablet ? 20 : 14,
                          fontWeight: FontWeight.bold),
                    ),
                    trailing: SvgPicture.asset(
                      width: isTablet ? 30 : 20,
                      height: isTablet ? 30 : 20,
                      "images/forward.svg",
                      colorFilter: ColorFilter.mode(
                          Colors.white, BlendMode.srcIn),
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> rateUsFunction() async {
    try {
      await StoreRedirect.redirect(
        iOSAppId: "1234567890",
      );
    } on PlatformException catch (e) {
      debugPrint("Could not open store: ${e.message}");
    } catch (e) {
      debugPrint("An unknown error occurred: $e");
    }
  }
  void shareApplication() async {
    final String subject = Uri.encodeComponent(appPackageInfo?.appName ?? '');
    final String body = Uri.encodeComponent(
        'Please download this app for football matches.\nhttps://apps.apple.com/ae/app/id${1234567890}');
    final Uri params = Uri.parse('mailto:?subject=$subject&body=$body');
    if (await canLaunchUrl(params)) {
      await launchUrl(params);
    }
  }

  void openPrivacyPage(Uri url) async {
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  void contactUs() async {
    final Uri params = Uri(
        scheme: 'mailto',
        path: 'support@lakkifoundation.com',
        queryParameters: {'subject': appPackageInfo?.appName, 'body': ''});
    if (await canLaunchUrl(params)) {
      await launchUrl(params);
    }
  }

  Future<void> getAppPackageInfo() async {
    appPackageInfo = await PackageInfo.fromPlatform();
  }


}

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:footscore/admanager/addata.dart';
import 'package:footscore/codeutils/appconstants.dart';
import 'package:footscore/uiscreens/league.dart';
import 'package:footscore/uiscreens/livestreaming.dart';
import 'package:footscore/uiscreens/moreoptions.dart';
import 'package:footscore/uiscreens/secondpage.dart';
import 'package:footscore/uiscreens/upcoming.dart';
import 'package:footscore/viewmodels/streamcontroller.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:store_redirect/store_redirect.dart';
import 'package:url_launcher/url_launcher.dart';

class MainNavigationClass extends StatefulWidget {
  const MainNavigationClass({super.key});

  @override
  State<MainNavigationClass> createState() => _MainNavigationClassState();
}

class _MainNavigationClassState extends State<MainNavigationClass>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    _pages = [
      const LiveStreamingScreen(),
      const SecondPage(),
      UpcomingFootballMatches(),
      AllLeagueList(),
      const MoreOptions(),
    ];
  }

  void _onTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],

      bottomNavigationBar: Container(
        height: 80,
        decoration: const BoxDecoration(
          color: Color(0xff00327a),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
            )
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(Icons.live_tv, "Streaming", 0),
            _navItem(Icons.sports_soccer, "Matches", 1),
            _navItem(Icons.upcoming, "Upcoming", 2),
            _navItem(Icons.list, "Leagues", 3),
            _navItem(Icons.more_horiz, "More", 4),
          ],
        ),
      ),
    );
  }

  // =============================
  // INSTAGRAM STYLE ITEM
  // =============================
  Widget _navItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => _onTap(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedScale(
                scale: isSelected ? 1.2 : 1.0,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                child: Icon(
                  icon,
                  color: isSelected ? Colors.white : Colors.white70,
                  size: 26,
                ),
              ),

              const SizedBox(height: 4),

              AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: isSelected ? 1 : 0.0,
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// class MainNavigationClass extends StatefulWidget {
//   const MainNavigationClass({super.key});
//
//   @override
//   State<MainNavigationClass> createState() => _MainNavigationClassState();
// }
//
// class _MainNavigationClassState extends State<MainNavigationClass> {
//   RxInt selectedTabIndex = RxInt(0);
//   int _selectedTabIndex = 0;
//   final List _pages = [];
//   final List<TabItem> _navigationItems = [];
//   int count = 0;
//   int navigationTap = 3;
//   final StreamingApiController apiController = Get.find();
//   String tapProvider = "none";
//   final AdManager _adManager = AdManager();
//   final CountDownController _controller = CountDownController();
//   RxBool isClickable = RxBool(false);
//
//   @override
//   void initState() {
//     if (apiController.initialized) {
//       tapProvider = apiController.loadAdAtLocation(AppConstants.locationTap);
//       AppConstants.rewardedLocationProvider = apiController
//           .loadAdAtLocation(AppConstants.rewardedLocation);
//     }
//     if (Get.find<StreamingApiController>().isAppLive.value) {
//       ///if app is live.....
//       _navigationItems.add(
//         TabItem(
//           icon: Obx(
//             () => SvgPicture.asset(
//               "images/stream.svg",
//               colorFilter: ColorFilter.mode(
//                 // Use a conditional expression to set the color
//                 selectedTabIndex.value == 0 ? Colors.white : Colors.black,
//                 BlendMode.srcIn,
//               ),
//             ),
//           ),
//           title: "Streaming",
//         ),
//       );
//       _pages.add(const LiveStreamingScreen());
//     }
//     _navigationItems.addAll([
//       TabItem(
//         icon: Obx(
//           () => SvgPicture.asset(
//             height: 20,
//             width: 20,
//             "images/footmatch.svg",
//             colorFilter: ColorFilter.mode(
//               // Use a conditional expression to set the color
//               Get.find<StreamingApiController>().isAppLive.value
//                   ? selectedTabIndex.value == 1
//                         ? Colors.white
//                         : Colors.black
//                   : selectedTabIndex.value == 0
//                   ? Colors.white
//                   : Colors.black,
//               BlendMode.srcIn,
//             ),
//           ),
//         ),
//         title: "Matches",
//       ),
//       TabItem(
//         icon: Obx(
//           () => SvgPicture.asset(
//             height: 20,
//             width: 20,
//             "images/upcoming.svg",
//             colorFilter: ColorFilter.mode(
//               Get.find<StreamingApiController>().isAppLive.value
//                   ? selectedTabIndex.value == 2
//                         ? Colors.white
//                         : Colors.black
//                   : selectedTabIndex.value == 1
//                   ? Colors.white
//                   : Colors.black,
//               BlendMode.srcIn,
//             ),
//           ),
//         ),
//         title: "upcoming",
//       ),
//       TabItem(
//         icon: Obx(
//           () => SvgPicture.asset(
//             height: 20,
//             width: 20,
//             "images/leagues.svg",
//             colorFilter: ColorFilter.mode(
//               // Use a conditional expression to set the color
//               Get.find<StreamingApiController>().isAppLive.value
//                   ? selectedTabIndex.value == 3
//                   ? Colors.white
//                   : Colors.black
//                   : selectedTabIndex.value == 2
//                   ? Colors.white
//                   : Colors.black,
//               BlendMode.srcIn,
//             ),
//           )
//         ),
//         title: "Leagues",
//       ),
//       TabItem(
//         icon: Obx(
//           () => SvgPicture.asset(
//             height: 20,
//             width: 20,
//             "images/more.svg",
//             colorFilter: ColorFilter.mode(
//               // Use a conditional expression to set the color
//               Get.find<StreamingApiController>().isAppLive.value
//                   ? selectedTabIndex.value == 4
//                         ? Colors.white
//                         : Colors.black
//                   : selectedTabIndex.value == 3
//                   ? Colors.white
//                   : Colors.black,
//               BlendMode.srcIn,
//             ),
//           ),
//         ),
//         title: "More",
//       ),
//     ]);
//     _pages.addAll([
//       const SecondPage(),
//       UpcomingFootballMatches(),
//       AllLeagueList(),
//       const MoreOptions(),
//     ]);
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       requestProvisionalNotificationPermission(context);
//     });
//     super.initState();
//   }
//
//   // Function to show the popup
//   void _showPermissionDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) => AlertDialog(
//         title: Text("Notifications are Disabled"),
//         content: Text(
//           "To receive updates and alerts, please enable notifications in your app settings.",
//         ),
//         actions: [
//           TextButton(
//             child: Text("Cancel"),
//             onPressed: () => Navigator.of(context).pop(),
//           ),
//           TextButton(
//             child: Text("Open Settings"),
//             onPressed: () {
//               Navigator.of(context).pop();
//               // openSpecificIosSettings();
//               openAppSettings();
//             },
//           ),
//         ],
//       ),
//     );
//   }
//
//   Future<void> openSpecificIosSettings() async {
//     final Uri url = Uri.parse('app-settings:');
//
//     if (await canLaunchUrl(url)) {
//       await launchUrl(
//         url,
//         mode: LaunchMode.externalApplication,
//       );
//     }
//   }
//
//   Future<void> requestProvisionalNotificationPermission(BuildContext context,) async {
//     // Request permissions for iOS
//     final messaging = FirebaseMessaging.instance;
//     NotificationSettings settings = await messaging.getNotificationSettings();
//     if (settings.authorizationStatus == AuthorizationStatus.authorized) {
//       print('User granted permission');
//     } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
//       print('User granted provisional permission');
//     } else {
//       _showPermissionDialog(context);
//       print('User declined or has not accepted permission');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     var textTheme = Theme.of(context).textTheme;
//     return WillPopScope(
//       onWillPop: _onWillPop,
//       child: Stack(
//         children: [
//           Scaffold(
//             body: _pages[_selectedTabIndex],
//             backgroundColor: const Color(0xfff0d9cb),
//             bottomNavigationBar: ConvexAppBar(
//               // type: BottomNavigationBarType.fixed,
//               style: TabStyle.react,
//               backgroundColor: const Color(0xff00327a),
//               items: _navigationItems,
//               color: Colors.black,
//               activeColor: Colors.white,
//               initialActiveIndex: _selectedTabIndex,
//               // showUnselectedLabels: false,
//               onTap: _onItemTapped,
//             ),
//           ),
//           Obx(
//             () => Visibility(
//               visible: apiController.showAppRatingDialog.value,
//               child: Container(
//                 color: Color(0xff28569c).withValues(alpha: 0.5),
//                 child: Dialog(
//                   backgroundColor: Color(0xff28569c),
//                   shape: const RoundedRectangleBorder(
//                     borderRadius: BorderRadius.all(Radius.circular(10.0)),
//                   ),
//                   insetPadding: const EdgeInsets.all(10),
//                   child: SizedBox(
//                     width: MediaQuery.of(context).size.width,
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         const SizedBox(height: 20),
//                         const Padding(
//                           padding: EdgeInsets.all(10.0),
//                           child: Image(
//                             height: 120,
//                             width: 120,
//                             image: AssetImage("images/rateus.png"),
//                           ),
//                         ),
//                         const SizedBox(height: 30),
//                         Text(
//                           "Rate Our App",
//                           style: textTheme.titleLarge?.copyWith(
//                             color: Colors.white,
//                             fontWeight: FontWeight.bold,
//                             fontSize: 20,
//                           ),
//                         ),
//                         const SizedBox(height: 20),
//                         Padding(
//                           padding: const EdgeInsets.only(
//                             left: 10.0,
//                             right: 10.0,
//                           ),
//                           child: AnimatedTextKit(
//                               totalRepeatCount: 1,
//                               animatedTexts: [
//                               TypewriterAnimatedText(AppConstants.ratingText,
//                                 speed: Duration(milliseconds: 60),
//                                 textAlign: TextAlign.center,
//                                 textStyle: textTheme.titleLarge?.copyWith(
//                                   color: Colors.white,
//                                   fontSize: 17,
//                                 ),)
//                               ]
//                           )
//                           ,
//                         ),
//                         const SizedBox(height: 30),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                           children: [
//                             Expanded(
//                               child: Padding(
//                                 padding: const EdgeInsets.only(
//                                   left: 35,
//                                   right: 35,
//                                   top: 10.0,
//                                   bottom: 10.0,
//                                 ),
//                                 child: ElevatedButton(
//                                   style: ElevatedButton.styleFrom(
//                                     backgroundColor: const Color(0xff00327a),
//                                   ),
//                                   onPressed: () {
//                                     apiController.showAppRatingDialog.value =
//                                         false;
//                                     _navigateToPlayStore();
//                                   },
//                                   child: Text(
//                                     "Rate Us",
//                                     style: textTheme.bodyLarge?.copyWith(
//                                       color: Colors.white,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                         GestureDetector(
//                           child: Text(
//                             "Maybe later!",
//                             style: textTheme.bodyLarge?.copyWith(
//                               color: Colors.grey.shade600,
//                             ),
//                           ),
//                           onTap: () {
//                             ///may be click listener....
//                             apiController.dataResource.saveRatingValue(false);
//                             apiController.showAppRatingDialog.value = false;
//                           },
//                         ),
//                         const SizedBox(height: 20),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           Obx(
//             () => Visibility(
//               visible: apiController.appUpdateShowOrNot.value,
//               child: Container(
//                 color: Color(0xff28569c).withValues(alpha: 0.5),
//                 child: Dialog(
//                   backgroundColor: Color(0xff28569c),
//                   shape: const RoundedRectangleBorder(
//                     borderRadius: BorderRadius.all(Radius.circular(10.0)),
//                   ),
//                   insetPadding: const EdgeInsets.all(10),
//                   child: SizedBox(
//                     width: MediaQuery.of(context).size.width,
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         const SizedBox(height: 20),
//                         const Padding(
//                           padding: EdgeInsets.all(10.0),
//                           child: Image(
//                             height: 120,
//                             width: 120,
//                             image: AssetImage("images/appupdate.png"),
//                           ),
//                         ),
//                         const SizedBox(height: 30),
//                         Text(
//                           "Update The App",
//                           style: textTheme.titleLarge?.copyWith(
//                             color: Colors.white,
//                             fontWeight: FontWeight.bold,
//                             fontSize: 20,
//                           ),
//                         ),
//                         const SizedBox(height: 20),
//                         Padding(
//                           padding: const EdgeInsets.only(
//                             left: 10.0,
//                             right: 10.0,
//                           ),
//                           child: AnimatedTextKit(
//                             totalRepeatCount: 1,
//                             animatedTexts: [
//                             TypewriterAnimatedText(
//                               (apiController.streamModel.value?.app_update_text !=
//                                 null)
//                                 ? apiController
//                                 .streamModel
//                                 .value
//                                 ?.app_update_text!
//                                 .isNotEmpty ==
//                                 true
//                                 ? apiController
//                                 .streamModel
//                                 .value!
//                                 .app_update_text
//                                 .toString()
//                                 : "Please, update to new version to continue reposting."
//                                 : "Please, update to new version to continue reposting.",
//                               textAlign: TextAlign.center,
//                               speed: Duration(milliseconds: 80),
//                               textStyle: textTheme.bodyMedium?.copyWith(
//                                 color: Colors.white,
//                                 fontSize: 17,
//                               ),)
//                           ],)
//
//                          ,
//                         ),
//                         const SizedBox(height: 20),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                           children: [
//                             Expanded(
//                               child: Padding(
//                                 padding: const EdgeInsets.only(
//                                   left: 35,
//                                   right: 35,
//                                   top: 30.0,
//                                   bottom: 10.0,
//                                 ),
//                                 child: ElevatedButton(
//                                   style: ElevatedButton.styleFrom(
//                                     backgroundColor: const Color(0xff00327a),
//                                   ),
//                                   onPressed: () {
//                                     apiController.appUpdateShowOrNot.value =
//                                         false;
//                                     _navigateToPlayStore2();
//                                   },
//                                   child: Text(
//                                     "Update Now",
//                                     style: textTheme.bodyLarge?.copyWith(
//                                       color: Colors.white,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                         GestureDetector(
//                           child: Text(
//                             apiController
//                                         .streamModel
//                                         .value
//                                         ?.is_permanent_dialog !=
//                                     false
//                                 ? "Exit"
//                                 : "Maybe Later!",
//                             style: textTheme.bodyLarge?.copyWith(
//                               color: Colors.grey.shade600,
//                             ),
//                           ),
//                           onTap: () {
//                             ///may be click listener....
//                             apiController.appUpdateShowOrNot.value = false;
//                           },
//                         ),
//                         const SizedBox(height: 20),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           Obx(
//             () => Visibility(
//               visible: apiController.showSplashConfig.value,
//               child: Container(
//                 color: Color(0xff28569c).withValues(alpha: 0.5),
//                 child: Dialog(
//                   backgroundColor: Color(0xff28569c),
//                   shape: const RoundedRectangleBorder(
//                     borderRadius: BorderRadius.all(Radius.circular(10.0)),
//                   ),
//                   insetPadding: const EdgeInsets.all(10),
//                   child: SizedBox(
//                     width: MediaQuery.of(context).size.width,
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         const Padding(
//                           padding: EdgeInsets.all(10.0),
//                           child: Image(
//                             height: 120,
//                             width: 120,
//                             image: AssetImage("images/appsplashlay.png"),
//                           ),
//                         ),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.end,
//                           children: [
//                             Padding(
//                               padding: const EdgeInsets.only(right: 30.0),
//                               child: CircularCountDownTimer(
//                                 duration: apiController.splashTimerValue.value,
//                                 initialDuration: 0,
//                                 controller: _controller,
//                                 width: 50,
//                                 height: 50,
//                                 ringColor: Color(0xff00327a),
//                                 ringGradient: null,
//                                 fillColor: Color(0xff6dbd58),
//                                 fillGradient: null,
//                                 backgroundColor: Color(0xff00327a),
//                                 backgroundGradient: null,
//                                 strokeWidth: 4.0,
//                                 strokeCap: StrokeCap.round,
//                                 textStyle: TextStyle(
//                                     fontSize: 18.0, color: Colors.white, fontWeight: FontWeight.bold),
//                                 textAlign: TextAlign.center,
//                                 textFormat: CountdownTextFormat.S,
//                                 isReverse: false,
//                                 isReverseAnimation: false,
//                                 isTimerTextShown: true,
//                                 autoStart: true,
//                                 onStart: () {
//                                   debugPrint('Countdown Started');
//                                 },
//                                 onComplete: () {
//                                   debugPrint('Countdown Ended');
//                                   isClickable.value = true;
//                                 },
//                                 onChange: (String timeStamp) {
//
//                                 },
//                                 timeFormatterFunction: (defaultFormatterFunction, duration) {
//                                   if (duration.inSeconds == 0) {
//                                     return "Start";
//                                   } else {
//                                     return Function.apply(defaultFormatterFunction, [duration]);
//                                   }
//                                 },
//                               ),
//                             )
//                           ],
//                         ),
//                         const SizedBox(height: 30),
//                         Text(
//                           apiController.appConfiguration.title.toString(),
//                           style: textTheme.titleLarge?.copyWith(
//                             color: Colors.white,
//                             fontWeight: FontWeight.bold,
//                             fontSize: 22,
//                           ),
//                         ),
//                         const SizedBox(height: 20),
//                         Padding(
//                           padding: const EdgeInsets.only(
//                             left: 10.0,
//                             right: 10.0,
//                           ),
//                           child: AnimatedTextKit(
//                               totalRepeatCount: 1,
//                               animatedTexts: [
//                                 TypewriterAnimatedText(
//                                   apiController.appConfiguration.heading.toString(),
//                                   textAlign: TextAlign.center,
//                                   speed: Duration(milliseconds: 70),
//                                   textStyle: textTheme.bodyMedium?.copyWith(
//                                     color: Colors.white,
//                                     fontSize: 17,
//                                   ),
//                                 )])
//                           ,
//                         ),
//                         const SizedBox(height: 20),
//                         Visibility(
//                           visible:
//                               apiController.appConfiguration.showButton == true
//                               ? true
//                               : false,
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                             children: [
//                               Expanded(
//                                 child: Padding(
//                                   padding: const EdgeInsets.only(
//                                     left: 35,
//                                     right: 35,
//                                     top: 30.0,
//                                     bottom: 10.0,
//                                   ),
//                                   child: ElevatedButton(
//                                     style: ElevatedButton.styleFrom(
//                                       backgroundColor: const Color(0xff00327a),
//                                     ),
//                                     onPressed: () {
//                                       ///splash button click.....
//                                       Uri googleUrl = Uri.parse(apiController.appConfiguration.button_link);
//                                       _launchInBrowserView(googleUrl);
//                                       apiController.showSplashConfig.value = false;
//                                     },
//                                     child: Text(
//                                       apiController.appConfiguration.button_heading
//                                                                   .toString(),
//                                       style: textTheme.bodyLarge?.copyWith(
//                                         color: Colors.white,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         GestureDetector(
//                           onTap: isClickable.value== true
//                               ? () {
//                             // Handle the click action here
//                             apiController.showSplashConfig.value = false;
//                           }
//                               : null,
//                           child:Text(
//                             "Skip",
//                             style: textTheme.bodyLarge?.copyWith(
//                               color: isClickable.value== true ? Color(0xff00327a)
//                               :Colors.grey.shade600 ,
//                               fontWeight: isClickable.value== true ? FontWeight.bold
//                                   : FontWeight.normal,
//                               fontSize: isClickable.value== true ? 18
//                                   : 16
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 20),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Future<void> _launchInBrowserView(Uri url) async {
//     if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
//       debugPrint("Could not launch $url");
//     }
//   }
//
//
//   Future<void> _navigateToPlayStore() async {
//     try {
//       await StoreRedirect.redirect(iOSAppId: "123456789");
//       apiController.dataResource.saveRatingValue(true);
//     } on PlatformException catch (e) {
//       debugPrint("Could not open store: ${e.message}");
//     } catch (e) {
//       debugPrint("An unknown error occurred: $e");
//     }
//   }
//
//   Future<void> _navigateToPlayStore2() async {
//     try {
//       await StoreRedirect.redirect(iOSAppId: "123456789");
//     } on PlatformException catch (e) {
//       debugPrint("Could not open store: ${e.message}");
//     } catch (e) {
//       debugPrint("An unknown error occurred: $e");
//     }
//   }
//
//   void _onItemTapped(int index) {
//     selectedTabIndex.value = index;
//     count++;
//     if (count == navigationTap) {
//       if (AppConstants.adLoadStatus.toLowerCase() != "none") {
//         if (AppConstants.adLoadStatus.toLowerCase() == "loaded") {
//           _adManager.checkAdLoadedOrNot(
//             (value) {
//               if (value.toLowerCase() == "finish") {
//                 count = 0;
//                 apiController.loadAdAtLocation(AppConstants.locationTap);
//               }
//             },
//             tapProvider,
//             "",
//           );
//         } else {
//           count = 0;
//         }
//       } else {
//         count = 0;
//       }
//     }
//     setState(() {
//       _selectedTabIndex = index;
//     });
//   }
//
//   Future<bool> _onWillPop() async {
//     setState(() {
//       _selectedTabIndex = 0;
//     });
//
//     if (AppConstants.currentDestination == "football") {
//       SystemNavigator.pop();
//       return false;
//       // return true;
//     } else {
//       return false;
//     }
//   }
// }

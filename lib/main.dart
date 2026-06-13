import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:footscore/routing/approutes.dart';
import 'package:footscore/routing/appscreens.dart';
import 'package:footscore/uiscreens/app_open_ad_manager.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

import 'codeutils/notification.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    try {
      await FirebaseIosService.initialize();
    } catch (e, st) {
      debugPrint("FirebaseIosService.initialize failed: $e");
    }

    FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };
    // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  } catch (e) {
    debugPrint("Exception");
  }

  runApp(const FootScoreApp());
}

class FirebaseIosService {
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    try {
      await Firebase.initializeApp();
       // Request permissions for iOS
      final messaging = FirebaseMessaging.instance;
      NotificationSettings settings= await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('User granted permission');
      } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
        print('User granted provisional permission');
      } else {
        print('User declined or has not accepted permission');
      }

      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler,);
      try {
        await subscribeToTopic("event_com.lf.live.football.tv.hd.streaming");
      } catch (e, st) {
        print("Error subscribing to topic: $e");
      }
      _initializeLocalNotifications();
      _configureForegroundMessageHandler();
    } catch (e, st) {
      print("FirebaseIosService.initialize failed: $e");
    }
  }

  static Future<void> _initializeLocalNotifications() async {
    const DarwinInitializationSettings darwinSettings =
        DarwinInitializationSettings();

    const InitializationSettings initSettings = InitializationSettings(
      iOS: darwinSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );
  }

  // Legacy handler for older iOS versions
  static void _onDidReceiveLocalNotification(
    int id,
    String? title,
    String? body,
    String? payload,
  ) {}

  // Handles what happens when a user taps a notification
  static void _onNotificationTap(NotificationResponse response) {
    final String? payload = response.payload;
    if (payload != null && payload.isNotEmpty) {
      if (payload.startsWith("http://") || payload.startsWith("https://")) {
        launchUrl(Uri.parse(payload), mode: LaunchMode.externalApplication);
      } else {
        // Here you would navigate to your HomeScreen
        print("Navigate to HomeScreen or other internal route");
      }
    }
  }

  // This handles messages that arrive while the app is in the FOREGROUND
  static void _configureForegroundMessageHandler() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Foreground message received: ${message.data}");
      _showForegroundNotification(message);
    });
  }

  static Future<void> _showForegroundNotification(RemoteMessage message) async {
    final data = message.data;
    final packageInfo = await PackageInfo.fromPlatform();

    if (data['appname']?.toLowerCase() !=
            packageInfo.packageName.toLowerCase() ||
        data['type']?.toLowerCase() != "personalnotification") {
      return;
    }

    final String title = data['title'] ?? 'Test';
    final String description = data['description'] ?? 'Test Notification';
    final String imageUrl = data['image'] ?? '';
    final String urlToOpen = data['url'] ?? '';

    String? largeIconPath;
    if (imageUrl.isNotEmpty) {
      try {
        // largeIconPath = await _downloadAndSaveFile(imageUrl, 'largeIcon');
      } catch (e) {
        print("Error downloading image: $e");
      }
    }

    final DarwinNotificationDetails darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      attachments: largeIconPath != null
          ? [DarwinNotificationAttachment(largeIconPath)]
          : null,
    );

    final NotificationDetails notificationDetails = NotificationDetails(
      iOS: darwinDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      description,
      notificationDetails,
      payload: urlToOpen,
    );
  }
}

Future<void> subscribeToTopic(String topicName) async {
  final packageInfo = await PackageInfo.fromPlatform();
  try {
    final fcm = FirebaseMessaging.instance;
    final token = await fcm.getToken();
    debugPrint("FCM TOKEN: $token");

    if (token == null) {
      debugPrint("FCM token is null, cannot subscribe");
      return;
    }

    await fcm.subscribeToTopic(topicName);
    debugPrint("Subscribed to topic: $topicName");
  } catch (e) {
    debugPrint("Topic subscription error: $e ${packageInfo.packageName}");
  }
}




class FootScoreApp extends StatefulWidget {
  const FootScoreApp({super.key});

  @override
  State<FootScoreApp> createState() => _FootScoreAppState();
}

class _FootScoreAppState extends State<FootScoreApp>
    with WidgetsBindingObserver {
  final AppOpenAdManager _adManager = AppOpenAdManager();

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    _adManager.loadAd();
    // Check permissions after the first frame is rendered

    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _adManager.showAdIfAvailable();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      getPages: AppScreens.screens,
      initialRoute: Routes.firstpage,
    );
  }
}

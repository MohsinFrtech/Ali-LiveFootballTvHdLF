import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'appconstants.dart';

class NotificationService extends GetxController {
  NotificationService._();

  static final instance = NotificationService._();

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  Future requestNotificationPermission() async {
    final status = await Permission.notification.request();
    if (status.isGranted) {
      return AppConstants.permissionGranted;
    } else if (status.isDenied) {
      return AppConstants.permissionDenied;
    } else if (status.isPermanentlyDenied) {
      return AppConstants.permissionPermanentlyDenied;
    } else {
      return await requestNotificationPermission();
    }
  }

  void configureLocalNotifications() {
    var initializationSettingsAndroid =
    const AndroidInitializationSettings('app_icon');

    var initializationSettingsIOS = const DarwinInitializationSettings();
    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void openAndroidSettings() async {
    openAppSettings(); //for Android only
  }

  Future<void> showNotification(String title, String body) async {
    var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      importance: Importance.max,
      priority: Priority.high,
    );

    var iOSPlatformChannelSpecifics = const DarwinNotificationDetails(
      categoryIdentifier: "plainCategory",
    );
    var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
    );
  }
}

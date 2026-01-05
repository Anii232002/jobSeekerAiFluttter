import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestSoundPermission: false,
          requestBadgePermission: false,
          requestAlertPermission: false,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        // Handle notification tap
      },
    );

    // Initialize Timezone
    try {
      tz_data.initializeTimeZones();
      final dynamic tzResult = await FlutterTimezone.getLocalTimezone();

      String? timeZoneName;
      if (tzResult is String) {
        timeZoneName = tzResult;
      } else {
        // Handle web-specific TimezoneInfo or other objects
        try {
          // Attempt to access 'name' property commonly used in these objects
          timeZoneName = (tzResult as dynamic).name;
        } catch (_) {
          // Fallback to extraction from toString if it contains the pattern
          final str = tzResult.toString();
          if (str.contains('(') && str.contains(',')) {
            timeZoneName = str
                .substring(str.indexOf('(') + 1, str.indexOf(','))
                .trim();
          } else {
            timeZoneName = str;
          }
        }
      }

      tz.setLocalLocation(tz.getLocation(timeZoneName ?? 'UTC'));
    } catch (e) {
      // Fallback to UTC if detection fails or location is invalid
      debugPrint('Timezone initialization failed: $e. Falling back to UTC.');
      tz.setLocalLocation(tz.getLocation('UTC'));
    }
  }

  Future<void> requestPermissions() async {
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'job_seeker_ai_channel',
          'Job Matches',
          channelDescription: 'Notifications for new job matches',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: true,
        );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails();

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }

  Future<void> scheduleDailyNotification() async {
    // Schedule a daily notification (Placeholder for now)
    // In a real app, we would use zonedSchedule
  }
}

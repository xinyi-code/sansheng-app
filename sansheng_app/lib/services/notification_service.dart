import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class NotificationService {
  static final NotificationService instance = NotificationService._init();
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  // 通知点击回调
  void Function(Map<String, dynamic>)? _onNotificationTapCallback;

  NotificationService._init();

  Future<void> init() async {
    // 初始化时区
    tz_data.initializeTimeZones();

    // 设置本地时区
    tz.setLocalLocation(tz.getLocation('Asia/Shanghai'));

    // Android 设置
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS 设置
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );
  }

  // 请求通知权限（iOS）
  Future<bool> requestPermissions() async {
    if (Platform.isIOS) {
      final result = await _notifications
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      return result ?? false;
    }
    return true;
  }

  // 调度每日提醒
  Future<void> scheduleDailyReminders(
      List<String> times, String question) async {
    await _notifications.cancelAll(); // 先清除所有旧通知

    for (int i = 0; i < times.length; i++) {
      final timeParts = times[i].split(':');
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      if (Platform.isIOS) {
        // iOS 使用专门的调度方法
        await _scheduleIOSReminder(i, hour, minute, question);
      } else {
        // Android 使用 zonedSchedule
        await _scheduleAndroidReminder(i, hour, minute, question);
      }
    }
  }

  // iOS 通知调度
  Future<void> _scheduleIOSReminder(
      int id, int hour, int minute, String question) async {
    // iOS 使用 pending notification request
    await _notifications.zonedSchedule(
      id,
      '自我观察时间到',
      question,
      _nextInstanceOfTime(hour, minute),
      const NotificationDetails(
        iOS: DarwinNotificationDetails(
          sound: 'default',
          badgeNumber: 1,
          presentAlert: true,
          presentSound: true,
          presentBadge: true,
        ),
      ),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  // Android 通知调度
  Future<void> _scheduleAndroidReminder(
      int id, int hour, int minute, String question) async {
    await _notifications.zonedSchedule(
      id,
      '自我观察时间到',
      question,
      _nextInstanceOfTime(hour, minute),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'sansheng_reminders',
          '三省吾身提醒',
          channelDescription: '每日提醒功能',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  // 计算下次提醒时间
  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
        tz.local, now.year, now.month, now.day, hour, minute);

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  // 取消所有提醒
  Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }

  // 获取已调度的通知列表
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  // 处理通知点击
  void _onNotificationTap(NotificationResponse response) {
    // 通知点击后，执行回调函数
    if (_onNotificationTapCallback != null) {
      // 构建payload数据
      final payload = response.payload != null && response.payload!.isNotEmpty
          ? {'data': response.payload}
          : <String, dynamic>{};

      _onNotificationTapCallback!(payload);
    }
  }

  // 设置通知点击回调
  void setOnNotificationTap(void Function(Map<String, dynamic>) callback) {
    _onNotificationTapCallback = callback;
  }

  // 显示即时通知
  Future<void> showImmediateNotification(String title, String body) async {
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      iOS: DarwinNotificationDetails(
        sound: 'default',
        presentAlert: true,
        presentSound: true,
        presentBanner: true,
        badgeNumber: 1,
      ),
      android: AndroidNotificationDetails(
        'sansheng_immediate',
        '三省吾身',
        channelDescription: '即时通知通道',
        importance: Importance.high,
        priority: Priority.high,
      ),
    );

    await _notifications.show(
      999,
      title,
      body,
      platformChannelSpecifics,
    );
  }
}

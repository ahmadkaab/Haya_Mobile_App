import 'dart:math';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/foundation.dart';
import 'package:hijri/hijri_calendar.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  final List<String> _morningMessages = [
    "Another day, another chance to not mess up your streak. Make it count, chief. 🦅",
    "Woke up for Fajr? 10/10. Woke up without relapsing? 100/100. Keep that energy today. 🔥",
    "Your streak is looking healthier than a Biryani without elaichi. Keep it going! 🍛",
    "Bismillah. Today is a good day to lower your gaze and raise your standards. 👑",
  ];

  final List<String> _afternoonMessages = [
    "Lowering your gaze > Liking her story. Stay focused king. 👑",
    "Hey. Yes, you. Drink some water. Make some dua. Keep surviving. 🌊",
    "Just a friendly reminder: that 5 seconds of pleasure isn't worth 5 hours of regret. Hold the line. 🛑",
    "If you can resist checking your phone every 5 mins, you can resist this urge. We believe in you. 🤝",
    "🚨 Alert: Boredom detected. Boredom = Danger. Go do 10 pushups.",
  ];

  final List<String> _nightMessages = [
    "You up? Yeah, so are the angels writing your good deeds. Go to sleep with Wudu. 💧",
    "Bro, drop the phone. Pick up the Quran. It's a much better scroll. 📖",
    "Shaytan is trying to cook right now. Don't let him. Go to sleep. 🥊",
    "POV: You're alone in your room and your Nafs is whispering. Close the app, say A'udhu billah. 🛡️",
    "Your FBI agent is watching. But more importantly, Allah is watching. Keep the streak alive! 👑",
  ];

  Future<void> init() async {
    if (_initialized) return;

    tz.initializeTimeZones();
    // In a real app we'd use flutter_timezone to get local, but UTC works for relative offsets.
    tz.setLocalLocation(tz.getLocation('UTC')); 

    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false, // We request manually
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(settings);
    _initialized = true;
  }

  Future<bool> requestPermission() async {
    bool granted = false;
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final result = await _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>()?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      granted = result ?? false;
    } else if (defaultTargetPlatform == TargetPlatform.android) {
       final result = await _plugin.resolvePlatformSpecificImplementation<
       AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
       granted = result ?? false;
    }
    return granted;
  }

  Future<void> scheduleDailyReminders() async {
    await _plugin.cancelAll(); // Clear existing

    // We simply schedule 3 notifications roughly 4, 10, and 16 hours from now for demonstration.
    // In production, we would schedule these at exact absolute local times (e.g. 9am, 3pm, 9pm).
    final now = tz.TZDateTime.now(tz.local);
    
    // Pick random messages
    final rnd = Random();
    final morning = _morningMessages[rnd.nextInt(_morningMessages.length)];
    final afternoon = _afternoonMessages[rnd.nextInt(_afternoonMessages.length)];
    
    // Hijri Context Logic for Night Messages (Looking towards tomorrow)
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final hijriTomorrow = HijriCalendar.fromDate(tomorrow);
    
    bool isWhiteDayTomorrow = hijriTomorrow.hDay >= 13 && hijriTomorrow.hDay <= 15;
    bool isMondayTomorrow = tomorrow.weekday == DateTime.monday;
    bool isThursdayTomorrow = tomorrow.weekday == DateTime.thursday;
    bool isJumuahTomorrow = tomorrow.weekday == DateTime.friday;

    List<String> contextualNightQueue = [];
    if (isWhiteDayTomorrow) {
      contextualNightQueue.add("Tomorrow is the ${hijriTomorrow.hDay}th White Day. Fasting brings immense reward and lowers your gaze. 🌙");
    }
    if (isJumuahTomorrow) {
      contextualNightQueue.add("Tomorrow is Friday. Sleep with wudu, prepare for Surah Kahf. Don't slip tonight. 🕌");
    }
    if (isMondayTomorrow || isThursdayTomorrow) {
      contextualNightQueue.add("Tomorrow is ${isMondayTomorrow ? "Monday" : "Thursday"}. A Sunnah day to fast. Fasting is a shield! 🛡️");
    }

    String night;
    if (contextualNightQueue.isNotEmpty) {
      night = contextualNightQueue.first; // Prioritize context
    } else {
      night = _nightMessages[rnd.nextInt(_nightMessages.length)];
    }

    await _schedule(1, "Haya Morning", morning, now.add(const Duration(hours: 4)));
    await _schedule(2, "Haya Afternoon Check", afternoon, now.add(const Duration(hours: 10)));
    await _schedule(3, "Haya Late Night", night, now.add(const Duration(hours: 16)));
  }

  Future<void> _schedule(int id, String title, String body, tz.TZDateTime time) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'haya_daily',
      'Daily Reminders',
      channelDescription: 'Motivational reminders to keep your streak alive',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      time,
      details,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  // A convenient method to test them immediately
  Future<void> sendTestNotification() async {
    final msg = _nightMessages[Random().nextInt(_nightMessages.length)];
    const details = NotificationDetails(
      android: AndroidNotificationDetails('haya_test', 'Tests', importance: Importance.max, priority: Priority.high),
    );
    await _plugin.show(0, "Testing Notifications", msg, details);
  }
}

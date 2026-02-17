import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../models/record.dart';
import 'notification_service.dart';

class ReminderScheduler {
  static Future<void> schedule(List<Record> records) async {
    // Cancel old reminder
    await NotificationService.plugin.cancel(100);

    // If already has expense today → don't notify
    if (_hasTodayExpense(records)) return;

    final now = tz.TZDateTime.now(tz.local);

    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      17, // 9 PM
    );

    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    await NotificationService.plugin.zonedSchedule(
  100,
  'Expense Reminder',
  'You haven’t added today’s expenses yet 📒',
  scheduled,
  const NotificationDetails(
    android: AndroidNotificationDetails(
      'daily_reminder',
      'Daily Reminder',
      importance: Importance.high,
      priority: Priority.high,
    ),
  ),
  androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle, // ✅ ADD THIS
  uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
  matchDateTimeComponents: DateTimeComponents.time,
);

  }

  static bool _hasTodayExpense(List<Record> records) {
    final today = DateTime.now();

    return records.any(
      (r) =>
          r.type == RecordType.expense &&
          r.date.year == today.year &&
          r.date.month == today.month &&
          r.date.day == today.day,
    );
  }
}

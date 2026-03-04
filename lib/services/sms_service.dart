import 'package:telephony/telephony.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SmsService {
  static final Telephony telephony = Telephony.instance;

  static void startListening() {
  telephony.listenIncomingSms(
    onNewMessage: _onNewMessage,
    onBackgroundMessage: backgroundSmsHandler,
    listenInBackground: true,
  );
}

  static Future<void> _onNewMessage(SmsMessage message) async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) return;

    final body = message.body ?? "";
    final dateMillis = message.date ?? 0;

    if (!_isTransaction(body)) return;

    final parsed = _parseTransaction(body);
    if (parsed == null) return;

    final recordDate =
        DateTime.fromMillisecondsSinceEpoch(dateMillis);

    await supabase.from('records').insert({
      'user_id': user.id,
      'title': parsed['title'],
      'amount': parsed['amount'],
      'record_type': parsed['type'],
      'record_date':
          recordDate.toIso8601String().split('T').first,
      'category_name': 'miscellaneous',
      'is_recurring': false,
    });
  }

  static bool _isTransaction(String body) {
    final lower = body.toLowerCase();
    return lower.contains("debited") ||
        lower.contains("credited") ||
        lower.contains("spent") ||
        lower.contains("withdrawn");
  }

  static Map<String, dynamic>? _parseTransaction(String body) {
    final regex =
        RegExp(r'(Rs\.?|INR|₹)\s?([\d,]+)', caseSensitive: false);

    final match = regex.firstMatch(body);
    if (match == null) return null;

    final amount =
        double.tryParse(match.group(2)!.replaceAll(',', ''));

    if (amount == null) return null;

    final lower = body.toLowerCase();

    final type =
        lower.contains("credited") ? "income" : "expense";

    return {
      'title': "SMS Transaction",
      'amount': amount,
      'type': type,
    };
  }
}
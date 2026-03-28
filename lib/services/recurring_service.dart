import 'package:supabase_flutter/supabase_flutter.dart';

class RecurringService {
  static Future<void> processRecurring() async {
  final supabase = Supabase.instance.client;

  final today = DateTime.now();

  final rules = await supabase
      .from('recurring_rules')
      .select()
      .eq('is_active', true);

  for (final rule in rules) {
    DateTime nextRun = DateTime.parse(rule['next_run_date']);

    final amount = (rule['amount'] as num).toDouble();
    final type = rule['record_type'];
    final accountId = rule['account_id'];

    while (!nextRun.isAfter(today)) {
      final recordDate = nextRun.toIso8601String().split('T').first;

      // 1️⃣ Insert record
      await supabase.from('records').insert({
        'user_id': rule['user_id'],
        'account_id': accountId,
        'title': rule['title'],
        'amount': amount,
        'record_type': type,
        'record_date': recordDate, // ✅ FIXED
        'is_recurring': true,
        'category_name': rule['category_name'],
        'budget_id': rule['budget_id'],
        'recurring_rule_id': rule['rule_id'],
      });

      // 2️⃣ Update balance
      if (type == 'income') {
        await supabase.rpc('increment_balance', params: {
          'acc_id': accountId,
          'amount_val': amount,
        });
      } else {
        await supabase.rpc('decrement_balance', params: {
          'acc_id': accountId,
          'amount_val': amount,
        });
      }

      // 3️⃣ Update budget
      if (rule['budget_id'] != null) {
        final budget = await supabase
            .from('budgets')
            .select('current_amount')
            .eq('budget_id', rule['budget_id'])
            .single();

        double current = (budget['current_amount'] ?? 0).toDouble();

        await supabase
            .from('budgets')
            .update({'current_amount': current + amount})
            .eq('budget_id', rule['budget_id']);
      }

      // 4️⃣ Move to next date
      switch (rule['frequency']) {
        case 'daily':
          nextRun = nextRun.add(const Duration(days: 1));
          break;
        case 'weekly':
          nextRun = nextRun.add(const Duration(days: 7));
          break;
        case 'monthly':
          nextRun =
              DateTime(nextRun.year, nextRun.month + 1, nextRun.day);
          break;
        case 'yearly':
          nextRun =
              DateTime(nextRun.year + 1, nextRun.month, nextRun.day);
          break;
      }
    }

    // 5️⃣ Save updated next_run_date
    await supabase
        .from('recurring_rules')
        .update({
          'next_run_date':
              nextRun.toIso8601String().split('T').first,
        })
        .eq('rule_id', rule['rule_id']);
  }
}
}
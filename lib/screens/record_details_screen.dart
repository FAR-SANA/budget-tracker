import 'package:flutter/material.dart';
import '../models/record.dart';
import 'edit_record_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_colors.dart';

class RecordDetailsScreen extends StatefulWidget {
  final Record record;

  const RecordDetailsScreen({super.key, required this.record});

  @override
  State<RecordDetailsScreen> createState() => _RecordDetailsScreenState();
}

class _RecordDetailsScreenState extends State<RecordDetailsScreen> {
  String? repeatType;
  String? accountName;
  String? budgetTitle;

  @override
  void initState() {
    super.initState();
    _loadAccount();
    _loadRepeatType();
     _loadBudget();
  }

  Future<void> _loadRepeatType() async {
    if (widget.record.recurringRuleId == null) {
      setState(() {
        repeatType = null;
      });
      return;
    }

    final data = await Supabase.instance.client
        .from('recurring_rules')
        .select('frequency')
        .eq('rule_id', widget.record.recurringRuleId!)
        .single();

    if (!mounted) return;

    setState(() {
      repeatType = data['frequency'];
    });
  }

  Future<void> _loadAccount() async {
    try {
      final data = await Supabase.instance.client
          .from('accounts')
          .select('name')
          .eq('account_id', widget.record.accountId)
          .single();

      if (!mounted) return;

      setState(() {
        accountName = data['name'];
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        accountName = "Unknown Account";
      });
    }
  }

Future<void> _loadBudget() async {
  if (widget.record.budgetId == null) {
    setState(() {
      budgetTitle = null;
    });
    return;
  }

  try {
    final data = await Supabase.instance.client
        .from('budgets')
        .select('title')
        .eq('budget_id', widget.record.budgetId!)
        .single();

    if (!mounted) return;

    setState(() {
      budgetTitle = data['title'];
    });
  } catch (e) {
    if (!mounted) return;

    setState(() {
      budgetTitle = "Unknown Budget";
    });
  }
}

  String getRepeatLabel(String? repeat) {
    switch (repeat) {
      case 'daily':
        return 'Daily';
      case 'weekly':
        return 'Weekly';
      case 'monthly':
        return 'Monthly';
      case 'yearly':
        return 'Yearly';
      default:
        return 'Never';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),

      appBar: AppBar(
        title: Text(
          "Record Details",
          style: TextStyle(color: AppColors.text(context)),
        ),
        backgroundColor: AppColors.background(context),
        iconTheme: IconThemeData(color: AppColors.text(context)),
        centerTitle: true,
      ),

      body: SafeArea(
        bottom: true,
        child: SingleChildScrollView(
          // ✅ makes screen scrollable
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _label("Transaction Type"),
              _value(
                widget.record.type == RecordType.income ? "Income" : "Expense",
              ),

              const SizedBox(height: 16),

              _label("Title"),
              _value(widget.record.title),

              const SizedBox(height: 16),

              _label("Amount"),
              _value("₹ ${widget.record.amount.toStringAsFixed(0)}"),

              const SizedBox(height: 16),

              _label("Date"),
              _value(
                "${widget.record.date.day}/${widget.record.date.month}/${widget.record.date.year}",
              ),

              const SizedBox(height: 20),

              // ACCOUNT
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.primary(context),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    accountName ?? "Loading...",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // CATEGORY + REPEAT
              Row(
                children: [
                  // CATEGORY
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.incomeCard(context),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Image.asset(
                            "assets/icons/categories/${widget.record.category}.png",
                            width: 20,
                            height: 20,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              widget.record.category,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // REPEAT
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.incomeCard(context),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: widget.record.repeatType == null
                                  ? Colors.transparent
                                  : AppColors.primary(
                                      context,
                                    ).withOpacity(0.15),
                            ),
                            child: Icon(
                              widget.record.repeatType == null
                                  ? Icons.radio_button_unchecked
                                  : Icons.check_circle,
                              size: 20,
                              color: AppColors.text(context),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              getRepeatLabel(repeatType),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

            // 🔥 BUDGET DISPLAY
Container(
  width: double.infinity,
  padding: const EdgeInsets.symmetric(vertical: 14),
  decoration: BoxDecoration(
    color: AppColors.incomeCard(context),
    borderRadius: BorderRadius.circular(12),
  ),
  child: Center(
    child: Text(
      budgetTitle ?? "No Budget Linked",
      style: TextStyle(
        color: budgetTitle == null
            ? AppColors.subText(context)
            : AppColors.text(context),
        fontWeight: FontWeight.w500,
      ),
    ),
  ),
),

              const SizedBox(height: 24), // ✅ SPACE BETWEEN BUDGET & EDIT
              // EDIT BUTTON
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final updated = await Navigator.push<Record?>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditRecordScreen(record: widget.record),
                      ),
                    );

                    if (!context.mounted) {
                      return; // ✅ prevents async context issue
                    }

                    if (updated != null) {
                      Navigator.pop(
                        context,
                        true,
                      ); // ✅ tell Home "record changed"
                    }
                  },
                  icon: const Icon(Icons.edit, color: Colors.white),
                  label: const Text(
                    "Edit Record",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF142752),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: TextStyle(color: AppColors.subText(context), fontSize: 13),
    );
  }

  Widget _value(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.incomeCard(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.text(context),
        ),
      ),
    );
  }
}

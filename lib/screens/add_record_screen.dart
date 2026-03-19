import 'package:flutter/material.dart';
import '../models/record.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_colors.dart';

class AddRecordScreen extends StatefulWidget {
  final String? voiceAccount;
  final RecordType type;
  final String? voiceTitle;
  final double? voiceAmount;
  final String? voiceCategory;
  final DateTime? voiceDate;

  const AddRecordScreen({
    super.key,
    required this.type,
    this.voiceTitle,
    this.voiceAmount,
    this.voiceCategory,
    this.voiceDate,
    this.voiceAccount,
  });

  @override
  State<AddRecordScreen> createState() => _AddRecordScreenState();
}

class _AddRecordScreenState extends State<AddRecordScreen> {
  final _formKey = GlobalKey<FormState>();

  final titleCtrl = TextEditingController();
  final amountCtrl = TextEditingController();
  final dateCtrl = TextEditingController();

  Future<void> _selectVoiceAccount(String accountName) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final accounts = await Supabase.instance.client
        .from('accounts')
        .select()
        .eq('user_id', user.id);

    for (final acc in accounts) {
      if (acc['name'].toString().toLowerCase() == accountName.toLowerCase()) {
        setState(() {
          selectedAccountId = acc['account_id'];
          selectedAccountName = acc['name'];
        });
        break;
      }
    }
  }

  late RecordType selectedType; // UUID for database
  String? selectedCategory; // name for UI
  String? repeatType; // null = Never
  DateTime? selectedDate;
  String? selectedAccountId;
  String? selectedAccountName;
  String? selectedBudgetId;
  String? selectedBudgetTitle;
  @override
  void initState() {
    super.initState();

    selectedType = widget.type;

    if (widget.voiceTitle != null) {
      titleCtrl.text = widget.voiceTitle!;
    }

    if (widget.voiceAmount != null) {
      amountCtrl.text = widget.voiceAmount!.toString();
    }

    if (widget.voiceCategory != null) {
      selectedCategory = widget.voiceCategory;
    }

    if (widget.voiceDate != null) {
      selectedDate = widget.voiceDate!;
    } else {
      selectedDate = DateTime.now();
    }

    dateCtrl.text =
        "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}";

    if (widget.voiceAccount != null) {
      _selectVoiceAccount(widget.voiceAccount!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text("Add Record"),
        centerTitle: true,
        backgroundColor: AppColors.background(context),
        surfaceTintColor: Colors.transparent, // ✅ prevents grey overlay
        elevation: 0,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ScrollConfiguration(
            behavior:
                const _NoGlowScrollBehavior(), // ✅ removes grey overscroll
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _toggle(),
                  const SizedBox(height: 20),

                  _label("Title *"),
                  _titleField(),
                  const SizedBox(height: 15),

                  _label("Amount *"),
                  _amountField(),
                  const SizedBox(height: 15),

                  _label("Date *"),
                  _dateField(),
                  const SizedBox(height: 15),

                  _accountButton(),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Flexible(child: _categoryButton()),
                      const SizedBox(width: 12),
                      Flexible(child: _repeatButton()),
                    ],
                  ),

                  const SizedBox(height: 20),
                  _linkBudgetButton(),

                  const SizedBox(height: 30),
                  _bottomButtons(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ================= TOGGLE =================
  Widget _toggle() {
    return Row(
      children: [
        _toggleBtn("Income", RecordType.income),
        _toggleBtn("Expense", RecordType.expense),
      ],
    );
  }

  Widget _toggleBtn(String text, RecordType type) {
    final active = selectedType == type;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedType = type),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: active
                ? AppColors.primary(context)
                : AppColors.isDark(context)
                ? const Color(0xFF1B263B) // darker card for dark mode
                : AppColors.incomeCard(context),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: active
                    ? Colors.white
                    : AppColors.isDark(context)
                    ? Colors.white70
                    : AppColors.subText(context),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ================= TITLE =================
  Widget _titleField() {
    return TextFormField(
      controller: titleCtrl,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return "Title is required";
        }
        return null;
      },
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.incomeCard(context),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // ================= AMOUNT =================
  Widget _amountField() {
    return TextFormField(
      controller: amountCtrl,
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return "Amount is required";
        }
        if (double.tryParse(value) == null) {
          return "Enter a valid number";
        }
        return null;
      },
      decoration: InputDecoration(
        prefixText: "₹ ",
        filled: true,
        fillColor: AppColors.incomeCard(context),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // ================= DATE =================
  Widget _dateField() {
    return TextFormField(
      controller: dateCtrl,
      readOnly: true,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Date is required";
        }
        return null;
      },
      onTap: _pickDate,
      decoration: InputDecoration(
        suffixIcon: IconButton(
          icon: Icon(Icons.calendar_today, color: AppColors.text(context)),
          onPressed: _pickDate,
        ),
        filled: true,
        fillColor: AppColors.incomeCard(context),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
        dateCtrl.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  // ================= CATEGORY =================
  Widget _categoryButton() {
    return InkWell(
      onTap: _showCategorySheet,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.incomeCard(context),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            selectedCategory == null
                ? Icon(
                    Icons.wallet,
                    size: 20,
                    color: AppColors.subText(context),
                  )
                : Image.asset(
                    "assets/icons/categories/$selectedCategory.png",
                    width: 20,
                    height: 20,
                  ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                selectedCategory ?? "Category",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: selectedCategory == null
                      ? AppColors.subText(context)
                      : AppColors.text(context),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.keyboard_arrow_down, size: 20),
          ],
        ),
      ),
    );
  }

  void _showCategorySheet() {
    final categories = [
      "miscellaneous",
      "entertainment",
      "household",
      "transport",
      "shopping",
      "education",
      "health",
      "salary",
      "food",
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return Stack(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(color: Colors.transparent),
            ),
            Positioned(
              bottom: 100,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 320,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.background(context),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(color: Colors.black26, blurRadius: 10),
                    ],
                  ),
                  child: SizedBox(
                    height: 280,
                    child: GridView.builder(
                      itemCount: categories.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                          ),
                      itemBuilder: (_, index) {
                        final name = categories[index];

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedCategory = name;
                            });
                            Navigator.pop(context);
                          },
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 26,
                                backgroundColor: AppColors.primary(context),
                                child: Image.asset(
                                  "assets/icons/categories/$name.png",
                                  width: 28,
                                  height: 28,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.text(context),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ================= REPEAT =================
  Widget _repeatButton() {
    return InkWell(
      onTap: _showRepeatSheet,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
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
                color: repeatType == null
                    ? Colors.transparent
                    : Colors.indigo.withOpacity(0.15),
              ),
              child: Icon(
                repeatType == null
                    ? Icons.radio_button_unchecked
                    : Icons.check_circle,
                size: 20,
                color: AppColors.text(context),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(child: Text(repeatType ?? "Repeat")),
          ],
        ),
      ),
    );
  }

  void _showRepeatSheet() {
    final options = ["Never", "Daily", "Weekly", "Monthly", "Yearly"];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return Center(
          child: Container(
            width: 280,
            decoration: BoxDecoration(
              color: AppColors.background(context),
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 10),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: options.map((o) {
                return RadioListTile<String?>(
                  title: Text(
                    o,
                    style: TextStyle(color: AppColors.text(context)),
                  ),
                  value: o == "Never" ? null : o,
                  groupValue: repeatType,
                  onChanged: (val) {
                    setState(() => repeatType = val);
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Future<void> _showBudgetSheet() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final typeFilter = selectedType == RecordType.income
        ? "saving"
        : "spending";

    final budgets = await Supabase.instance.client
        .from('budgets')
        .select()
        .eq('user_id', user.id)
        .eq('budget_type', typeFilter);

    showModalBottomSheet(
      context: context,
      builder: (_) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: budgets.map<Widget>((b) {
            return ListTile(
              title: Text(b['title']),
              subtitle: Text("₹${b['target_amount']}"),
              onTap: () {
                setState(() {
                  selectedBudgetId = b['budget_id'];
                  selectedBudgetTitle = b['title'];
                });
                Navigator.pop(context);
              },
            );
          }).toList(),
        );
      },
    );
  }

  // ================= UI HELPERS =================
  Widget _label(String text) => Text(
    text,
    style: TextStyle(
      fontWeight: FontWeight.w500,
      color: AppColors.text(context),
    ),
  );

  Widget _accountButton() {
    return InkWell(
      onTap: _showAccountSheet,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.primary(context),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              selectedAccountName ?? "Select account",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.keyboard_arrow_down,
              color: Colors.white,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAccountSheet() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final accounts = await Supabase.instance.client
        .from('accounts')
        .select()
        .eq('user_id', user.id);

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: accounts.map<Widget>((acc) {
            return ListTile(
              title: Text(acc['name']),
              subtitle: Text("₹${acc['balance']}"),
              onTap: () {
                setState(() {
                  selectedAccountId = acc['account_id'];
                  selectedAccountName = acc['name'];
                });
                Navigator.pop(context);
              },
            );
          }).toList(),
        );
      },
    );
  }

  Widget _linkBudgetButton() {
    return InkWell(
      onTap: _showBudgetSheet,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.incomeCard(context),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                selectedBudgetTitle ?? "Link to a budget",
                style: TextStyle(
                  color: selectedBudgetTitle == null
                      ? AppColors.subText(context)
                      : AppColors.text(context),
                ),
              ),
            ),
            const Icon(Icons.keyboard_arrow_down),
          ],
        ),
      ),
    );
  }

  Widget _bottomButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary(context), // blue text
          ),
          child: const Text("CANCEL"),
        ),
        ElevatedButton(
          onPressed: _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary(context), // blue
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: const Text(
            "SAVE",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  String _toPgDate(DateTime d) => d.toIso8601String().split('T').first;

  String? _mapRepeatToFrequency(String? repeatType) {
    if (repeatType == null) return null;
    switch (repeatType) {
      case "Daily":
        return "daily";
      case "Weekly":
        return "weekly";
      case "Monthly":
        return "monthly";
      case "Yearly":
        return "yearly";
      default:
        return null;
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (selectedAccountId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please select an account")));
      return;
    }
    if (selectedDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please select a date")));
      return;
    }

    if (selectedCategory == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please select a category")));
      return;
    }

    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("User not logged in")));
      return;
    }

    final dateStr = _toPgDate(selectedDate!);
    final frequency = _mapRepeatToFrequency(repeatType);
    final amount = double.parse(amountCtrl.text);
    if (selectedType == RecordType.expense) {
      final accountData = await supabase
          .from('accounts')
          .select('balance')
          .eq('account_id', selectedAccountId!) // 👈 add !
          .single();

      double currentBalance = (accountData['balance'] ?? 0).toDouble();

      if (amount > currentBalance) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Insufficient balance")));
        return;
      }
    }

    try {
      if (frequency == null) {
        // ================= NORMAL RECORD =================
        await supabase.from('records').insert({
          'user_id': user.id,
          'account_id': selectedAccountId,
          'title': titleCtrl.text.trim(),
          'amount': amount,
          'record_type': selectedType.name,
          'record_date': dateStr,
          'is_recurring': false,
          'category_name': selectedCategory,
          'budget_id': selectedBudgetId,
          'recurring_rule_id': null,
        });

        // Update balance
        if (selectedType == RecordType.income) {
          await supabase.rpc(
            'increment_balance',
            params: {'acc_id': selectedAccountId, 'amount_val': amount},
          );
        } else {
          await supabase.rpc(
            'decrement_balance',
            params: {'acc_id': selectedAccountId, 'amount_val': amount},
          );
        }
        if (selectedBudgetId != null) {
          final budgetData = await supabase
              .from('budgets')
              .select('current_amount')
              .eq('budget_id', selectedBudgetId!)
              .single();

          double current = (budgetData['current_amount'] ?? 0).toDouble();

          double updatedAmount;

          if (selectedType == RecordType.income) {
            updatedAmount = current + amount;
          } else {
            updatedAmount = current + amount; // expense also adds
          }

          await supabase
              .from('budgets')
              .update({'current_amount': updatedAmount})
              .eq('budget_id', selectedBudgetId!);
        }
      } else {
        // ================= RECURRING RECORD =================
        final byweekday = (frequency == "weekly")
            ? [selectedDate!.weekday]
            : null;

        final bymonthday = (frequency == "monthly") ? selectedDate!.day : null;

        final rule = await supabase
            .from('recurring_rules')
            .insert({
              'user_id': user.id,
              'account_id': selectedAccountId, // ✅ FIX HERE
              'budget_id': selectedBudgetId,
              'title': titleCtrl.text.trim(),
              'amount': amount,
              'record_type': selectedType.name,
              'category_name': selectedCategory,
              'frequency': frequency,
              'interval': 1,
              'byweekday': byweekday,
              'bymonthday': bymonthday,
              'start_date': dateStr,
              'next_run_date': dateStr,
              'is_active': true,
            })
            .select('rule_id')
            .single();

        final ruleId = rule['rule_id'];

        await supabase.from('records').insert({
          'user_id': user.id,
          'account_id': selectedAccountId, // ✅ FIX HERE
          'title': titleCtrl.text.trim(),
          'amount': amount,
          'record_type': selectedType.name,
          'record_date': dateStr,
          'is_recurring': true,
          'category_name': selectedCategory,
          'budget_id': selectedBudgetId,
          'recurring_rule_id': ruleId,
        });

        // Update balance
        if (selectedType == RecordType.income) {
          await supabase.rpc(
            'increment_balance',
            params: {'acc_id': selectedAccountId, 'amount_val': amount},
          );
        }
        if (selectedBudgetId != null) {
          final budgetData = await supabase
              .from('budgets')
              .select('current_amount')
              .eq('budget_id', selectedBudgetId!)
              .single();

          double current = (budgetData['current_amount'] ?? 0).toDouble();

          double updatedAmount;

          if (selectedType == RecordType.income) {
            updatedAmount = current + amount;
          } else {
            updatedAmount = current + amount; // expense also adds
          }

          await supabase
              .from('budgets')
              .update({'current_amount': updatedAmount})
              .eq('budget_id', selectedBudgetId!);
        } else {
          await supabase.rpc(
            'decrement_balance',
            params: {'acc_id': selectedAccountId, 'amount_val': amount},
          );
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Record saved successfully")),
      );

      Navigator.pop(context, selectedAccountId);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }
}

class _NoGlowScrollBehavior extends ScrollBehavior {
  const _NoGlowScrollBehavior();

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child; // removes glow / grey stretch
  }
}

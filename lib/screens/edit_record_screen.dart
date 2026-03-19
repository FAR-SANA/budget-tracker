import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/record.dart';
import '../theme/app_colors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditRecordScreen extends StatefulWidget {
  final Record record;

  const EditRecordScreen({super.key, required this.record});

  @override
  State<EditRecordScreen> createState() => _EditRecordScreenState();
}

class _EditRecordScreenState extends State<EditRecordScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController titleCtrl;
  late TextEditingController amountCtrl;
  late TextEditingController dateCtrl;

  late RecordType selectedType;
  String? selectedCategory;
  String? repeatType;
  late DateTime selectedDate;
  String? selectedAccountId;
  String? selectedBudgetId;
  String? selectedBudgetTitle;
  String? oldBudgetId; // 🔥 track previous budget
  List accounts = [];
  String? selectedAccountName;
  @override
  void initState() {
    super.initState();

    titleCtrl = TextEditingController(text: widget.record.title);
    amountCtrl = TextEditingController(
      text: widget.record.amount.toStringAsFixed(0),
    );

    dateCtrl = TextEditingController(
      text:
          "${widget.record.date.day}/${widget.record.date.month}/${widget.record.date.year}",
    );

    selectedType = widget.record.type;
    selectedCategory = widget.record.category;
    repeatType = widget.record.repeatType;
    selectedDate = widget.record.date;
    selectedAccountId = widget.record.accountId;
    oldBudgetId = widget.record.budgetId;
    selectedBudgetId = widget.record.budgetId;

    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final data = await Supabase.instance.client
        .from('accounts')
        .select()
        .eq('user_id', user.id);

    if (!mounted) return;

    setState(() {
      accounts = data;

      for (var acc in accounts) {
        if (acc['account_id'] == selectedAccountId) {
          selectedAccountName = acc['name'];
          break;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),

      appBar: AppBar(
        title: const Text("Edit Record"),
        centerTitle: true,
        backgroundColor: AppColors.background(context),
        iconTheme: IconThemeData(color: AppColors.text(context)),
        titleTextStyle: TextStyle(
          color: AppColors.text(context),
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),

      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _toggle(),
                const SizedBox(height: 20),

                _label("Title"),
                _input(titleCtrl),
                const SizedBox(height: 16),

                _label("Amount"),
                _input(amountCtrl, prefix: "₹ "),
                const SizedBox(height: 16),

                _label("Date"),
                _dateField(),
                const SizedBox(height: 20),

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

                _budgetButton(),

                const SizedBox(height: 30),

                _bottomButtons(),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- TOGGLE ----------------

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
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: active ? AppColors.primary(context) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: active ? Colors.white : AppColors.subText(context),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- INPUTS ----------------

  Widget _label(String text) => Text(
    text,
    style: TextStyle(
      fontWeight: FontWeight.w500,
      color: AppColors.text(context),
    ),
  );

  // ✅ UPDATED: Allows decimals
  Widget _input(TextEditingController ctrl, {String? prefix}) {
    final isAmount = prefix != null;

    return TextFormField(
      controller: ctrl,

      keyboardType: isAmount
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,

      inputFormatters: isAmount
          ? [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))]
          : null,

      validator: (v) =>
          v == null || v.isEmpty ? "This field is required" : null,

      decoration: InputDecoration(
        prefixText: prefix,
        filled: true,
        fillColor: AppColors.incomeCard(context),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _dateField() {
    return TextFormField(
      controller: dateCtrl,
      readOnly: true,
      onTap: _pickDate,
      style: TextStyle(color: AppColors.text(context)),
      decoration: InputDecoration(
        suffixIcon: Icon(Icons.calendar_today, color: AppColors.text(context)),
        filled: true,
        fillColor: AppColors.incomeCard(context), // ✅ FIXED
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
      initialDate: selectedDate,
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

  // ---------------- BUTTONS ----------------

  Widget _accountButton() {
    return GestureDetector(
      onTap: _showAccountSheet,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.primary(context),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            selectedAccountName ?? "Select account",
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }

  void _showAccountSheet() {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return ListView(
          padding: const EdgeInsets.all(20),
          children: accounts.map((acc) {
            return ListTile(
              title: Text(acc['name']),
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

  Widget _categoryButton() {
    return InkWell(
      onTap: _showCategorySheet, // ✅ you must create this function
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
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.keyboard_arrow_down),
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

  Widget _repeatButton() {
    return InkWell(
      onTap: _showRepeatSheet, // ✅ you must create this function
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.incomeCard(context),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              repeatType == null
                  ? Icons.radio_button_unchecked
                  : Icons.check_circle,
              color: AppColors.text(context),
            ),
            const SizedBox(width: 6),
            Expanded(child: Text(repeatType ?? "Repeat")),
            const Icon(Icons.keyboard_arrow_down),
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
                  title: Text(o),
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

    // 🔥 Filter based on record type
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

  Widget _budgetButton() {
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

  // ---------------- SAVE / CANCEL ----------------

  Widget _bottomButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(foregroundColor: const Color(0xFF142752)),
          child: const Text("CANCEL"),
        ),
        ElevatedButton(
          onPressed: _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary(context),
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

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      // 🔥 1️⃣ Get old record from database
      final oldRecord = await supabase
          .from('records')
          .select()
          .eq('record_id', widget.record.id)
          .single();
      oldBudgetId = oldRecord['budget_id'];

      final oldAmount = (oldRecord['amount'] as num).toDouble();
      final oldType = oldRecord['record_type'];
      final accountId = oldRecord['account_id'];

      // 🔥 2️⃣ Reverse old balance effect
      // 🔥 Reverse old account effect
      if (oldType == 'income') {
        await supabase.rpc(
          'decrement_balance',
          params: {'acc_id': accountId, 'amount_val': oldAmount},
        );
      } else {
        await supabase.rpc(
          'increment_balance',
          params: {'acc_id': accountId, 'amount_val': oldAmount},
        );
      }

      // 🔥 3️⃣ Apply new balance effect
      final newAmount = double.parse(amountCtrl.text);
      final newAccountId = selectedAccountId ?? accountId;

      if (selectedType == RecordType.income) {
        await supabase.rpc(
          'increment_balance',
          params: {'acc_id': newAccountId, 'amount_val': newAmount},
        );
      } else {
        await supabase.rpc(
          'decrement_balance',
          params: {'acc_id': newAccountId, 'amount_val': newAmount},
        );
      }

      String? recurringRuleId = widget.record.recurringRuleId;

      if (repeatType == null) {
        // 🔴 User selected "Never"
        if (recurringRuleId != null) {
          await supabase
              .from('recurring_rules')
              .update({'is_active': false})
              .eq('rule_id', recurringRuleId);
        }

        recurringRuleId = null;
      } else {
        final freq = repeatType!.toLowerCase();

        if (recurringRuleId == null) {
          // 🟢 create new rule
          final rule = await supabase
              .from('recurring_rules')
              .insert({
                'user_id': user.id,
                'account_id': newAccountId,
                'budget_id': selectedBudgetId,
                'title': titleCtrl.text.trim(),
                'amount': double.parse(amountCtrl.text),
                'record_type': selectedType.name,
                'category_name': selectedCategory,
                'frequency': freq,
                'interval': 1,
                'start_date': selectedDate.toIso8601String().split('T').first,
                'next_run_date': selectedDate
                    .toIso8601String()
                    .split('T')
                    .first,
                'is_active': true,
              })
              .select()
              .single();

          recurringRuleId = rule['rule_id'];
        } else {
          // 🔵 update existing rule
          await supabase
              .from('recurring_rules')
              .update({'frequency': freq})
              .eq('rule_id', recurringRuleId);
        }
      }

      // ================= BUDGET UPDATE =================

      // ================= BUDGET UPDATE =================

      // Case 1: Budget changed
      if (oldBudgetId != selectedBudgetId) {
        // 🔴 Remove from old budget
        if (oldBudgetId != null) {
          final oldBudget = await supabase
              .from('budgets')
              .select('current_amount')
              .eq('budget_id', oldBudgetId!)
              .single();

          double oldCurrent = (oldBudget['current_amount'] ?? 0).toDouble();

          await supabase
              .from('budgets')
              .update({'current_amount': oldCurrent - oldAmount})
              .eq('budget_id', oldBudgetId!);
        }

        // 🟢 Add to new budget
        if (selectedBudgetId != null) {
          final newBudget = await supabase
              .from('budgets')
              .select('current_amount')
              .eq('budget_id', selectedBudgetId!)
              .single();

          double newCurrent = (newBudget['current_amount'] ?? 0).toDouble();

          await supabase
              .from('budgets')
              .update({'current_amount': newCurrent + newAmount})
              .eq('budget_id', selectedBudgetId!);
        }
      }
      // Case 2: Same budget, amount changed
      else if (selectedBudgetId != null) {
        final budget = await supabase
            .from('budgets')
            .select('current_amount')
            .eq('budget_id', selectedBudgetId!)
            .single();

        double current = (budget['current_amount'] ?? 0).toDouble();

        // 🔥 Adjust difference only
        double updated = current - oldAmount + newAmount;

        await supabase
            .from('budgets')
            .update({'current_amount': updated})
            .eq('budget_id', selectedBudgetId!);
      }

      // 🔥 4️⃣ Update record table
      await supabase
          .from('records')
          .update({
            'title': titleCtrl.text.trim(),
            'amount': newAmount,
            'record_date': selectedDate.toIso8601String().split('T').first,
            'record_type': selectedType.name,
            'category_name': selectedCategory,
            'account_id': newAccountId,
            'budget_id': selectedBudgetId,
            'is_recurring': repeatType != null,
          })
          .eq('record_id', widget.record.id)
          .eq('user_id', user.id);

      if (!mounted) return;

      Navigator.pop(
        context,
        Record(
          id: widget.record.id,
          title: titleCtrl.text.trim(),
          amount: newAmount,
          date: selectedDate,
          type: selectedType,
          category: selectedCategory ?? "miscellaneous",
          accountId: newAccountId,
          repeatType: repeatType,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }
}

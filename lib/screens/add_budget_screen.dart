import 'package:flutter/material.dart';
import '../models/budget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_colors.dart';

class AddBudgetScreen extends StatefulWidget {
  final BudgetType type;
  const AddBudgetScreen({super.key, required this.type});

  @override
  State<AddBudgetScreen> createState() => _AddBudgetScreenState();
}

class _AddBudgetScreenState extends State<AddBudgetScreen> {
  late BudgetType selectedType;

  final titleCtrl = TextEditingController();
  final amountCtrl = TextEditingController();
  final startDateCtrl = TextEditingController();
  final endDateCtrl = TextEditingController();
  final currentAmountCtrl = TextEditingController();

  DateTime? startDate;
  DateTime? endDate;

  // 🔴 Validation flags
  bool titleError = false;
  bool amountError = false;
  bool startDateError = false;

  @override
  void initState() {
    super.initState();
    selectedType = widget.type;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.background(context),

      appBar: AppBar(
        title: Text(
          "Add Budget",
          style: TextStyle(
            color: AppColors.text(context),
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.background(context),
        iconTheme: IconThemeData(color: AppColors.text(context)),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _typeToggle(),
              const SizedBox(height: 30),

              _label("Title *"),
              _textField(titleCtrl, titleError),
              if (titleError) _errorText("Title is required"),
              const SizedBox(height: 20),

              _label("Target Amount *"),
              _amountField(),

              const SizedBox(height: 20),

              _label("Current Amount"),
              _currentAmountField(),
              if (amountError) _errorText("Amount is required"),
              const SizedBox(height: 20),

              _label("Start Date *"),
              _dateField(startDateCtrl, () => _pickDate(isStart: true)),
              if (startDateError) _errorText("Start date is required"),
              const SizedBox(height: 20),

              _label("End Date"),
              _dateField(endDateCtrl, () => _pickDate(isStart: false)),

              const SizedBox(height: 40),

              _bottomButtons(),
            ],
          ),
        ),
      ),
    );
  }

  // ================= TOGGLE =================
  Widget _typeToggle() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _toggleButton("Saving", BudgetType.saving),
          _toggleButton("Spending", BudgetType.spending),
        ],
      ),
    );
  }

  Widget _toggleButton(String text, BudgetType type) {
    final active = selectedType == type;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedType = type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: active ? AppColors.primary(context) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: active ? Colors.white : AppColors.subText(context),
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ================= FIELDS =================
  Widget _label(String text) {
    return Text(
      text,
      style: TextStyle(
        color: AppColors.text(context),
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _textField(TextEditingController ctrl, bool error) {
    return TextField(
      controller: ctrl,
      style: TextStyle(color: AppColors.text(context)),
      decoration: _inputDecoration(error),
      onChanged: (_) {
        if (error) setState(() => titleError = false);
      },
    );
  }

  Widget _amountField() {
    return TextField(
      controller: amountCtrl,
      style: TextStyle(color: AppColors.text(context)),
      keyboardType: TextInputType.number,
      decoration: _inputDecoration(amountError, prefix: "₹ "),
      onChanged: (_) {
        if (amountError) setState(() => amountError = false);
      },
    );
  }

  Widget _currentAmountField() {
    return TextField(
      controller: currentAmountCtrl,
      style: TextStyle(color: AppColors.text(context)),
      keyboardType: TextInputType.number,
      decoration: _inputDecoration(false, prefix: "₹ "),
    );
  }

  Widget _dateField(TextEditingController ctrl, VoidCallback onTap) {
    return TextField(
      controller: ctrl,
      style: TextStyle(color: AppColors.text(context)),
      readOnly: true,
      onTap: onTap,
      decoration: _inputDecoration(
        startDateError && ctrl == startDateCtrl,
        suffix: IconButton(
          icon: Icon(
            Icons.calendar_today,
            size: 18,
            color: AppColors.text(context),
          ),
          onPressed: onTap,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(
    bool error, {
    String? prefix,
    Widget? suffix,
  }) {
    return InputDecoration(
      prefixText: prefix,
      suffixIcon: suffix,
      filled: true,
      fillColor: AppColors.incomeCard(context),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: error ? Colors.red : Colors.transparent),
      ),
    );
  }

  Widget _errorText(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        text,
        style: const TextStyle(color: Colors.red, fontSize: 12),
      ),
    );
  }

  // ================= DATE PICKER =================
  Future<void> _pickDate({required bool isStart}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          startDate = picked;
          startDateCtrl.text = "${picked.day}/${picked.month}/${picked.year}";
          startDateError = false;
        } else {
          endDate = picked;
          endDateCtrl.text = "${picked.day}/${picked.month}/${picked.year}";
        }
      });
    }
  }

  // ================= BOTTOM BUTTONS =================
  Widget _bottomButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton.icon(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary(context),
          ),
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.chevron_left),
          label: const Text("CANCEL"),
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
    setState(() {
      titleError = titleCtrl.text.trim().isEmpty;
      amountError = amountCtrl.text.trim().isEmpty;
      startDateError = startDate == null;
    });

    if (titleError || amountError || startDateError) return;

    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) return;

    // ✅ calculate values
    final target = double.parse(amountCtrl.text);

    final current = currentAmountCtrl.text.trim().isEmpty
        ? 0
        : double.parse(currentAmountCtrl.text);

    // ✅ validation
    if (current > target) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Current amount cannot exceed target")),
      );
      return;
    }

    try {
      await supabase.from('budgets').insert({
        'user_id': user.id,
        'title': titleCtrl.text.trim(),
        'target_amount': target,
        'current_amount': current,
        'budget_type': selectedType.name,
        'start_date': startDate!.toIso8601String().split('T').first,
        'end_date': endDate?.toIso8601String().split('T').first,
      });

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }
}

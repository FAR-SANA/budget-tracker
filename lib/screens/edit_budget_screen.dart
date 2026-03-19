import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_colors.dart';
import '../models/budget.dart';

class EditBudgetScreen extends StatefulWidget {
  final Budget budget;

  const EditBudgetScreen({super.key, required this.budget});

  @override
  State<EditBudgetScreen> createState() => _EditBudgetScreenState();
}

class _EditBudgetScreenState extends State<EditBudgetScreen> {
  late BudgetType selectedType;

  final titleCtrl = TextEditingController();
  final amountCtrl = TextEditingController();
  final currentAmountCtrl = TextEditingController();
  final startDateCtrl = TextEditingController();
  final endDateCtrl = TextEditingController();

  DateTime? startDate;
  DateTime? endDate;

  @override
  void initState() {
    super.initState();

    final b = widget.budget;

    selectedType = b.type;
    titleCtrl.text = b.title;
    amountCtrl.text = b.targetAmount.toString();
    currentAmountCtrl.text = b.currentAmount.toString();

    startDate = b.startDate;
    endDate = b.endDate;

    if (startDate != null) {
      startDateCtrl.text =
          "${startDate!.day}/${startDate!.month}/${startDate!.year}";
    }

    if (endDate != null) {
      endDateCtrl.text = "${endDate!.day}/${endDate!.month}/${endDate!.year}";
    }
  }

  // ================= UPDATE =================

  Future<void> saveBudget() async {
    final supabase = Supabase.instance.client;

    if (titleCtrl.text.trim().isEmpty ||
        amountCtrl.text.trim().isEmpty ||
        startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill required fields")),
      );
      return;
    }

    try {
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

      // ✅ update DB
      await supabase
          .from('budgets')
          .update({
            'title': titleCtrl.text.trim(),
            'target_amount': target,
            'current_amount': current,
            'budget_type': selectedType.name,
            'start_date': startDate!.toIso8601String().split('T').first,
            'end_date': endDate?.toIso8601String().split('T').first,
          })
          .eq('budget_id', widget.budget.id);

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),

      appBar: AppBar(
        title: Text(
          "Edit Budget",
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
          child: Padding(
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
                _editableField(titleCtrl),

                const SizedBox(height: 20),

                _label("Target Amount *"),
                _editableField(amountCtrl, prefix: "₹ "),

                const SizedBox(height: 20),

                _label("Current Amount"),
                _editableField(currentAmountCtrl, prefix: "₹ "),

                const SizedBox(height: 20),

                _label("Start Date *"),
                _dateField(startDateCtrl, true),

                const SizedBox(height: 20),

                _label("End Date"),
                _dateField(endDateCtrl, false),

                const SizedBox(height: 40),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: saveBudget,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF142752),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      "Save Budget",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================= UI HELPERS =================

  Widget _label(String text) {
    return Text(
      text,
      style: TextStyle(
        color: AppColors.text(context),
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _editableField(TextEditingController ctrl, {String? prefix}) {
    return TextField(
      controller: ctrl,
      style: TextStyle(color: AppColors.text(context)),
      keyboardType: prefix != null ? TextInputType.number : TextInputType.text,
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

  Widget _dateField(TextEditingController ctrl, bool isStart) {
    return TextField(
      controller: ctrl,
      readOnly: true,
      onTap: () => _pickDate(isStart),
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.incomeCard(context),
        suffixIcon: Icon(Icons.calendar_today, color: AppColors.text(context)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Future<void> _pickDate(bool isStart) async {
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
        } else {
          endDate = picked;
          endDateCtrl.text = "${picked.day}/${picked.month}/${picked.year}";
        }
      });
    }
  }

  Widget _typeToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.background(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.subText(context).withOpacity(0.2)),
      ),
      child: Row(
        children: [
          _toggleBox("Saving", BudgetType.saving),
          _toggleBox("Spending", BudgetType.spending),
        ],
      ),
    );
  }

  Widget _toggleBox(String text, BudgetType type) {
    final active = selectedType == type;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedType = type),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: active ? AppColors.primary(context) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: active ? Colors.white : AppColors.text(context),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

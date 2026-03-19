import 'package:flutter/material.dart';
import '../models/budget.dart';
import 'edit_budget_screen.dart';
import '../theme/app_colors.dart';

class BudgetDetailsScreen extends StatefulWidget {
  final Budget budget;

  const BudgetDetailsScreen({super.key, required this.budget});

  @override
  State<BudgetDetailsScreen> createState() => _BudgetDetailsScreenState();
}

class _BudgetDetailsScreenState extends State<BudgetDetailsScreen> {
  late BudgetType selectedType;

  final titleCtrl = TextEditingController();
  final amountCtrl = TextEditingController();
  final currentAmountCtrl = TextEditingController();
  final startDateCtrl = TextEditingController();
  final endDateCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();

    final b = widget.budget;

    selectedType = b.type;
    titleCtrl.text = b.title;
    amountCtrl.text = b.targetAmount.toString();
    currentAmountCtrl.text = b.currentAmount.toString();

    // ✅ Handle dates (ensure your Budget model has these fields)
    if (b.startDate != null) {
      startDateCtrl.text =
          "${b.startDate!.day}/${b.startDate!.month}/${b.startDate!.year}";
    }

    if (b.endDate != null) {
      endDateCtrl.text =
          "${b.endDate!.day}/${b.endDate!.month}/${b.endDate!.year}";
    } else {
      endDateCtrl.text = ""; // optional → empty
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),

      appBar: AppBar(
        title: Text(
          "Budget Details",
          style: TextStyle(
            color: AppColors.text(context),
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true, // ✅ CENTER TITLE
        elevation: 0,
        backgroundColor: AppColors.background(context),
        iconTheme: IconThemeData(color: AppColors.text(context)),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _typeToggle(),

              const SizedBox(height: 30),

              _label("Title"),
              _readOnlyField(titleCtrl),

              const SizedBox(height: 20),

              _label("Target Amount"),
              _readOnlyField(amountCtrl, prefix: "₹ "),

              const SizedBox(height: 20),

              _label("Current Amount"),
              _readOnlyField(currentAmountCtrl, prefix: "₹ "),
              const SizedBox(height: 20),

              _label("Start Date"),
              _readOnlyField(startDateCtrl),

              const SizedBox(height: 20),

              _label("End Date"),
              _readOnlyField(endDateCtrl),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    final updated = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditBudgetScreen(budget: widget.budget),
                      ),
                    );

                    if (updated == true) {
                      Navigator.pop(context, true); // 🔥 THIS IS CRITICAL
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF142752),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    "Edit Budget",
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

  Widget _readOnlyField(TextEditingController ctrl, {String? prefix}) {
    return TextField(
      controller: ctrl,
      readOnly: true,
      style: TextStyle(color: AppColors.text(context)),
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
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF142752) : Colors.transparent,
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
    );
  }
}

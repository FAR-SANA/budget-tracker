import 'package:flutter/material.dart';
import '../models/budget.dart';

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
      backgroundColor: Colors.white,

      appBar: AppBar(
        title: const Text(
          "Add Budget",
          style: TextStyle(
            color: Color(0xFF142752),
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Color(0xFF142752)),
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

              _label("Amount *"),
              _amountField(),
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
        color: const Color(0xFFE3EBFD),
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
            color: active ? const Color(0xFF142752) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: active ? Colors.white : Colors.blue.shade200,
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
      style: const TextStyle(
        color: Color(0xFF142752),
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _textField(TextEditingController ctrl, bool error) {
    return TextField(
      controller: ctrl,
      decoration: _inputDecoration(error),
      onChanged: (_) {
        if (error) setState(() => titleError = false);
      },
    );
  }

  Widget _amountField() {
    return TextField(
      controller: amountCtrl,
      keyboardType: TextInputType.number,
      decoration: _inputDecoration(amountError, prefix: "₹ "),
      onChanged: (_) {
        if (amountError) setState(() => amountError = false);
      },
    );
  }

  Widget _dateField(TextEditingController ctrl, VoidCallback onTap) {
    return TextField(
      controller: ctrl,
      readOnly: true,
      onTap: onTap,
      decoration: _inputDecoration(
        startDateError && ctrl == startDateCtrl,
        suffix: IconButton(
          icon: const Icon(Icons.calendar_today, size: 18),
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
      fillColor: const Color(0xFFE8EEFF),
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
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.chevron_left),
          label: const Text("CANCEL"),
        ),
        ElevatedButton(
          onPressed: _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF142752),
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

  void _save() {
    setState(() {
      titleError = titleCtrl.text.trim().isEmpty;
      amountError = amountCtrl.text.trim().isEmpty;
      startDateError = startDate == null;
    });

    if (titleError || amountError || startDateError) return;

    Navigator.pop(
      context,
      Budget(
        title: titleCtrl.text,
        targetAmount: double.parse(amountCtrl.text),
        type: selectedType,
      ),
    );
  }
}

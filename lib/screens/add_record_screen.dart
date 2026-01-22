import 'package:flutter/material.dart';
import '../models/record.dart';

class AddRecordScreen extends StatefulWidget {
  final RecordType type;
  const AddRecordScreen({super.key, required this.type});

  @override
  State<AddRecordScreen> createState() => _AddRecordScreenState();
}

class _AddRecordScreenState extends State<AddRecordScreen> {
  final _formKey = GlobalKey<FormState>();

  final titleCtrl = TextEditingController();
  final amountCtrl = TextEditingController();
  final dateCtrl = TextEditingController();

  late RecordType selectedType;
  String? selectedCategory;
  String? repeatType; // null = Never
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    selectedType = widget.type;
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text("Add Record"),
        centerTitle: true,
        backgroundColor: const Color(0xFFF7F4FB),
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

                  _primaryButton("Select account"),
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
            color: active ? const Color(0xFF142752) : const Color(0xFFE3EBFD),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: active ? Colors.white : Colors.grey,
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
        fillColor: const Color(0xFFE3EBFD),
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
        fillColor: const Color(0xFFE3EBFD),
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
          icon: const Icon(Icons.calendar_today),
          onPressed: _pickDate,
        ),
        filled: true,
        fillColor: const Color(0xFFE3EBFD),
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
          color: const Color(0xFFE3EBFD),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            selectedCategory == null
                ? const Icon(Icons.wallet, size: 20, color: Colors.grey)
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
                  color: selectedCategory == null ? Colors.grey : Colors.black,
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
      "rewards",
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
                    color: Colors.white,
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
                            setState(() => selectedCategory = name);
                            Navigator.pop(context);
                          },
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 26,
                                backgroundColor: Colors.indigo,
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
                                style: const TextStyle(fontSize: 10),
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
          color: const Color(0xFFE3EBFD),
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
                color: const Color(0xFF142752),
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
              color: Colors.white,
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

  // ================= UI HELPERS =================
  Widget _label(String text) =>
      Text(text, style: const TextStyle(fontWeight: FontWeight.w500));

  Widget _primaryButton(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF142752),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 22),
        ],
      ),
    );
  }

  Widget _linkBudgetButton() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFE3EBFD),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: const [
          Expanded(child: Text("Link to a budget")),
          Icon(Icons.keyboard_arrow_down),
        ],
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
            foregroundColor: const Color(0xFF142752), // blue text
          ),
          child: const Text("CANCEL"),
        ),
        ElevatedButton(
          onPressed: _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF142752), // blue
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
    if (!_formKey.currentState!.validate()) return;

    final record = Record(
      title: titleCtrl.text,
      amount: double.parse(amountCtrl.text),
      date: selectedDate!,
      type: selectedType,
      category: selectedCategory ?? "miscellaneous",
    );

    Navigator.pop(context, record);
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

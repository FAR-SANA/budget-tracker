import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/record.dart';
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        title: const Text("Edit Record"),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF142752)),
        titleTextStyle: const TextStyle(
          color: Color(0xFF142752),
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

  // ---------------- INPUTS ----------------

  Widget _label(String text) =>
      Text(text, style: const TextStyle(fontWeight: FontWeight.w500));

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
        fillColor: const Color(0xFFE3EBFD),
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
      decoration: InputDecoration(
        suffixIcon: const Icon(Icons.calendar_today),
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF142752),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Text("Select account", style: TextStyle(color: Colors.white)),
      ),
    );
  }

Widget _categoryButton() {
  return InkWell(
    onTap: _showCategorySheet, // ✅ you must create this function
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
                          setState(() {
                            selectedCategory = name;
                          });
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
Widget _repeatButton() {
  return InkWell(
    onTap: _showRepeatSheet, // ✅ you must create this function
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFE3EBFD),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            repeatType == null ? Icons.radio_button_unchecked : Icons.check_circle,
            color: const Color(0xFF142752),
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
  Widget _budgetButton() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFE3EBFD),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          Expanded(child: Text("Link to a budget")),
          Icon(Icons.keyboard_arrow_down),
        ],
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

    final oldAmount = (oldRecord['amount'] as num).toDouble();
    final oldType = oldRecord['record_type'];
    final accountId = oldRecord['account_id'];

    // 🔥 2️⃣ Reverse old balance effect
    if (oldType == 'income') {
      await supabase.rpc('decrement_balance', params: {
        'acc_id': accountId,
        'amount_val': oldAmount,
      });
    } else {
      await supabase.rpc('increment_balance', params: {
        'acc_id': accountId,
        'amount_val': oldAmount,
      });
    }

    // 🔥 3️⃣ Apply new balance effect
    final newAmount = double.parse(amountCtrl.text);

    if (selectedType == RecordType.income) {
      await supabase.rpc('increment_balance', params: {
        'acc_id': accountId,
        'amount_val': newAmount,
      });
    } else {
      await supabase.rpc('decrement_balance', params: {
        'acc_id': accountId,
        'amount_val': newAmount,
      });
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
          'is_recurring': repeatType != null,
        })
        .eq('record_id', widget.record.id)
        .eq('user_id', user.id);

    if (!mounted) return;
    Navigator.pop(context, true);

  } catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error: $e")),
    );
  }
}
}

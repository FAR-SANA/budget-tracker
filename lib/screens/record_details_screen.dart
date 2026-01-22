import 'package:flutter/material.dart';
import '../models/record.dart';
import 'edit_record_screen.dart';

class RecordDetailsScreen extends StatelessWidget {
  final Record record;

  const RecordDetailsScreen({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        title: const Text(
          "Record Details",
          style: TextStyle(color: Color(0xFF142752)),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF142752)),
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
              _value(record.type == RecordType.income ? "Income" : "Expense"),

              const SizedBox(height: 16),

              _label("Title"),
              _value(record.title),

              const SizedBox(height: 16),

              _label("Amount"),
              _value("₹ ${record.amount.toStringAsFixed(0)}"),

              const SizedBox(height: 16),

              _label("Date"),
              _value(
                "${record.date.day}/${record.date.month}/${record.date.year}",
              ),

              const SizedBox(height: 20),

              // ACCOUNT
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFF142752),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text(
                    "Personal Account",
                    style: TextStyle(
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
                        color: const Color(0xFFE3EBFD),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Image.asset(
                            "assets/icons/categories/${record.category}.png",
                            width: 20,
                            height: 20,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              record.category,
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
                        color: const Color(0xFFE3EBFD),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: record.repeatType == null
                                  ? Colors.transparent
                                  : Colors.indigo.withOpacity(0.15),
                            ),
                            child: Icon(
                              record.repeatType == null
                                  ? Icons.radio_button_unchecked
                                  : Icons.check_circle,
                              size: 20,
                              color: const Color(0xFF142752),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              record.repeatType ?? "Repeat",
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

              // LINK BUDGET
              Container(
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
              ),

              const SizedBox(height: 24), // ✅ SPACE BETWEEN BUDGET & EDIT
              // EDIT BUTTON
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final updated = await Navigator.push<Record>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditRecordScreen(record: record),
                      ),
                    );

                    if (updated != null) {
                      Navigator.pop(context, updated);
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
    return Text(text, style: const TextStyle(color: Colors.grey, fontSize: 13));
  }

  Widget _value(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFE8EEFF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
    );
  }
}

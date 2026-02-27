import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddAccountSheet extends StatefulWidget {
  const AddAccountSheet({super.key});

  @override
  State<AddAccountSheet> createState() => _AddAccountSheetState();
}

class _AddAccountSheetState extends State<AddAccountSheet> {
  final nameController = TextEditingController();
  final amountController = TextEditingController();

  Future<void> createAccount() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    await Supabase.instance.client.from('accounts').insert({
      'user_id': user.id,
      'name': nameController.text.trim(),
      'balance': double.parse(amountController.text.trim()),
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: const Color.fromARGB(
            255,
            255,
            255,
            255,
          ), // your light overlay background
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔹 Back Arrow
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),

              // 🔹 Title
              const Center(
                child: Text(
                  "Add Account",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A2B5D),
                  ),
                ),
              ),

              const SizedBox(height: 35),

              // 🔹 Account Name
              const Text(
                "Account Name:",
                style: TextStyle(fontSize: 15, color: Color(0xFF1A2B5D)),
              ),

              const SizedBox(height: 4),

              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFDCE3F8),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // 🔹 Amount
              const Text(
                "Amount:",
                style: TextStyle(fontSize: 15, color: Color(0xFF1A2B5D)),
              ),

              const SizedBox(height: 4),

              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFDCE3F8),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    prefixText: "₹ ",
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 50),

              // 🔹 Create Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: createAccount,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A2B5D),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 6,
                  ),
                  child: const Text(
                    "Create Account",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}

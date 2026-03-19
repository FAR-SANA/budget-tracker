import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../theme/app_colors.dart';

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

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: AppColors.background(context), // your light overlay background
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔹 Back Arrow
              IconButton(
                icon: Icon(Icons.arrow_back, color: AppColors.text(context)),
                onPressed: () => Navigator.pop(context),
              ),

              // 🔹 Title
              Center(
                child: Text(
                  "Add Account",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text(context),
                  ),
                ),
              ),

              const SizedBox(height: 35),

              // 🔹 Account Name
              Text(
                "Account Name:",
                style: TextStyle(fontSize: 15, color: AppColors.text(context)),
              ),

              const SizedBox(height: 4),

              Container(
                decoration: BoxDecoration(
                  color: AppColors.incomeCard(context),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  controller: nameController,
                  style: TextStyle(color: AppColors.text(context)), // ✅ ADD
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // 🔹 Amount
              Text(
                "Amount:",
                style: TextStyle(fontSize: 15, color: AppColors.text(context)),
              ),

              const SizedBox(height: 4),

              Container(
                decoration: BoxDecoration(
                  color: AppColors.incomeCard(context),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: AppColors.text(context)), // ✅ ADD
                  decoration: InputDecoration(
                    prefixText: "₹ ",
                    prefixStyle: TextStyle(
                      color: AppColors.text(context),
                    ), // ✅ ADD
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
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
                    backgroundColor: AppColors.primary(context),
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

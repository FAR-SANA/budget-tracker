import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../theme/app_colors.dart';

class EditAccountSheet extends StatefulWidget {
  final Map account;

  const EditAccountSheet({super.key, required this.account});

  @override
  State<EditAccountSheet> createState() => _EditAccountSheetState();
}

class _EditAccountSheetState extends State<EditAccountSheet> {
  late TextEditingController nameController;
  late TextEditingController amountController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.account['name']);
    amountController = TextEditingController(
      text: widget.account['balance'].toString(),
    );
  }

  Future<void> saveAccount() async {
    final updatedData = {
      'account_id': widget.account['account_id'],
      'name': nameController.text.trim(),
      'balance': double.parse(amountController.text.trim()),
    };

    await Supabase.instance.client
        .from('accounts')
        .update({
          'name': updatedData['name'],
          'balance': updatedData['balance'],
        })
        .eq('account_id', widget.account['account_id']);

    Navigator.pop(context, updatedData); // ✅ return updated map
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.background(context),
          borderRadius: BorderRadius.circular(16),
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
                  "Edit Account",
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

              // 🔹 Save Button (same style as others)
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: saveAccount,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary(context),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 6,
                  ),
                  child: const Text(
                    "Save Account",
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

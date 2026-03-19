import 'package:flutter/material.dart';
import 'edit_account_sheet.dart';
import '../../theme/app_colors.dart';

class AccountDetailsSheet extends StatefulWidget {
  final Map account;

  const AccountDetailsSheet({super.key, required this.account});

  @override
  State<AccountDetailsSheet> createState() => _AccountDetailsSheetState();
}

class _AccountDetailsSheetState extends State<AccountDetailsSheet> {
  late Map accountData;

  @override
  void initState() {
    super.initState();
    accountData = Map.from(widget.account);
  }

  void openEdit() async {
    final result = await showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(24),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Container(
            color: AppColors.background(context), // ✅ ADD THIS
            child: EditAccountSheet(account: accountData),
          ),
        ),
      ),
    );

    if (result != null) {
      setState(() {
        accountData = result; // 🔥 update local UI
      });

      Navigator.pop(context, true); // 🔥 send change upward
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: AppColors.background(context),
          borderRadius: BorderRadius.circular(16),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back, color: AppColors.text(context)),
                onPressed: () => Navigator.pop(context),
              ),

              Center(
                child: Text(
                  "Account Details",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text(context),
                  ),
                ),
              ),

              const SizedBox(height: 35),

              Text(
                "Account Name:",
                style: TextStyle(fontSize: 15, color: AppColors.text(context)),
              ),

              const SizedBox(height: 4),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.incomeCard(context),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  accountData['name'],
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.text(context),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              Text(
                "Amount:",
                style: TextStyle(fontSize: 15, color: AppColors.text(context)),
              ),

              const SizedBox(height: 4),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.incomeCard(context),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "₹ ${accountData['balance']}",
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.text(context),
                  ),
                ),
              ),

              const SizedBox(height: 50),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: openEdit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary(context),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 6,
                  ),
                  child: const Text(
                    "Edit Account",
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

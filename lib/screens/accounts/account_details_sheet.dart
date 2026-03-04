import 'package:flutter/material.dart';
import 'edit_account_sheet.dart';

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
        child: EditAccountSheet(account: accountData),
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
        decoration: const BoxDecoration(
          color: Color.fromARGB(255, 255, 255, 255),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),

              const Center(
                child: Text(
                  "Account Details",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A2B5D),
                  ),
                ),
              ),

              const SizedBox(height: 35),

              const Text(
                "Account Name:",
                style: TextStyle(fontSize: 15, color: Color(0xFF1A2B5D)),
              ),

              const SizedBox(height: 4),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCE3F8),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  accountData['name'],
                  style: const TextStyle(fontSize: 16),
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                "Amount:",
                style: TextStyle(fontSize: 15, color: Color(0xFF1A2B5D)),
              ),

              const SizedBox(height: 4),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCE3F8),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "₹ ${accountData['balance']}",
                  style: const TextStyle(fontSize: 16),
                ),
              ),

              const SizedBox(height: 50),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: openEdit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A2B5D),
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
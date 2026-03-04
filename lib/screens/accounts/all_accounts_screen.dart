import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'add_account_sheet.dart';
import 'account_details_sheet.dart';

class AllAccountsScreen extends StatefulWidget {
  const AllAccountsScreen({super.key});

  @override
  State<AllAccountsScreen> createState() => _AllAccountsScreenState();
}

class _AllAccountsScreenState extends State<AllAccountsScreen> {
  List accounts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAccounts();
  }

  Future<void> fetchAccounts() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final data = await Supabase.instance.client
        .from('accounts')
        .select()
        .eq('user_id', user.id)
        .order('created_at');

    setState(() {
      accounts = data;
      isLoading = false;
    });
  }

  void openAddAccount() async {
    final changed = await showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(24),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Container(
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: const AddAccountSheet(),
          ),
        ),
      ),
    );

    if (changed == true) {
      fetchAccounts();
      Navigator.pop(context, true);
    }
  }

  void openDetails(Map account) async {
    final changed = await showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(24),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Container(
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: AccountDetailsSheet(account: account),
          ),
        ),
      ),
    );

    if (changed == true) {
      fetchAccounts();
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("All Accounts")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: ListView(
                children: [
                  ...accounts.map((acc) {
                    return Center(
                      child: Dismissible(
                        key: Key(acc['account_id']),
                        direction: DismissDirection.horizontal,

                        confirmDismiss: (_) async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text("Delete Account"),
                              content: const Text(
                                "Are you sure you want to delete this account?",
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text("Cancel"),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text("Yes"),
                                ),
                              ],
                            ),
                          );

                          if (confirm != true) return false;

                          final client = Supabase.instance.client;

                          await client
                              .from('records')
                              .delete()
                              .eq('account_id', acc['account_id']);

                          await client
                              .from('accounts')
                              .delete()
                              .eq('account_id', acc['account_id']);

                          setState(() {
                            accounts.remove(acc);
                          });

                          Navigator.pop(context, true);

                          return true;
                        },

                        background: Container(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          color: Colors.red,
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),

                        secondaryBackground: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          color: Colors.red,
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),

                        child: GestureDetector(
                          onTap: () => openDetails(acc),
                          child: Container(
                            width: 330,
                            margin: const EdgeInsets.only(bottom: 20),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: const Color.fromARGB(
                                255,
                                202,
                                200,
                                255,
                              ).withOpacity(0.5),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.4),
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  blurRadius: 20,
                                  offset: Offset(0, 10),
                                  color: Color.fromARGB(31, 255, 255, 255),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "Account name",
                                  style: TextStyle(
                                    color: Colors.indigo.shade900,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  acc['name'],
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  "Balance",
                                  style: TextStyle(
                                    color: Colors.indigo.shade900,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  "₹${acc['balance']}",
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: openAddAccount,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(
                          0xFF1A2B5D,
                        ), // same as your app buttons
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 4,
                      ),
                      child: const Text(
                        "Add Account",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20), // 👈 bottom breathing space
                ],
              ),
            ),
    );
  }
}

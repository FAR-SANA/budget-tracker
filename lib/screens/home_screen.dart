import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'budget_screen.dart';
import 'dart:ui';
import '../models/record.dart';
import 'record_details_screen.dart';
import '../models/account.dart';
import 'profile_screen.dart';
import 'add_record_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'voice_input_dialog.dart';
import '../services/voice_parser.dart';
import '../theme/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final supabase = Supabase.instance.client;

  late RealtimeChannel _recordsChannel;

  Account? primaryAccount;
  List<Account> allAccounts = [];
  bool showAllAccounts = false; // for cumulative view
  RecordType selectedType = RecordType.income;
  List<Record> dayRecords = []; // ✅ list + chart (only selected day)
  List<Record> uptoRecords = []; // ✅ used only for balance totals

  double incomeUpToDate = 0;
  double expenseUpToDate = 0;

  DateTime selectedDate = DateTime.now();
  int touchedIndex = -1;

  // ✅ for list + chart (only selected day)
  double get dayIncome => dayRecords
      .where((r) => r.type == RecordType.income)
      .fold(0, (sum, r) => sum + r.amount);

  double get dayExpense => dayRecords
      .where((r) => r.type == RecordType.expense)
      .fold(0, (sum, r) => sum + r.amount);

  // ✅ totals upto selectedDate
  double get totalIncome => incomeUpToDate;
  double get totalExpense => expenseUpToDate;

  // ✅ balance upto selectedDate
  double get balance {
    if (showAllAccounts) {
      return allAccounts.fold<double>(0, (sum, acc) => sum + acc.balance);
    }

    return primaryAccount?.balance ?? 0;
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    _initialize();
    _listenForRealtimeUpdates();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      await loadAccount();
      await loadRecords();
    }
  }

  Future<void> _initialize() async {
    await loadAccount();

    if (primaryAccount != null) {
      await loadRecords();
    }
  }

  void _listenForRealtimeUpdates() {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    _recordsChannel = supabase
        .channel('records_changes')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'records',
          callback: (payload) async {
            print("REALTIME EVENT TRIGGERED");
            print("Payload: ${payload.newRecord}");

            if (!mounted) return;

            await loadAccount();
            await loadRecords();
          },
        )
        .subscribe();
  }

  String _toPgDate(DateTime d) => d.toIso8601String().split('T').first;
  Future<void> loadAccount() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final data = await supabase
        .from('accounts')
        .select()
        .eq('user_id', user.id)
        .order('created_at', ascending: true);

    if ((data as List).isEmpty) {
      _showAddAccountDialog();
      return;
    }

    final accounts = (data as List).map((e) => Account.fromJson(e)).toList();

    setState(() {
      allAccounts = accounts;
      primaryAccount = accounts.firstWhere(
        (acc) => acc.isDefault == true,
        orElse: () => accounts.first,
      );
    });
  }

  Future<void> loadRecords() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final dateStr = _toPgDate(selectedDate);

    List dayData;
    List uptoData;

    if (showAllAccounts) {
      // 🔵 ALL ACCOUNTS

      dayData = await supabase
          .from('records')
          .select()
          .eq('user_id', user.id)
          .eq('record_date', dateStr)
          .order('record_date', ascending: false);

      uptoData = await supabase
          .from('records')
          .select()
          .eq('user_id', user.id)
          .lte('record_date', dateStr)
          .order('record_date', ascending: false);
    } else {
      // 🟢 SINGLE ACCOUNT

      if (primaryAccount == null) return;
      final accountId = primaryAccount!.accountId;

      dayData = await supabase
          .from('records')
          .select()
          .eq('user_id', user.id)
          .eq('account_id', accountId)
          .eq('record_date', dateStr)
          .order('record_date', ascending: false);

      uptoData = await supabase
          .from('records')
          .select()
          .eq('user_id', user.id)
          .eq('account_id', accountId)
          .lte('record_date', dateStr)
          .order('record_date', ascending: false);
    }

    final dayList = dayData.map((json) => Record.fromJson(json)).toList();

    final uptoList = uptoData.map((json) => Record.fromJson(json)).toList();

    double inc = 0;
    double exp = 0;

    for (final r in uptoList) {
      if (r.type == RecordType.income) {
        inc += r.amount;
      } else {
        exp += r.amount;
      }
    }

    setState(() {
      dayRecords = dayList;
      uptoRecords = uptoList;
      incomeUpToDate = inc;
      expenseUpToDate = exp;
    });
  }

  Future<void> _deleteRecord(Record r) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Record"),
        content: const Text("Are you sure you want to delete this record?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Yes"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final record = await supabase
        .from('records')
        .select()
        .eq('record_id', r.id)
        .single();

    final budgetId = record['budget_id'];

    try {
      // 🔥 1️⃣ Get current account balance
      final accountData = await supabase
          .from('accounts')
          .select()
          .eq('account_id', r.accountId)
          .single();

      double currentBalance = (accountData['balance'] as num).toDouble();

      // 🔥 2️⃣ Reverse the transaction effect
      if (r.type == RecordType.income) {
        currentBalance -= r.amount;
      } else {
        currentBalance += r.amount;
      }

      // 🔥 3️⃣ Update account balance in DB
      await supabase
          .from('accounts')
          .update({'balance': currentBalance})
          .eq('account_id', r.accountId);

      // 🔥 4️⃣ UPDATE BUDGET BEFORE DELETING RECORD
      if (r.budgetId != null) {
        final budgetData = await supabase
            .from('budgets')
            .select('current_amount')
            .eq('budget_id', r.budgetId!)
            .single();

        double currentBudget = (budgetData['current_amount'] ?? 0).toDouble();

        await supabase
            .from('budgets')
            .update({'current_amount': currentBudget - r.amount})
            .eq('budget_id', r.budgetId!);
      }

      // 🔥 Update budget BEFORE deleting record
      if (budgetId != null) {
        final budgetData = await supabase
            .from('budgets')
            .select('current_amount')
            .eq('budget_id', budgetId)
            .single();

        double currentBudget = (budgetData['current_amount'] ?? 0).toDouble();

        await supabase
            .from('budgets')
            .update({'current_amount': currentBudget - r.amount})
            .eq('budget_id', budgetId);
      }

      // 🔥 4️⃣ Delete record
      await supabase.from('records').delete().eq('record_id', r.id);

      // 🔥 5️⃣ Refresh everything
      await loadAccount();
      await loadRecords();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Delete failed: $e")));
    }
  }

  void _showAddAccountDialog() {
    final nameCtrl = TextEditingController();
    final amountCtrl = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false, // ❗ user MUST add account
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    "Add Account",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.text(context),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                const Text("Account Name"),
                const SizedBox(height: 6),
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.incomeCard(context),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                const Text("Amount"),
                const SizedBox(height: 6),
                TextField(
                  controller: amountCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    prefixText: "₹ ",
                    filled: true,
                    fillColor: AppColors.incomeCard(context),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary(context),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      if (nameCtrl.text.isEmpty || amountCtrl.text.isEmpty) {
                        return;
                      }

                      try {
                        final user = supabase.auth.currentUser;
                        if (user == null) return;

                        // 🔥 1️⃣ Check if user already has a default account
                        final existingDefault = await supabase
                            .from('accounts')
                            .select()
                            .eq('user_id', user.id)
                            .eq('is_default', true);

                        final isFirstAccount =
                            (existingDefault as List).isEmpty;

                        // 🔥 2️⃣ Insert account
                        final inserted = await supabase
                            .from('accounts')
                            .insert({
                              'name': nameCtrl.text,
                              'balance': double.parse(amountCtrl.text),
                              'user_id': user.id,
                              'is_default':
                                  isFirstAccount, // ✅ Only first account becomes default
                            })
                            .select()
                            .single();

                        setState(() {
                          primaryAccount = Account.fromJson(inserted);
                        });

                        Navigator.pop(context);
                      } catch (e) {
                        print("ACCOUNT SAVE ERROR: $e");

                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text("Error: $e")));
                      }
                    },

                    child: const Text(
                      "Save Account",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredRecords = dayRecords
        .where((r) => r.type == selectedType)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _header(),
              _summaryCard(),
              const SizedBox(height: 20),
              _dateSelector(),
              const SizedBox(height: 20),
              _donutOrEmpty(filteredRecords),
              const SizedBox(height: 20),
              _tabs(),
              _recordList(filteredRecords),
              const SizedBox(height: 100), // 👈 space for FAB
            ],
          ),
        ),
      ),

      bottomNavigationBar: _bottomNav(),
      floatingActionButton: _fab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  // ---------------- HEADER ----------------
  Widget _header() {
    return Container(
      color: AppColors.headerBg(context),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Hello, Naomi",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.text(context),
            ),
          ),

          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () async {
              final changed = await Navigator.push<bool>(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );

              if (changed == true) {
                await loadAccount();
                await loadRecords();
              }
            },
            child: CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.incomeCard(context), // app soft blue
              child: Icon(
                Icons.person,
                color: AppColors.text(context), // primary app color
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- SUMMARY ----------------
  Widget _summaryCard() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.incomeCard(context),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 ACCOUNT NAME
            Row(
              children: [
                Image.asset(
                  'assets/images/logo.png',
                  height: 32,
                  width: 32,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 8),

                Expanded(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: showAllAccounts
                          ? 'ALL'
                          : primaryAccount?.accountId,
                      items: [
                        const DropdownMenuItem(
                          value: 'ALL',
                          child: Text("All Accounts"),
                        ),
                        ...allAccounts.map(
                          (acc) => DropdownMenuItem(
                            value: acc.accountId, // ✅ FIXED
                            child: Text(acc.name),
                          ),
                        ),
                      ],
                      onChanged: (value) async {
                        if (value == null) return;

                        final user = supabase.auth.currentUser;
                        if (user == null) return;

                        if (value == 'ALL') {
                          setState(() {
                            showAllAccounts = true;
                          });

                          await loadRecords();
                          return;
                        }

                        // 🔥 1️⃣ Remove current default
                        await supabase
                            .from('accounts')
                            .update({'is_default': false})
                            .eq('user_id', user.id);

                        // 🔥 2️⃣ Set selected account as default
                        await supabase
                            .from('accounts')
                            .update({'is_default': true})
                            .eq('account_id', value);

                        setState(() {
                          showAllAccounts = false;
                        });

                        await loadAccount(); // refresh primary account
                        await loadRecords(); // refresh UI
                      },
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 🔹 BALANCE + INCOME / EXPENSE
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Balance\n₹${balance.toStringAsFixed(2)}",
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.text(context),
                  ),
                ),
                Text(
                  selectedType == RecordType.income
                      ? "Income\n₹${dayIncome.toStringAsFixed(2)}"
                      : "Expense\n₹${dayExpense.toStringAsFixed(2)}",
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.text(context),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- DATE ----------------
  Widget _dateSelector() {
    final today = DateTime.now();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () async {
            setState(() {
              selectedDate = selectedDate.subtract(const Duration(days: 1));
            });
            await loadRecords();
          },
        ),
        Text(
          _formatDate(selectedDate),
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: AppColors.text(context),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed:
              selectedDate.isBefore(
                DateTime(today.year, today.month, today.day),
              )
              ? () async {
                  setState(() {
                    selectedDate = selectedDate.add(const Duration(days: 1));
                  });
                  await loadRecords();
                }
              : null,
        ),
      ],
    );
  }

  // ---------------- DONUT / EMPTY ----------------
  Widget _donutOrEmpty(List<Record> list) {
    if (list.isEmpty) {
      return Column(
        children: [
          Icon(
            Icons.pie_chart_outline,
            size: 100,
            color: AppColors.subText(context),
          ),
          SizedBox(height: 10),
          Text(
            "No records yet. Add one to\nview your daily analysis.",
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.subText(context)),
          ),
        ],
      );
    }

    final data = _groupByCategory(list);

    return Column(
      children: [
        SizedBox(
          height: 220,
          child: PieChart(
            PieChartData(
              centerSpaceRadius: 45,
              sectionsSpace: 2,
              pieTouchData: PieTouchData(
                touchCallback: (event, response) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        response == null ||
                        response.touchedSection == null) {
                      touchedIndex = -1;
                      return;
                    }
                    touchedIndex = response.touchedSection!.touchedSectionIndex;
                  });
                },
              ),
              sections: _buildSections(data),
            ),
          ),
        ),
        const SizedBox(height: 12),
        _legend(data),
      ],
    );
  }

  // ---------------- TABS ----------------
  Widget _tabs() {
    return Row(
      children: [
        _tab("Income", RecordType.income),
        _tab("Expense", RecordType.expense),
      ],
    );
  }

  Widget _tab(String title, RecordType type) {
    final active = selectedType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedType = type),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: active
                    ? AppColors.activeTab(context)
                    : AppColors.inactiveTab(context),
              ),
            ),
            Divider(
              thickness: 3,
              color: active
                  ? AppColors.activeTab(context)
                  : AppColors.inactiveTab(context),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- RECORD LIST ----------------
  Widget _recordList(List<Record> list) {
    return ListView.builder(
      itemCount: list.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (_, i) {
        final r = list[i];

        return Dismissible(
          key: Key(r.id),
          direction: DismissDirection.horizontal,
          confirmDismiss: (_) async {
            await _deleteRecord(r);
            return false;
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () async {
                final changed = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RecordDetailsScreen(record: r),
                  ),
                );

                if (changed == true) {
                  await loadAccount();
                  await loadRecords();
                }
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color:
                          (r.type == RecordType.income
                                  ? AppColors.incomeCard(context)
                                  : AppColors.expenseCard(context))
                              .withOpacity(0.65),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.subText(context).withOpacity(0.2),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: AppColors.primary(context),
                                child: Icon(Icons.work, color: Colors.white),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  r.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.text(context),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Flexible(
                          child: Text(
                            "${r.type == RecordType.income ? '+' : '-'}₹${r.amount.toStringAsFixed(2)}",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: r.type == RecordType.income
                                  ? AppColors.highlight(
                                      context,
                                    ) // or keep green if you want
                                  : AppColors.darkBlueText(context),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ---------------- FAB ----------------
  Widget _fab() {
    return Container(
      height: 64,
      width: 64,
      decoration: BoxDecoration(
        color: AppColors.primary(context),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 10,
            offset: const Offset(0, 4), // shadow downwards
          ),
        ],
      ),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: _showAddOptions,
        child: const Center(
          child: Icon(Icons.add, color: Colors.white, size: 30),
        ),
      ),
    );
  }

  void _showAddOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return Stack(
          children: [
            // Tap outside to dismiss
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(color: Colors.transparent),
            ),

            // Popup ABOVE FAB
            Positioned(
              bottom: 180,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 220,
                  decoration: BoxDecoration(
                    color: AppColors.background(context), // ✅ THEME FIX
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 12),

                      ListTile(
                        leading: const Icon(Icons.edit),
                        title: const Text("Text"),
                        onTap: () async {
                          Navigator.pop(context);

                          final selectedAccountId =
                              await Navigator.push<String?>(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      AddRecordScreen(type: selectedType),
                                ),
                              );

                          if (selectedAccountId != null) {
                            final data = await supabase
                                .from('accounts')
                                .select()
                                .eq('account_id', selectedAccountId)
                                .single();

                            setState(() {
                              primaryAccount = Account.fromJson(data);
                            });

                            await loadRecords();
                          }
                        },
                      ),

                      const Divider(height: 0),

                      ListTile(
                        leading: const Icon(Icons.mic),
                        title: const Text("Voice"),
                        onTap: () async {
                          Navigator.pop(context);

                          final text = await showDialog<String>(
                            context: context,
                            builder: (_) => const VoiceInputDialog(),
                          );

                          if (text == null || text.isEmpty) return;
                          final supabase = Supabase.instance.client;
                          final user = supabase.auth.currentUser;

                          if (user == null) return;
                          final accounts = await supabase
                              .from('accounts')
                              .select('name')
                              .eq('user_id', user.id);

                          final accountNames = accounts
                              .map<String>((a) => a['name'] as String)
                              .toList();

                          final parsed = VoiceParser.parse(text, accountNames);

                          if (parsed == null) return;

                          final changed = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AddRecordScreen(
                                type: parsed.type,
                                voiceTitle: parsed.title,
                                voiceAmount: parsed.amount,
                                voiceCategory: parsed.category,
                                voiceDate: parsed.date,
                                voiceAccount: parsed.accountName,
                              ),
                            ),
                          );

                          if (changed == true) {
                            await loadRecords();
                          }
                        },
                      ),

                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ---------------- BOTTOM NAV ----------------
  Widget _bottomNav() {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(Icons.home),
            SizedBox(width: 48),
            IconButton(
              icon: const Icon(Icons.track_changes),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BudgetScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- CHART HELPERS ----------------
  Map<String, double> _groupByCategory(List<Record> list) {
    final Map<String, double> map = {};
    for (final r in list) {
      final key = r.category;
      map[key] = (map[key] ?? 0) + r.amount;
    }
    return map;
  }

  List<PieChartSectionData> _buildSections(Map<String, double> data) {
    final total = data.values.fold(0.0, (a, b) => a + b);
    final colors = Colors.primaries;

    return data.entries.toList().asMap().entries.map((entry) {
      final index = entry.key;
      final value = entry.value.value;
      final percent = (value / total * 100).toStringAsFixed(0);

      final isTouched = index == touchedIndex;
      final radius = isTouched ? 60.0 : 50.0;

      return PieChartSectionData(
        value: value,
        title: "$percent%",
        radius: radius,
        color: colors[index % colors.length],
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Widget _legend(Map<String, double> data) {
    final colors = Colors.primaries;

    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: data.entries.toList().asMap().entries.map((entry) {
        final index = entry.key;
        final category = entry.value.key;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              color: colors[index % colors.length],
            ),
            const SizedBox(width: 6),
            Text(category),
          ],
        );
      }).toList(),
    );
  }

  String _formatDate(DateTime d) {
    const months = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December",
    ];
    return "${d.day} ${months[d.month - 1]} ${d.year}";
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    supabase.removeChannel(_recordsChannel);
    super.dispose();
  }
}

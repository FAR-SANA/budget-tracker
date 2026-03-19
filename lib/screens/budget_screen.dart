import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/budget.dart';
import 'add_budget_screen.dart';
import 'profile_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'budget_details_screen.dart';
import '../theme/app_colors.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  BudgetType selectedTab = BudgetType.saving;
  String userName = "User";
  Future<void> loadUserName() async {
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) return;

  final data = await Supabase.instance.client
      .from('users')
      .select('name')
      .eq('id', user.id)
      .single();

  if (!mounted) return;

  setState(() {
    userName = data['name'] ?? "User";
  });
}
  // ✅ FIX: persist budgets across screen rebuilds
  List<Budget> budgets = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchBudgets();
     loadUserName();
  }

  Future<void> fetchBudgets() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) return;

    final data = await supabase
        .from('budgets')
        .select()
        .eq('user_id', user.id)
        .order('created_at', ascending: false);

    setState(() {
      budgets = data.map<Budget>((b) {
        return Budget(
          id: b['budget_id'],
          title: b['title'],
          targetAmount: (b['target_amount'] ?? 0).toDouble(),
          currentAmount: (b['current_amount'] ?? 0).toDouble(),
          type: b['budget_type'] == 'saving'
              ? BudgetType.saving
              : BudgetType.spending,

          // ✅ ADD THESE
          startDate: b['start_date'] != null
              ? DateTime.parse(b['start_date'])
              : null,

          endDate: b['end_date'] != null ? DateTime.parse(b['end_date']) : null,
        );
      }).toList();

      isLoading = false;
    });
  }

  List<Budget> get filteredBudgets =>
      budgets.where((b) => b.type == selectedTab).toList();

  @override
  Widget build(BuildContext context) {
    final currentBudgets = filteredBudgets;

    return Scaffold(
      backgroundColor: AppColors.background(context),

      body: SafeArea(
        child: Column(
          children: [
            _header(),
            const SizedBox(height: 20),
            _tabs(),
            const SizedBox(height: 20),

            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : currentBudgets.isEmpty
                  ? _emptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 100),
                      itemCount: currentBudgets.length,
                      itemBuilder: (context, index) {
                        return _budgetCard(currentBudgets[index]);
                      },
                    ),
            ),
          ],
        ),
      ),

      floatingActionButton: _fab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.home),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              const SizedBox(width: 48),
              Icon(Icons.track_changes, color: AppColors.primary(context)),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- HEADER ----------------
  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Hello, $userName",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.text(context),
            ),
          ),
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
            child: CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.incomeCard(context), // soft blue bg
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

  // ---------------- TABS ----------------
  Widget _tabs() {
    return Row(
      children: [
        _tab("Saving", BudgetType.saving),
        _tab("Spending", BudgetType.spending),
      ],
    );
  }

  Widget _tab(String title, BudgetType type) {
    final active = selectedTab == type;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedTab = type),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: active
                    ? AppColors.text(context)
                    : AppColors.subText(context),
              ),
            ),
            const SizedBox(height: 6),
            Container(
              height: 3,
              color: active
                  ? AppColors.text(context)
                  : AppColors.subText(context),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- EMPTY STATE ----------------
  Widget _emptyState() {
    return Center(
      child: Text(
        "No budgets yet. Tap on +\n to add one",
        textAlign: TextAlign.center,
        style: TextStyle(color: AppColors.subText(context), fontSize: 16),
      ),
    );
  }

  Future<void> _deleteBudget(String budgetId) async {
    final supabase = Supabase.instance.client;

    try {
      await supabase.from('budgets').delete().eq('budget_id', budgetId);

      // refresh list after delete
      await fetchBudgets();

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Budget deleted")));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error deleting budget: $e")));
    }
  }

  // ---------------- GLASS BUDGET CARD ----------------
  Widget _budgetCard(Budget budget) {
    final progress = budget.currentAmount / budget.targetAmount;
    final barColor = budget.type == BudgetType.saving
        ? AppColors.primary(context)
        : AppColors.highlight(context);

    return Dismissible(
      key: Key(budget.id),
      direction: DismissDirection.horizontal,

      // 🔥 CONFIRMATION DIALOG
      confirmDismiss: (direction) async {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.background(context),
            titleTextStyle: TextStyle(
              color: AppColors.text(context),
              fontSize: 18,
            ),
            contentTextStyle: TextStyle(color: AppColors.subText(context)),
            title: const Text("Delete Budget"),
            content: const Text("Are you sure you want to delete this budget?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Delete"),
              ),
            ],
          ),
        );

        return confirm == true;
      },

      // 🔥 DELETE ACTION
      onDismissed: (direction) async {
        await _deleteBudget(budget.id);
      },

      // 🔴 BACKGROUND (LEFT SWIPE)
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),

      // 🔴 BACKGROUND (RIGHT SWIPE)
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),

      child: GestureDetector(
        onTap: () async {
          final changed = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (_) => BudgetDetailsScreen(budget: budget),
            ),
          );

          if (changed == true) {
            fetchBudgets();
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.incomeCard(context).withOpacity(0.8),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.text(context).withOpacity(0.1),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 10,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      budget.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text(context),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "₹${budget.targetAmount.toStringAsFixed(0)}",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.text(context),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 14,
                        backgroundColor: AppColors.background(context),
                        valueColor: AlwaysStoppedAnimation(barColor),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      budget.type == BudgetType.saving
                          ? "Saved ₹${budget.currentAmount} of ₹${budget.targetAmount}"
                          : "Spent ₹${budget.currentAmount} of ₹${budget.targetAmount}",
                      style: TextStyle(color: AppColors.subText(context)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- CUSTOM FAB ----------------
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
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () async {
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (_) => AddBudgetScreen(type: selectedTab),
            ),
          );

          if (result == true) {
            fetchBudgets(); // 🔥 reload from DB
          }
        },
        child: const Center(
          child: Icon(Icons.add, color: Colors.white, size: 30),
        ),
      ),
    );
  }
}

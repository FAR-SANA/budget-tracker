import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/budget.dart';
import 'add_budget_screen.dart';
import 'profile_screen.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  BudgetType selectedTab = BudgetType.saving;

  // ✅ FIX: persist budgets across screen rebuilds
  static final List<Budget> budgets = [];

  List<Budget> get filteredBudgets =>
      budgets.where((b) => b.type == selectedTab).toList();

  @override
  Widget build(BuildContext context) {
    final currentBudgets = filteredBudgets;

    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Column(
          children: [
            _header(),
            const SizedBox(height: 20),
            _tabs(),
            const SizedBox(height: 20),

            Expanded(
              child: currentBudgets.isEmpty
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
              const Icon(Icons.track_changes, color: Color(0xFF142752)),
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
          const Text(
            "Hello, Naomi",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
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
              backgroundColor: const Color(0xFFE8EEFF), // soft blue bg
              child: Icon(
                Icons.person,
                color: const Color(0xFF142752), // primary app color
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
                color: active ? const Color(0xFF142752) : Colors.blue.shade200,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              height: 3,
              color: active ? const Color(0xFF142752) : Colors.blue.shade200,
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- EMPTY STATE ----------------
  Widget _emptyState() {
    return const Center(
      child: Text(
        "No budgets yet. Tap on +\n to add one",
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.blueGrey, fontSize: 16),
      ),
    );
  }

  // ---------------- GLASS BUDGET CARD ----------------
  Widget _budgetCard(Budget budget) {
    final progress = budget.currentAmount / budget.targetAmount;
    final barColor = budget.type == BudgetType.saving
        ? Colors.indigo
        : Colors.amber;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50]!.withOpacity(0.75),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.blue[200]!.withOpacity(0.35)),
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
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "₹${budget.targetAmount.toStringAsFixed(0)}",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF142752),
                  ),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 14,
                    backgroundColor: Colors.white,
                    valueColor: AlwaysStoppedAnimation(barColor),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  budget.type == BudgetType.saving
                      ? "Saved ₹${budget.currentAmount} of ₹${budget.targetAmount}"
                      : "Spent ₹${budget.currentAmount} of ₹${budget.targetAmount}",
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
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
        color: const Color(0xFF142752),
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
          final result = await Navigator.push<Budget>(
            context,
            MaterialPageRoute(
              builder: (_) => AddBudgetScreen(type: selectedTab),
            ),
          );

          if (result != null) {
            setState(() => budgets.add(result));
          }
        },
        child: const Center(
          child: Icon(Icons.add, color: Colors.white, size: 30),
        ),
      ),
    );
  }
}

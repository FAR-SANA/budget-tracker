import 'package:flutter/material.dart';
import '../models/record.dart';
import 'add_record_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  RecordType selectedType = RecordType.income;
  List<Record> records = [];

  double get totalIncome => records
      .where((r) => r.type == RecordType.income)
      .fold(0, (sum, r) => sum + r.amount);

  double get totalExpense => records
      .where((r) => r.type == RecordType.expense)
      .fold(0, (sum, r) => sum + r.amount);

  double get balance => totalIncome - totalExpense;

  @override
  Widget build(BuildContext context) {
    final filteredRecords = records
        .where((r) => r.type == selectedType)
        .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
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
          ],
        ),
      ),
      bottomNavigationBar: _bottomNav(),
      floatingActionButton: _fab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  // ---------------- HEADER ----------------
  Widget _header() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          Text(
            "Hello, Naomi",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          CircleAvatar(child: Icon(Icons.person)),
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
          color: const Color(0xFFE8EEFF),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Balance\n₹${balance.toStringAsFixed(0)}"),
            Text(
              selectedType == RecordType.income
                  ? "Income\n₹${totalIncome.toStringAsFixed(0)}"
                  : "Expense\n₹${totalExpense.toStringAsFixed(0)}",
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- DATE ----------------
  Widget _dateSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Icon(Icons.chevron_left),
        SizedBox(width: 10),
        Text("24 September 2025"),
        SizedBox(width: 10),
        Icon(Icons.chevron_right),
      ],
    );
  }

  // ---------------- DONUT / EMPTY ----------------
  Widget _donutOrEmpty(List<Record> list) {
    if (list.isEmpty) {
      return Column(
        children: const [
          Icon(Icons.pie_chart_outline, size: 100, color: Colors.grey),
          SizedBox(height: 10),
          Text(
            "No records yet. Add one to\nview your daily analysis.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      );
    }

    // Simple placeholder donut
    return Container(
      height: 160,
      width: 160,
      decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.indigo),
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
                color: active ? Colors.indigo : Colors.grey,
              ),
            ),
            Divider(
              thickness: 2,
              color: active ? Colors.indigo : Colors.grey.shade300,
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- RECORD LIST ----------------
  Widget _recordList(List<Record> list) {
    return Expanded(
      child: ListView.builder(
        itemCount: list.length,
        itemBuilder: (_, i) {
          final r = list[i];
          return ListTile(
            leading: const CircleAvatar(child: Icon(Icons.work)),
            title: Text(r.title),
            trailing: Text(
              "${r.type == RecordType.income ? '+' : '-'}₹${r.amount}",
              style: TextStyle(
                color: r.type == RecordType.income ? Colors.green : Colors.red,
              ),
            ),
          );
        },
      ),
    );
  }

  // ---------------- FAB ----------------
  Widget _fab() {
    return Container(
      height: 64,
      width: 64,
      decoration: const BoxDecoration(
        color: Colors.indigo,
        shape: BoxShape.circle,
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
            // tap outside to dismiss
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(color: Colors.transparent),
            ),

            // popup ABOVE FAB
            Positioned(
              bottom: 180, // 👈 height ABOVE FAB (adjust if needed)
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 220, // ✅ same size as before
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 4),
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
                          final result = await Navigator.push<Record>(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  AddRecordScreen(type: selectedType),
                            ),
                          );
                          if (result != null) {
                            setState(() => records.add(result));
                          }
                        },
                      ),

                      const Divider(height: 0),

                      ListTile(
                        leading: const Icon(Icons.mic),
                        title: const Text("Voice"),
                        onTap: () {
                          Navigator.pop(context);
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
          children: const [
            Icon(Icons.home),
            SizedBox(width: 48),
            Icon(Icons.track_changes),
          ],
        ),
      ),
    );
  }
}

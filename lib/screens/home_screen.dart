import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'budget_screen.dart';
import 'dart:ui';
import '../models/record.dart';
import 'record_details_screen.dart';
import '../models/account.dart';
import 'profile_screen.dart';
import '../services/reminder_scheduler.dart';
import 'add_record_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Account? primaryAccount;
  RecordType selectedType = RecordType.income;
  List<Record> records = [];

  DateTime selectedDate = DateTime.now();
  int touchedIndex = -1;

  double get totalIncome => records
      .where(
        (r) => r.type == RecordType.income && _isSameDay(r.date, selectedDate),
      )
      .fold(0, (sum, r) => sum + r.amount);

  double get totalExpense => records
      .where(
        (r) => r.type == RecordType.expense && _isSameDay(r.date, selectedDate),
      )
      .fold(0, (sum, r) => sum + r.amount);

  double get balance {
    final baseBalance = primaryAccount?.balance ?? 0;
    return baseBalance + totalIncome - totalExpense;
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (primaryAccount == null) {
        _showAddAccountDialog();
      }
    });
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
                const Center(
                  child: Text(
                    "Add Account",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF142752),
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
                    fillColor: const Color(0xFFE3EBFD),
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
                    fillColor: const Color(0xFFE3EBFD),
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
                      backgroundColor: const Color(0xFF142752),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      if (nameCtrl.text.isEmpty || amountCtrl.text.isEmpty) {
                        return;
                      }

                      setState(() {
                        primaryAccount = Account(
                          name: nameCtrl.text,
                          balance: double.parse(amountCtrl.text),
                        );
                      });

                      Navigator.pop(context);
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
    final filteredRecords = records
        .where(
          (r) => r.type == selectedType && _isSameDay(r.date, selectedDate),
        )
        .toList();

    return Scaffold(
      backgroundColor: Colors.white,
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
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
            child: CircleAvatar(
              radius: 20,
              backgroundColor: const Color(0xFFE8EEFF), // app soft blue
              child: const Icon(
                Icons.person,
                color: Color(0xFF142752), // primary app color
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
          color: const Color(0xFFE8EEFF),
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
                Text(
                  primaryAccount?.name ?? "Account",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF142752),
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
                  style: const TextStyle(fontSize: 15),
                ),
                Text(
                  selectedType == RecordType.income
                      ? "Income\n₹${totalIncome.toStringAsFixed(2)}"
                      : "Expense\n₹${totalExpense.toStringAsFixed(2)}",
                  style: const TextStyle(fontSize: 15),
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
          onPressed: () {
            setState(() {
              selectedDate = selectedDate.subtract(const Duration(days: 1));
            });
          },
        ),
        Text(
          _formatDate(selectedDate),
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed:
              selectedDate.isBefore(
                DateTime(today.year, today.month, today.day),
              )
              ? () {
                  setState(() {
                    selectedDate = selectedDate.add(const Duration(days: 1));
                  });
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
                color: active ? const Color(0xFF142752) : Colors.blue.shade200,
              ),
            ),
            Divider(
              thickness: 3,
              color: active ? const Color(0xFF142752) : Colors.blue.shade200,
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
      shrinkWrap: true, // ✅ key
      physics: const NeverScrollableScrollPhysics(), // ✅ key
      itemBuilder: (_, i) {
        final r = list[i];

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () async {
              final updated = await Navigator.push<Record>(
                context,
                MaterialPageRoute(
                  builder: (_) => RecordDetailsScreen(record: r),
                ),
              );

              if (updated != null) {
                setState(() {
                  final index = records.indexOf(r);
                  if (index != -1) {
                    records[index] = updated;
                  }
                });

                await ReminderScheduler.schedule(records);
              }
            },

            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.blue[50]!.withOpacity(0.65), // glass effect
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.blue[100]!.withOpacity(0.35),
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
                              backgroundColor: const Color(0xFF142752),
                              child: const Icon(
                                Icons.work,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                r.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF142752),
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
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                      ),
                    ],
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
        color: const Color(0xFF142752),
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
                            await ReminderScheduler.schedule(records);

                            // ✅ confirmation message
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                  "Record added successfully",
                                ),
                                duration: const Duration(seconds: 2),
                                behavior: SnackBarBehavior.floating,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                backgroundColor: const Color(0xFF142752),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            );
                          }
                        },
                      ),

                      const Divider(height: 0),

                      ListTile(
                        leading: const Icon(Icons.mic),
                        title: const Text("Voice"),
                        onTap: () {
                          Navigator.pop(context);
                          // voice logic later
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

  // ---------------- HELPERS ----------------
  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

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
}

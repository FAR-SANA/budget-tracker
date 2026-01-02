import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FF),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.amber,
        onPressed: () {},
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _bottomNav(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(),
              const SizedBox(height: 20),
              _balanceCard(),
              const SizedBox(height: 20),
              _dateSelector(),
              const SizedBox(height: 20),
              _tabs(),
              const SizedBox(height: 10),
              _transactionList(),
            ],
          ),
        ),
      ),
    );
  }

  // Header
  Widget _header() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: const [
        Text(
          "Hello, Naomi",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        CircleAvatar(
          radius: 22,
          backgroundColor: Colors.lightBlueAccent,
          child: Icon(Icons.person, color: Colors.white),
        )
      ],
    );
  }

  // Balance Card
  Widget _balanceCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFE8EEFF),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("My Balance"),
          const SizedBox(height: 8),
          const Text(
            "+ Rs. 27510/-",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text("Spent\n+ Rs 6940/-"),
              Text("Earned\n- Rs 27015/-"),
            ],
          )
        ],
      ),
    );
  }

  // Date selector
  Widget _dateSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Icon(Icons.chevron_left),
        SizedBox(width: 12),
        Text(
          "24 September 2025",
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        SizedBox(width: 12),
        Icon(Icons.chevron_right),
      ],
    );
  }

  // Income / Expense Tabs
  Widget _tabs() {
    return Row(
      children: const [
        Expanded(
          child: Column(
            children: [
              Text("Income", style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 6),
              Divider(thickness: 2, color: Colors.indigo),
            ],
          ),
        ),
        Expanded(
          child: Column(
            children: [
              Text("Expense", style: TextStyle(color: Colors.grey)),
              SizedBox(height: 6),
              Divider(thickness: 2, color: Colors.grey),
            ],
          ),
        ),
      ],
    );
  }

  // Transaction List
  Widget _transactionList() {
    return Expanded(
      child: ListView(
        children: const [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.indigo,
              child: Icon(Icons.attach_money, color: Colors.white),
            ),
            title: Text("Freelance Work"),
            trailing: Text("+ Rs 2000/-"),
          ),
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.amber,
              child: Icon(Icons.card_giftcard, color: Colors.white),
            ),
            title: Text("GPay Cashback"),
            trailing: Text("+ Rs 15/-"),
          ),
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.indigo,
              child: Icon(Icons.attach_money, color: Colors.white),
            ),
            title: Text("Salary"),
            trailing: Text("+ Rs 25000/-"),
          ),
        ],
      ),
    );
  }

  // Bottom Navigation Bar
  Widget _bottomNav() {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Icon(Icons.home),
            Icon(Icons.account_balance_wallet),
            SizedBox(width: 40),
            Icon(Icons.pie_chart),
            Icon(Icons.more_horiz),
          ],
        ),
      ),
    );
  }
}

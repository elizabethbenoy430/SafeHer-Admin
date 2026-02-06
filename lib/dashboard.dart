import 'package:admin_app/category.dart';
import 'package:admin_app/district.dart';
import 'package:admin_app/myprofile.dart';
import 'package:admin_app/place.dart';
import 'package:flutter/material.dart';

/* ===================== DASHBOARD ===================== */

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Row(
        children: const [
          AdminSidebar(),
          Expanded(child: DashboardContent()),
        ],
      ),
    );
  }
}

/* ===================== SIDEBAR ===================== */

class AdminSidebar extends StatelessWidget {
  const AdminSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      padding: const EdgeInsets.all(20),
      color: Colors.black,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "SafeHer",
            style: TextStyle(
              color: Colors.greenAccent,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 40),

          sidebarButton(context, Icons.dashboard, "Overview", true, null),
          sidebarButton(context, Icons.sos, "District", false, AdminDistrictPage()),

          // ✅ CATEGORY BUTTON (ADDED)
          sidebarButton(
            context,
            Icons.category,
            "Category",
            false,
            const AdminCategoryPage(),
          ),

          sidebarButton(context, Icons.report, "Complaints", false, null),
          sidebarButton(context, Icons.location_on, "Live Tracking", false, null),
          sidebarButton(context, Icons.bar_chart, "Reports", false, null),
          sidebarButton(context, Icons.bar_chart, "Place", false, const Place()),

          const Spacer(),

          sidebarButton(context, Icons.settings, "Settings", false, null),
          sidebarButton(context, Icons.logout, "Logout", false, null),
        ],
      ),
    );
  }

  Widget sidebarButton(
    BuildContext context,
    IconData icon,
    String title,
    bool active,
    Widget? page,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor:
              active ? Colors.greenAccent.withOpacity(0.2) : Colors.transparent,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: active ? Colors.greenAccent : Colors.transparent,
            ),
          ),
        ),
        onPressed: page == null
            ? () {}
            : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => page),
                );
              },
        child: Row(
          children: [
            Icon(icon, color: Colors.greenAccent),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

/* ===================== MAIN CONTENT ===================== */

class DashboardContent extends StatelessWidget {
  const DashboardContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          topBar(context),
          const SizedBox(height: 20),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      topCards(),
                      const SizedBox(height: 20),
                      Expanded(child: bottomCards()),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(flex: 1, child: performanceCard()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget topBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Dashboard",
          style: TextStyle(
            color: Colors.greenAccent,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.greenAccent,
              child: IconButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => MyProfile()));
                },
                icon: const Icon(Icons.person, color: Colors.black),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget topCards() {
    return Row(
      children: [
        Expanded(flex: 2, child: highlightCard()),
        const SizedBox(width: 20),
        Expanded(child: statCard("SOS Alerts", "193", "+35%")),
        const SizedBox(width: 20),
        Expanded(child: statCard("Complaints", "32", "-12%")),
      ],
    );
  }

  Widget highlightCard() {
    return Container(
      height: 150,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F2E1F),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.greenAccent),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Update", style: TextStyle(color: Colors.greenAccent)),
          SizedBox(height: 10),
          Text(
            "SOS alerts increased\n40% this week",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget statCard(String title, String value, String change) {
    return Container(
      height: 150,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.greenAccent,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            change,
            style: TextStyle(
              color:
                  change.contains('-') ? Colors.redAccent : Colors.greenAccent,
            ),
          ),
        ],
      ),
    );
  }

  Widget bottomCards() {
    return Row(
      children: [
        Expanded(flex: 2, child: transactionCard()),
        const SizedBox(width: 20),
        Expanded(child: reportCard()),
      ],
    );
  }

  Widget transactionCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Recent SOS / Complaints",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.greenAccent,
            ),
          ),
        ],
      ),
    );
  }

  Widget reportCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        "Monthly Report",
        style: TextStyle(color: Colors.greenAccent),
      ),
    );
  }

  Widget performanceCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(
        child: Text(
          "Analytics",
          style: TextStyle(color: Colors.white54),
        ),
      ),
    );
  }
}

import 'package:admin_app/viewcomplaints.dart';
import 'package:flutter/material.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const SafeHerDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "SafeHer Dashboard",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      // 🌿 BACKGROUND IMAGE
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/bg.webp"), // ✅ UPDATED PATH
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black54,
              BlendMode.darken,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 30),

              dashboardButton(
                icon: Icons.sos,
                label: "SOS Alerts",
                color: Colors.redAccent,
                onTap: () {},
              ),

              dashboardButton(
                icon: Icons.report_problem,
                label: "View Complaints",
                color: Colors.orangeAccent,
                onTap: () {},
              ),

              dashboardButton(
                icon: Icons.bar_chart,
                label: "Reports",
                color: Colors.greenAccent,
                onTap: () {},
              ),

              dashboardButton(
                icon: Icons.location_on,
                label: "Live Location Tracking",
                color: Colors.blueAccent,
                onTap: () {},
              ),

              dashboardButton(
                icon: Icons.people,
                label: "Manage Users",
                color: Colors.purpleAccent,
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔹 DASHBOARD BUTTON WIDGET
  Widget dashboardButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      child: Material(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: color.withOpacity(0.2),
                  child: Icon(icon, color: color, size: 30),
                ),
                const SizedBox(width: 20),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                const Icon(Icons.arrow_forward_ios,
                    color: Colors.white70, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// 🔹 SIDEBAR / DRAWER
class SafeHerDrawer extends StatelessWidget {
  const SafeHerDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.black,
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Colors.black),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.shield, color: Colors.greenAccent, size: 50),
                SizedBox(height: 10),
                Text(
                  "SafeHer",
                  style: TextStyle(
                    color: Colors.greenAccent,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Women Safety Dashboard",
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),

          drawerButton(Icons.sos, "SOS Alerts", context),
          drawerButton(Icons.description, "View Complaints", context, onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const ViewComplaints()));
          }),
          drawerButton(Icons.bar_chart, "Report", context),
          drawerButton(Icons.location_on, "Live Tracking", context),
          drawerButton(Icons.settings, "Settings", context),

          const Spacer(),

          drawerButton(Icons.logout, "Logout", context),
        ],
      ),
    );
  }

  Widget drawerButton(IconData icon, String title, BuildContext context, {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.greenAccent),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white),
      ),
      onTap: () {
        Navigator.pop(context);
        onTap?.call();
      },
    );
  }
}

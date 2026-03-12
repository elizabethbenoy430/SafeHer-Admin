import 'package:admin_app/main.dart';
import 'package:admin_app/report.dart';
import 'package:admin_app/viewsosactivity.dart';
import 'package:flutter/material.dart';
import 'package:admin_app/myprofile.dart';
import 'package:admin_app/viewcomplaints.dart';
import 'package:admin_app/viewstationlist.dart';
import 'package:admin_app/viewuserlist.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fl_chart/fl_chart.dart';




/* ===================== ADMIN DASHBOARD ===================== */

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

/* ===================== SIDEBAR NAVIGATION ===================== */

class AdminSidebar extends StatelessWidget {
  const AdminSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 30),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D0D),
        border: Border(right: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              "SafeHer Admin",
              style: TextStyle(
                color: Colors.greenAccent,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
            ),
          ),
          const SizedBox(height: 40),

          // Navigation Buttons
          _sidebarButton(context, Icons.dashboard_rounded, "Overview", true, null),
          _sidebarButton(context, Icons.people_alt_rounded, "View User List", false, const ViewUserList()),
          _sidebarButton(context, Icons.local_police_rounded, "View Station List", false, const Viewstationlist()),
          _sidebarButton(context, Icons.notifications_active_rounded, "SOS Activity", false, const ViewSOSActivity()),
          _sidebarButton(context, Icons.assignment_late_rounded, "Complaints", false, const ViewComplaints()),
          _sidebarButton(context, Icons.assignment_late_rounded, "Reports", false, const AdminReport()),
         

          const Spacer(),
          
          _sidebarButton(context, Icons.settings_rounded, "Settings", false, null),
          _sidebarButton(context, Icons.logout_rounded, "Logout", false, null),
        ],
      ),
    );
  }

  Widget _sidebarButton(BuildContext context, IconData icon, String title, bool active, Widget? destination) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: active ? Colors.greenAccent.withOpacity(0.1) : Colors.transparent,
            foregroundColor: active ? Colors.greenAccent : Colors.white60,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 15),
            alignment: Alignment.centerLeft,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: active ? Colors.greenAccent.withOpacity(0.5) : Colors.transparent),
            ),
          ),
          onPressed: destination == null 
            ? () {} 
            : () {
                // The Navigator logic that pushes to the new page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => destination),
                );
              },
          child: Row(
            children: [
              Icon(icon, size: 20),
              const SizedBox(width: 15),
              Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }
}



/* ===================== DASHBOARD CONTENT ===================== */


class DashboardContent extends StatefulWidget {
  const DashboardContent({super.key});

  @override
  State<DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<DashboardContent> {

  final SupabaseClient supabase = Supabase.instance.client;

  int totalUsers = 0;
  int activeSOS = 0;
  int totalStations = 0;
  
List<int> monthlySOS = List.filled(12, 0);

  @override
  void initState() {
    super.initState();
    fetchDashboardCounts();
  fetchMonthlySOS();
  }

  Future<void> fetchDashboardCounts() async {
    try {

      // Total Users
      final users = await supabase
          .from('tbl_user')
          .select();

      // Active SOS
      final sos = await supabase
          .from('tbl_sos')
          .select();

      // Stations
      final stations = await supabase
          .from('tbl_station')
          .select();

      setState(() {
        totalUsers = users.length;
        activeSOS = sos.length;
        totalStations = stations.length;
      });

    } catch (e) {
      print("Dashboard Count Error: $e");
    }
  }

  Future<void> fetchMonthlySOS() async {
  try {

    final data = await supabase
        .from('tbl_sos')
        .select();

    List<int> counts = List.filled(12, 0);

    for (var sos in data) {
      DateTime date = DateTime.parse(sos['created_at']);
      int monthIndex = date.month - 1; // Jan=0

      counts[monthIndex]++;
    }

    setState(() {
      monthlySOS = counts;
    });

  } catch (e) {
    print("Monthly SOS Error: $e");
  }
}

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "System Overview",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold),
              ),
              CircleAvatar(
                backgroundColor: Colors.greenAccent,
                child: IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.person, color: Colors.black),
                ),
              ),
            ],
          ),

          const SizedBox(height: 30),

          Row(
            children: [
              _buildStatCard(
                  "Total Users",
                  totalUsers.toString(),
                  Icons.people,
                  Colors.blueAccent),

              const SizedBox(width: 20),

              _buildStatCard(
                  "Active SOS",
                  activeSOS.toString(),
                  Icons.warning,
                  Colors.redAccent),

              const SizedBox(width: 20),

              _buildStatCard(
                  "Stations",
                  totalStations.toString(),
                  Icons.shield,
                  Colors.greenAccent),
            ],
          ),

          const SizedBox(height: 30),
Expanded(
  child: Container(
    width: double.infinity,
    padding: const EdgeInsets.all(25),
    decoration: BoxDecoration(
      color: const Color(0xFF151515),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white.withOpacity(0.05)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        const Text(
          "SOS Activity Overview (Last 7 Days)",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 20),

      Expanded(
  child: LineChart(
    LineChartData(
      gridData: FlGridData(show: true),

      borderData: FlBorderData(
        show: true,
        border: Border.all(color: Colors.white24),
      ),

      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: true),
        ),

        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {

              const months = [
                "Jan","Feb","Mar","Apr","May","Jun",
                "Jul","Aug","Sep","Oct","Nov","Dec"
              ];

              if (value.toInt() < 0 || value.toInt() > 11) {
                return const SizedBox();
              }

              return Text(
                months[value.toInt()],
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 10,
                ),
              );
            },
          ),
        ),
      ),

      lineBarsData: [
        LineChartBarData(
          isCurved: true,
          color: Colors.redAccent,
          barWidth: 4,
          dotData: FlDotData(show: true),

          spots: List.generate(
            monthlySOS.length,
            (index) => FlSpot(
              index.toDouble(),
              monthlySOS[index].toDouble(),
            ),
          ),
        ),
      ],
    ),
  ),
)



      ],
    ),
  ),
)
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF151515),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Icon(icon, color: color, size: 28),

            const SizedBox(height: 15),

            Text(
              title,
              style: const TextStyle(color: Colors.white54, fontSize: 14),
            ),

            const SizedBox(height: 5),

            Text(
              value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

  
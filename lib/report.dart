import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fl_chart/fl_chart.dart';

class AdminReport extends StatefulWidget {
  const AdminReport({super.key});

  @override
  State<AdminReport> createState() => _AdminReportState();
}

class _AdminReportState extends State<AdminReport> {
  final SupabaseClient supabase = Supabase.instance.client;

  int totalUsers = 0;
  int totalSOS = 0;
  int totalStations = 0;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchReport();
  }

  Future<void> fetchReport() async {
    try {
      final users = await supabase.from('tbl_user').select();
      final sos = await supabase.from('tbl_sos').select();
      final stations = await supabase.from('tbl_station').select();

      setState(() {
        totalUsers = users.length;
        totalSOS = sos.length;
        totalStations = stations.length;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget glassCard({required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.55),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.greenAccent.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.greenAccent.withOpacity(0.1),
            blurRadius: 15,
          )
        ],
      ),
      child: child,
    );
  }

  /// USERS LINE GRAPH
  Widget userGraph() {
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            color: Colors.greenAccent,
            isCurved: true,
            barWidth: 3,
            spots: [
              FlSpot(0, 1),
              FlSpot(1, totalUsers.toDouble()),
            ],
          )
        ],
      ),
    );
  }

  /// SOS BAR GRAPH
  Widget sosGraph() {
    return BarChart(
      BarChartData(
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(show: false),
        barGroups: [
          BarChartGroupData(
            x: 0,
            barRods: [
              BarChartRodData(
                toY: totalSOS.toDouble(),
                color: Colors.redAccent,
                width: 20,
              )
            ],
          ),
        ],
      ),
    );
  }

  /// STATION RADIAL GRAPH
  Widget stationGraph() {
    return PieChart(
      PieChartData(
        centerSpaceRadius: 50,
        sections: [
          PieChartSectionData(
            value: totalStations.toDouble(),
            color: Colors.blueAccent,
            radius: 45,
            title: "",
          ),
          PieChartSectionData(
            value: 100 - totalStations.toDouble(),
            color: Colors.grey.withOpacity(0.2),
            radius: 45,
            title: "",
          ),
        ],
      ),
    );
  }

  /// DONUT OVERVIEW
  Widget donutChart() {
    return PieChart(
      PieChartData(
        centerSpaceRadius: 60,
        sectionsSpace: 4,
        sections: [
          PieChartSectionData(
              value: totalUsers.toDouble(),
              color: Colors.greenAccent,
              title: ""),
          PieChartSectionData(
              value: totalSOS.toDouble(),
              color: Colors.redAccent,
              title: ""),
          PieChartSectionData(
              value: totalStations.toDouble(),
              color: Colors.blueAccent,
              title: ""),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          "Admin Analytics",
          style: TextStyle(color: Colors.greenAccent),
        ),
        centerTitle: true,
      ),

      body: Stack(
        children: [

          /// MAP BACKGROUND
          Positioned.fill(
            child: Image.asset(
              "assets/bgl.png",
              fit: BoxFit.cover,
            ),
          ),

          /// DARK OVERLAY
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.85),
            ),
          ),

          /// CONTENT
          isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Colors.greenAccent,
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: [

                      /// USER GRAPH
                      glassCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            const Text(
                              "Users Growth",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),

                            const SizedBox(height: 20),

                            SizedBox(height: 150, child: userGraph()),
                          ],
                        ),
                      ),

                      /// SOS GRAPH
                      glassCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            const Text(
                              "SOS Activity",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),

                            const SizedBox(height: 20),

                            SizedBox(height: 150, child: sosGraph()),
                          ],
                        ),
                      ),

                      /// STATION GRAPH
                      glassCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            const Text(
                              "Stations Coverage",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),

                            const SizedBox(height: 20),

                            SizedBox(height: 150, child: stationGraph()),
                          ],
                        ),
                      ),

                      /// DONUT OVERVIEW
                      glassCard(
                        child: Column(
                          children: [

                            const Text(
                              "System Overview",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),

                            const SizedBox(height: 20),

                            SizedBox(height: 200, child: donutChart()),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
        ],
      ),
    );
  }
}
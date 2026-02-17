import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Viewstationlist extends StatefulWidget {
  const Viewstationlist({super.key});

  @override
  State<Viewstationlist> createState() => _ViewstationlistState();
}

class _ViewstationlistState extends State<Viewstationlist> {
  final SupabaseClient supabase = Supabase.instance.client;

  List<dynamic> stationList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchStations();
  }

  Future<void> fetchStations() async {
    try {
      final response = await supabase.from('tbl_station').select();
      setState(() {
         stationList = response;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error fetching stations: $e");
      setState(() => isLoading = false);
    }
  }

  // 🔹 FILTER LOGIC
  List<dynamic> get pendingStations => stationList
      .where((u) => u['station_status'] == null || u['station_status'] == 'pending')
      .toList();

  List<dynamic> get acceptedStations =>
      stationList.where((u) => u['station_status'] == 'accepted').toList();

  List<dynamic> get rejectedStations =>
      stationList.where((u) => u['station_status'] == 'rejected').toList();

  // 🔹 DATABASE ACTIONS
  Future<void> updateStationStatus(String stationId, String status) async {
    // Optimistic Update: Change local state immediately for a smooth UI
    setState(() {
      final index = stationList.indexWhere((u) => u['station_id'] == stationId);
      if (index != -1) stationList[index]['station_status'] = status;
    });

    try {
      await supabase
          .from('tbl_station')
          .update({'station_status': status})
          .eq('station_id', stationId);
    } catch (e) {
      debugPrint("Update failed: $e");
      fetchStations(); // Rollback/Refresh if DB update fails
    }
  }

  // 🔹 UI COMPONENTS
  Widget infoRow(IconData icon, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.greenAccent),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildUserList(List<dynamic> list, {bool showActions = false}) {
    if (list.isEmpty) {
      return const Center(
        child: Text("No stations found", style: TextStyle(color: Colors.white70)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final user = list[index];

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white10),
          ),
          child: Row(
            children: [
              Text("${index + 1}.",
                  style: const TextStyle(
                      color: Colors.greenAccent, fontWeight: FontWeight.bold)),
              const SizedBox(width: 12),
             
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user['station_name'] ?? 'Unknown Station',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                    infoRow(Icons.email_outlined, user['station_email'] ?? 'N/A'),
                    infoRow(Icons.phone_outlined, user['station_contact'] ?? 'N/A'),
                  ],
                ),
              ),
              if (showActions)
                Column(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check_circle_outline,
                          color: Colors.greenAccent),
                      onPressed: () =>
                          updateStationStatus(user['station_id'].toString(), 'accepted'),
                    ),
                    IconButton(
                      icon: const Icon(Icons.highlight_off, color: Colors.redAccent),
                      onPressed: () =>
                          updateStationStatus(user['station_id'].toString(), 'rejected'),
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          centerTitle: true,
          title: const Text("User Directory",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w300)),
          bottom: const TabBar(
            indicatorColor: Colors.greenAccent,
            indicatorWeight: 3,
            labelColor: Colors.greenAccent,
            unselectedLabelColor: Colors.white38,
            tabs: [
              Tab(text: "Pending"),
              Tab(text: "Accepted"),
              Tab(text: "Rejected"),
            ],
          ),
        ),
        body: isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.greenAccent))
            : TabBarView(
                children: [
                  buildUserList(pendingStations, showActions: true),
                  buildUserList(acceptedStations),
                  buildUserList(rejectedStations),
                ],
              ),
      ),
    );
  }
}
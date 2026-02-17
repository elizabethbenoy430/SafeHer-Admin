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

  // FILTERS
  List<dynamic> get pendingStations =>
      stationList.where((u) => u['station_status'] == null || u['station_status'] == 'pending').toList();

  List<dynamic> get acceptedStations =>
      stationList.where((u) => u['station_status'] == 'accepted').toList();

  List<dynamic> get rejectedStations =>
      stationList.where((u) => u['station_status'] == 'rejected').toList();

  // UPDATE STATUS
  Future<void> updateStationStatus(String id, String status) async {
    setState(() {
      final index = stationList.indexWhere((u) => u['station_id'].toString() == id);
      if (index != -1) stationList[index]['station_status'] = status;
    });

    await supabase.from('tbl_station').update({'station_status': status}).eq('station_id', id);
  }

  // INFO ROW
  Widget infoRow(IconData icon, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.tealAccent),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  // STATION CARD UI
  Widget buildStationCard(dynamic user, int index, bool showActions) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1F1C2C), Color(0xFF928DAB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.6), blurRadius: 8),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // NUMBER AVATAR
            CircleAvatar(
              radius: 25,
              backgroundColor: Colors.tealAccent,
              child: Text(
                "${index + 1}",
                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 15),

            // DETAILS
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user['station_name'] ?? 'Unknown Station',
                    style: const TextStyle(color: Colors.white, fontSize: 17),
                  ),

                  infoRow(Icons.email, user['station_email'] ?? "N/A"),
                  infoRow(Icons.phone, user['station_contact'] ?? "N/A"),

                  const SizedBox(height: 8),

                  // STATUS CHIP
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: user['station_status'] == 'accepted'
                          ? Colors.green
                          : user['station_status'] == 'rejected'
                              ? Colors.red
                              : Colors.orange,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      (user['station_status'] ?? 'Pending').toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),

            // ACTION BUTTONS
            if (showActions)
              Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.check_circle, color: Colors.greenAccent, size: 28),
                    onPressed: () => updateStationStatus(user['station_id'].toString(), 'accepted'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.cancel, color: Colors.redAccent, size: 28),
                    onPressed: () => updateStationStatus(user['station_id'].toString(), 'rejected'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  // LIST VIEW
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
        return buildStationCard(list[index], index, showActions);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFF0F0F0F),

        // APP BAR
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          centerTitle: true, // CENTER TITLE
          title: const Text(
            "Station Directory",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w300, // NOT BOLD
              fontSize: 18,
            ),
          ),
          bottom: const TabBar(
            indicatorColor: Colors.tealAccent,
            labelColor: Colors.tealAccent,
            unselectedLabelColor: Colors.white54,
            tabs: [
              Tab(icon: Icon(Icons.hourglass_empty), text: "Pending"),
              Tab(icon: Icon(Icons.check_circle), text: "Accepted"),
              Tab(icon: Icon(Icons.cancel), text: "Rejected"),
            ],
          ),
        ),

        // BODY
        body: isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.tealAccent))
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

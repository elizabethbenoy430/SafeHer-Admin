import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class ViewComplaints extends StatefulWidget {
  const ViewComplaints({super.key});

  @override
  State<ViewComplaints> createState() => _ViewComplaintsState();
}

class _ViewComplaintsState extends State<ViewComplaints> {
  final SupabaseClient supabase = Supabase.instance.client;

  List<dynamic> complaintList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    viewComplaint(); // Calling the fetch function
  }

  // 🔹 FETCH COMPLAINTS WITH USER NAME
  Future<void> viewComplaint() async {
    try {
      final response = await supabase
          .from('tbl_complaint') // Ensure this matches your Supabase table name
          .select('*, tbl_user(user_name)') // Join with user table
          .order('complaint_id', ascending: false);

      setState(() {
        complaintList = response;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error fetching complaints: $e");
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  // OPEN ATTACHED FILE
  Future<void> openFile(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not open file: $url');
    }
  }

  // COMPLAINT CARD UI
  Widget buildComplaintCard(dynamic complaint, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        // Changed gradient to Red/Dark for a "Complaint/Alert" feel
        gradient: const LinearGradient(
          colors: [Color(0xFF2C1C1C), Color(0xFF4A3B3B)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 6),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SL NO / INDEX
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.orangeAccent,
              child: Text(
                "${index + 1}",
                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 12),

            // DETAILS
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // USER NAME
                  Text(
                    "From: ${complaint['tbl_user']?['user_name'] ?? 'Anonymous'}",
                    style: const TextStyle(
                      color: Colors.orangeAccent,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // COMPLAINT CONTENT
                  Text(
                    complaint['complaint_content'] ?? "No Details Provided",
                    style: const TextStyle(color: Colors.white, fontSize: 15),
                  ),

                  const SizedBox(height: 8),

                  // DATE & STATUS ROW
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Date: ${complaint['complaint_date'] ?? 'N/A'}",
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      // Added a Status badge for Admin perspective
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white10,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          complaint['complaint_status'] ?? "Pending",
                          style: const TextStyle(color: Colors.amber, fontSize: 11),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // FILE ACTION
                  if (complaint['complaint_file'] != null && complaint['complaint_file'] != "")
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orangeAccent,
                        foregroundColor: Colors.black,
                       shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: const Icon(Icons.description, size: 18),
                      label: const Text("View Evidence"),
                      onPressed: () => openFile(complaint['complaint_file']),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "User Complaints",
          style: TextStyle(color: Colors.white, letterSpacing: 1.2),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: viewComplaint, // Swipe down to refresh
        color: Colors.orangeAccent,
        child: isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.orangeAccent))
            : complaintList.isEmpty
                ? const Center(
                    child: Text("No Complaints Found",
                        style: TextStyle(color: Colors.white54, fontSize: 16)),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: complaintList.length,
                    itemBuilder: (context, index) {
                      return buildComplaintCard(complaintList[index], index);
                    },
                  ),
      ),
    );
  }
}
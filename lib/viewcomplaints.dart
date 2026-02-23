import 'package:admin_app/replycomplaint.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'replycomplaint.dart';

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
    viewComplaint();
  }

  Future<void> viewComplaint() async {
    try {
      // ✅ Using * ensures complaint_id is fetched
      final response = await supabase
          .from('tbl_complaint')
          .select('*, tbl_user(user_name)')
          .order('complaint_id', ascending: false);

      setState(() {
        complaintList = response;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Fetch Error: $e");
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> openFile(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not open file');
    }
  }

  Widget buildComplaintCard(dynamic complaint, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF2C1C1C), Color(0xFF4A3B3B)]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "From: ${complaint['tbl_user']?['user_name'] ?? 'Anonymous'}",
              style: const TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(complaint['complaint_content'] ?? "", style: const TextStyle(color: Colors.white)),
            const Divider(color: Colors.white10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (complaint['complaint_file'] != null && complaint['complaint_file'] != "")
                  IconButton(
                    icon: const Icon(Icons.attach_file, color: Colors.blueAccent),
                    onPressed: () => openFile(complaint['complaint_file']),
                  ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReplyComplaint(complaint: complaint),
                      ),
                    ).then((_) => viewComplaint()); // Auto-refresh on return
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent),
                  child: const Text("Reply", style: TextStyle(color: Colors.black)),
                ),
              ],
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
      appBar: AppBar(title: const Text("Complaints"), backgroundColor: Colors.black),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: complaintList.length,
              itemBuilder: (context, index) => buildComplaintCard(complaintList[index], index),
            ),
    );
  }
}
import 'dart:ui';
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

  Widget buildComplaintCard(dynamic complaint) {
    // Check for both '0' (DB default) or 'Pending' string
    bool isPending = complaint['complaint_status'] == "0" || 
                     complaint['complaint_status'] == "Pending";

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12), // High blur for glass effect
        child: Container(
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3), // Darker overlay for readability
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.15)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.orangeAccent.withOpacity(0.2),
                          child: const Icon(Icons.person, color: Colors.orangeAccent, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          complaint['tbl_user']?['user_name'] ?? 'Anonymous',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isPending ? Colors.redAccent.withOpacity(0.2) : Colors.greenAccent.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isPending ? "Pending" : "Resolved",
                        style: TextStyle(
                          color: isPending ? Colors.redAccent : Colors.greenAccent,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  complaint['complaint_content'] ?? "",
                  style: const TextStyle(
                    color: Colors.white, 
                    fontSize: 14, 
                    height: 1.5,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(color: Colors.white24, thickness: 1),
                Row(
                  children: [
                    if (complaint['complaint_file'] != null && complaint['complaint_file'] != "")
                      TextButton.icon(
                        icon: const Icon(Icons.attach_file, size: 18, color: Colors.blueAccent),
                        label: const Text("View Attachment", style: TextStyle(color: Colors.blueAccent)),
                        onPressed: () => openFile(complaint['complaint_file']),
                      ),
                    const Spacer(),
                    if (isPending)
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ReplyComplaint(complaint: complaint),
                            ),
                          ).then((_) => viewComplaint());
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orangeAccent,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        ),
                        child: const Text("Reply", style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 🔹 BACKGROUND IMAGE
          Positioned.fill(
            child: Image.asset(
              'assets/bgl.png', // Ensure path matches your pubspec.yaml
              fit: BoxFit.cover,
            ),
          ),
          // 🔹 OVERLAY (To make sure background isn't too distracting)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.4),
            ),
          ),
          
          // MAIN CONTENT
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              const SliverAppBar(
                floating: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                centerTitle: true,
                title: Text(
                  "Complaints Inbox",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                sliver: isLoading
                    ? const SliverFillRemaining(
                        child: Center(child: CircularProgressIndicator(color: Colors.orangeAccent)),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => buildComplaintCard(complaintList[index]),
                          childCount: complaintList.length,
                        ),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
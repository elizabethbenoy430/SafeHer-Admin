import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ReplyComplaint extends StatefulWidget {
  final dynamic complaint;
  const ReplyComplaint({super.key, required this.complaint});

  @override
  State<ReplyComplaint> createState() => _ReplyComplaintState();
}

class _ReplyComplaintState extends State<ReplyComplaint> {
  final SupabaseClient supabase = Supabase.instance.client;
  final TextEditingController replyController = TextEditingController();
  bool isSubmitting = false;

  Future<void> replyComplaint() async {
    final String replyText = replyController.text.trim();
    
    // 1. Check if reply is empty
    if (replyText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please type a reply")));
      return;
    }

    // 2. SAFETY CHECK: Check if ID exists to avoid the Null Type Error
    final dynamic complaintId = widget.complaint['complaint_id'];
    if (complaintId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error: Complaint ID is missing"), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => isSubmitting = true);

    try {
      await supabase.from('tbl_complaint').update({
        'complaint_reply': replyText,
        'complaint_status': 'Replied',
      }).eq('complaint_id', complaintId); // ✅ Using the validated ID

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Reply sent!"), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint("Update Error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Database Error: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(backgroundColor: Colors.black, title: const Text("Reply")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("User's Complaint:", style: TextStyle(color: Colors.orangeAccent)),
            const SizedBox(height: 8),
            Text(widget.complaint['complaint_content'] ?? "No content", 
                 style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 20),
            TextField(
              controller: replyController,
              maxLines: 5,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Enter response...",
                hintStyle: const TextStyle(color: Colors.white24),
                filled: true,
                fillColor: Colors.white10,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isSubmitting ? null : replyComplaint,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent),
                child: isSubmitting
                    ? const CircularProgressIndicator(color: Colors.black)
                    : const Text("SUBMIT", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
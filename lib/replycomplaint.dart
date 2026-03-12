import 'dart:ui';
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

  // Green color constant for consistency
  final Color themeGreen = const Color(0xFF00E676); 

  Future<void> replyComplaint() async {
    final String replyText = replyController.text.trim();
    
    if (replyText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please type a reply"))
      );
      return;
    }

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
      }).eq('complaint_id', complaintId);

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
      backgroundColor: const Color(0xFF0F0F12),
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/bgl.png',
              fit: BoxFit.cover,
            ),
          ),
          // Dark Overlay
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.55)),
          ),
          
          Column(
            children: [
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                iconTheme: const IconThemeData(color: Colors.white),
                title: const Text("Send Response", 
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w300)),
                centerTitle: true,
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Label (Updated to Green)
                      Text("ORIGINAL COMPLAINT", 
                        style: TextStyle(color: themeGreen, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                      const SizedBox(height: 12),
                      
                      // Glass Box for Content
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.white.withOpacity(0.1)),
                            ),
                            child: Text(
                              widget.complaint['complaint_content'] ?? "No content available",
                              style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.5),
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Label (Updated to Green)
                      Text("YOUR REPLY", 
                        style: TextStyle(color: themeGreen, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                      const SizedBox(height: 12),
                      
                      // Input Box
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: TextField(
                            controller: replyController,
                            maxLines: 6,
                            style: const TextStyle(color: Colors.white),
                            cursorColor: themeGreen,
                            decoration: InputDecoration(
                              hintText: "Type your message here...",
                              hintStyle: const TextStyle(color: Colors.white24),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.05),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: themeGreen),
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // 🔹 SUBMIT BUTTON (Now Green)
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: isSubmitting ? null : replyComplaint,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: themeGreen,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 0,
                          ),
                          child: isSubmitting
                              ? const CircularProgressIndicator(color: Colors.black)
                              : const Text("SUBMIT REPLY", 
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
                        ),
                      ),
                    ],
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
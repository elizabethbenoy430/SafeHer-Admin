import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ViewSOSActivity extends StatefulWidget {
  const ViewSOSActivity({super.key});

  @override
  State<ViewSOSActivity> createState() => _ViewSOSActivityState();
}

class _ViewSOSActivityState extends State<ViewSOSActivity> {
  final SupabaseClient supabase = Supabase.instance.client;

  List<dynamic> sosList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSOSActivity();
  }

  Future<void> fetchSOSActivity() async {
    try {
      final response = await supabase
          .from('tbl_sos')
          .select('''
          sos_id,
          sos_status,
          created_at,
          tbl_user(user_name)
        ''')
          .order('created_at', ascending: false);

      setState(() {
        sosList = response;
        isLoading = false;
      });
    } catch (e) {
      print("ERROR: $e");

      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          "SOS Activity",
          style: TextStyle(
            color: Colors.greenAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [

          /// BACKGROUND IMAGE
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
              : sosList.isEmpty
                  ? const Center(
                      child: Text(
                        "No SOS Activity",
                        style: TextStyle(color: Colors.white70),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: sosList.length,
                      itemBuilder: (context, index) {
                        final sos = sosList[index];

                        return Container(
                          margin: const EdgeInsets.only(bottom: 15),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF111111),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: Colors.greenAccent.withOpacity(0.3),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.greenAccent.withOpacity(0.1),
                                blurRadius: 10,
                                spreadRadius: 1,
                              )
                            ],
                          ),
                          child: Row(
                            children: [

                              /// SL NO CIRCLE
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: Colors.greenAccent,
                                child: Text(
                                  "${index + 1}",
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),

                              const SizedBox(width: 15),

                              /// DETAILS
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [

                                    /// USER NAME
                                    Text(
                                      sos['tbl_user']?['user_name'] ??
                                          "Unknown User",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),

                                    const SizedBox(height: 5),

                                    /// TIME
                                    Text(
                                      sos['created_at'] ?? "",
                                      style: const TextStyle(
                                        color: Colors.white54,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              /// STATUS BADGE
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.greenAccent,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  sos['sos_status'] ?? "Unknown",
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            ],
                          ),
                        );
                      },
                    ),
        ],
      ),
    );
  }
}
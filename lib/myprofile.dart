import 'dart:ui';
import 'package:admin_app/main.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MyProfile extends StatefulWidget {
  const MyProfile({super.key});

  @override
  State<MyProfile> createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  final SupabaseClient supabase = Supabase.instance.client;
  Map<String, dynamic>? adminData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAdminDetails();
  }

  Future<void> fetchAdminDetails() async {
    try {
      final user = supabase.auth.currentUser;

      if (user == null) {
        setState(() => isLoading = false);
        return;
      }

      // 🔍 DEBUG: Copy this ID from your console and paste it into tbl_admin 'admin_id'
      debugPrint("Logged in Auth UID: ${user.id}");

      final response = await supabase
          .from('tbl_admin')
          .select('admin_name, admin_email')
          .eq('admin_id', user.id)
          .maybeSingle();

      debugPrint("Supabase Table Response: $response");

      if (!mounted) return;

      setState(() {
        if (response != null) {
          // Data found in table
          adminData = response;
        } else {
          // FALLBACK: If table is empty/mismatched, show Auth data
          adminData = {
            'admin_name': 'Admin User (Not in Table)',
            'admin_email': user.email ?? 'No Email Found',
          };
        }
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Fetch Error: $e");
      if (!mounted) return;
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.redAccent),
      );
    }
  }

  Future<void> handleSignOut() async {
    await supabase.auth.signOut();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const MainApp()),
        (route) => false,
      );
    }
  }

  Widget infoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF00E676).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: const Color(0xFF00E676), size: 24),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
          // 🔹 Background
          Positioned.fill(
            child: Image.asset('assets/bgl.png', fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.65)),
          ),

          isLoading
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF00E676)))
              : SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        // Custom Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                              onPressed: () => Navigator.pop(context),
                            ),
                            const Text("ADMIN PROFILE",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2)),
                            const SizedBox(width: 48),
                          ],
                        ),
                        const SizedBox(height: 40),

                        // Avatar
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(colors: [Color(0xFF00E676), Colors.cyanAccent]),
                          ),
                          child: const CircleAvatar(
                            radius: 55,
                            backgroundColor: Color(0xFF121212),
                            child: Icon(Icons.person, size: 60, color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        Text(
                          adminData?['admin_name'] ?? 'Admin',
                          style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        const Text("Authorized Administrator", style: TextStyle(color: Colors.white38, fontSize: 13)),
                        
                        const SizedBox(height: 40),

                        // Cards
                        infoCard(
                          icon: Icons.badge_outlined,
                          title: "ADMIN NAME",
                          value: adminData?['admin_name'] ?? 'Not Found',
                        ),
                        infoCard(
                          icon: Icons.alternate_email_rounded,
                          title: "EMAIL ADDRESS",
                          value: adminData?['admin_email'] ?? 'Not Found',
                        ),

                        const SizedBox(height: 50),

                        // Logout
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: handleSignOut,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent.withOpacity(0.1),
                              foregroundColor: Colors.redAccent,
                              side: const BorderSide(color: Colors.redAccent, width: 0.5),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              elevation: 0,
                            ),
                            child: const Text("SIGN OUT", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ViewUserList extends StatefulWidget {
  const ViewUserList({super.key});

  @override
  State<ViewUserList> createState() => _ViewUserListState();
}

class _ViewUserListState extends State<ViewUserList> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<dynamic> userList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    try {
      final response = await supabase
          .from('tbl_user')
          .select()
          .order('id', ascending: true);

      setState(() {
        userList = response;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Widget infoRow(IconData icon, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.greenAccent),
          const SizedBox(width: 6),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          "User List",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF4CAF50)),
            )
          : userList.isEmpty
          ? const Center(
              child: Text(
                "No users found",
                style: TextStyle(color: Colors.white70),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: userList.length,
              itemBuilder: (context, index) {
                final user = userList[index];

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.greenAccent.withOpacity(0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 🔹 SL NO
                      Text(
                        "${index + 1}.",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(width: 12),

                      // 🔹 USER PHOTO
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: const Color(
                          0xFF4CAF50,
                        ).withOpacity(0.2),
                        backgroundImage: user['photo'] != null
                            ? NetworkImage(user['photo'])
                            : null,
                        child: user['photo'] == null
                            ? const Icon(
                                Icons.person,
                                color: Color(0xFF4CAF50),
                                size: 30,
                              )
                            : null,
                      ),

                      const SizedBox(width: 14),

                      // 🔹 DETAILS
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user['name'] ?? '',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            infoRow(Icons.email_outlined, user['email'] ?? ''),
                            infoRow(
                              Icons.phone_outlined,
                              user['contact'] ?? '',
                            ),
                            infoRow(Icons.cake_outlined, user['dob'] ?? ''),
                          ],
                        ),
                      ),

                      // 🔹 ACTION
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.redAccent,
                        ),
                        onPressed: () {
                          // delete / block logic
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

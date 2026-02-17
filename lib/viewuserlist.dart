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
      final response = await supabase.from('tbl_user').select();
      setState(() {
        userList = response;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error fetching users: $e");
      setState(() => isLoading = false);
    }
  }

  // 🔹 FILTER LOGIC
  List<dynamic> get pendingUsers => userList
      .where((u) => u['user_status'] == null || u['user_status'] == 'pending')
      .toList();

  List<dynamic> get acceptedUsers =>
      userList.where((u) => u['user_status'] == 'accepted').toList();

  List<dynamic> get rejectedUsers =>
      userList.where((u) => u['user_status'] == 'rejected').toList();

  // 🔹 DATABASE ACTIONS
  Future<void> updateUserStatus(String userId, String status) async {
    // Optimistic Update: Change local state immediately for a smooth UI
    setState(() {
      final index = userList.indexWhere((u) => u['user_id'] == userId);
      if (index != -1) userList[index]['user_status'] = status;
    });

    try {
      await supabase
          .from('tbl_user')
          .update({'user_status': status})
          .eq('user_id', userId);
    } catch (e) {
      debugPrint("Update failed: $e");
      fetchUsers(); // Rollback/Refresh if DB update fails
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
        child: Text("No users found", style: TextStyle(color: Colors.white70)),
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
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.greenAccent.withOpacity(0.1),
                backgroundImage: user['user_photo'] != null
                    ? NetworkImage(user['user_photo'])
                    : null,
                child: user['user_photo'] == null
                    ? const Icon(Icons.person, color: Colors.greenAccent)
                    : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user['user_name'] ?? 'Unknown User',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                    infoRow(Icons.email_outlined, user['user_email'] ?? 'N/A'),
                    infoRow(Icons.phone_outlined, user['user_contact'] ?? 'N/A'),
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
                          updateUserStatus(user['user_id'].toString(), 'accepted'),
                    ),
                    IconButton(
                      icon: const Icon(Icons.highlight_off, color: Colors.redAccent),
                      onPressed: () =>
                          updateUserStatus(user['user_id'].toString(), 'rejected'),
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
                  buildUserList(pendingUsers, showActions: true),
                  buildUserList(acceptedUsers),
                  buildUserList(rejectedUsers),
                ],
              ),
      ),
    );
  }
}
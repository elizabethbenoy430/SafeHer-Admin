import 'dart:ui';
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
          .order('user_name', ascending: true);

      if (mounted) {
        setState(() {
          userList = response;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    }
  }

  List<dynamic> get pendingUsers => userList
      .where((u) => u['user_status'] == null || u['user_status'] == 'pending')
      .toList();

  List<dynamic> get acceptedUsers =>
      userList.where((u) => u['user_status'] == 'accepted').toList();

  List<dynamic> get rejectedUsers =>
      userList.where((u) => u['user_status'] == 'rejected').toList();

  Future<void> updateUserStatus(dynamic userId, String status) async {
    final backup = List.from(userList);

    setState(() {
      final index = userList.indexWhere((u) => u['user_id'] == userId);
      if (index != -1) {
        userList[index]['user_status'] = status;
      }
    });

    try {
      await supabase
          .from('tbl_user')
          .update({'user_status': status})
          .eq('user_id', userId);
    } catch (e) {
      setState(() => userList = backup);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Database update failed")),
      );
    }
  }

  Widget infoRow(IconData icon, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.greenAccent),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildUserList(List<dynamic> list,
      {bool showActions = false, required String tabKey}) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.group_off, color: Colors.white24, size: 60),
            const SizedBox(height: 10),
            const Text("No users found",
                style: TextStyle(color: Colors.white70)),
            TextButton(
              onPressed: fetchUsers,
              child: const Text("Refresh",
                  style: TextStyle(color: Colors.greenAccent)),
            )
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: fetchUsers,
      color: Colors.greenAccent,
      child: ListView.builder(
        key: PageStorageKey(tabKey),
        padding: const EdgeInsets.all(16),
        itemCount: list.length,
        itemBuilder: (context, index) {
          final user = list[index];

          return Container(
            key: ValueKey(user['user_id'] ?? index),
            margin: const EdgeInsets.only(bottom: 12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                    border:
                        Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 25,
                        backgroundColor:
                            Colors.greenAccent.withOpacity(0.1),
                        backgroundImage: (user['user_photo'] != null &&
                                user['user_photo'].toString().isNotEmpty)
                            ? NetworkImage(user['user_photo'])
                            : null,
                        child: (user['user_photo'] == null ||
                                user['user_photo'].toString().isEmpty)
                            ? const Icon(Icons.person,
                                color: Colors.greenAccent)
                            : null,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user['user_name'] ?? 'Unknown',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold),
                            ),
                            infoRow(Icons.email,
                                user['user_email'] ?? 'N/A'),
                          ],
                        ),
                      ),
                      if (showActions)
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.check_circle,
                                  color: Colors.greenAccent),
                              onPressed: () => updateUserStatus(
                                  user['user_id'], 'accepted'),
                            ),
                            IconButton(
                              icon: const Icon(Icons.cancel,
                                  color: Colors.redAccent),
                              onPressed: () => updateUserStatus(
                                  user['user_id'], 'rejected'),
                            ),
                          ],
                        )
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                "assets/bgl.png",
                fit: BoxFit.cover,
              ),
            ),
            Positioned.fill(
              child: Container(color: Colors.black.withOpacity(0.6)),
            ),
            SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 10),

                  const Text(
                    "User Directory",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      letterSpacing: 1,
                    ),
                  ),

                  const SizedBox(height: 10),

                  const TabBar(
                    indicatorColor: Colors.greenAccent,
                    labelColor: Colors.greenAccent,
                    unselectedLabelColor: Colors.white38,
                    tabs: [
                      Tab(text: "Pending"),
                      Tab(text: "Accepted"),
                      Tab(text: "Rejected"),
                    ],
                  ),

                  Expanded(
                    child: isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: Colors.greenAccent,
                            ),
                          )
                        : TabBarView(
                            children: [
                              buildUserList(
                                pendingUsers,
                                showActions: true,
                                tabKey: "pending",
                              ),
                              buildUserList(
                                acceptedUsers,
                                tabKey: "accepted",
                              ),
                              buildUserList(
                                rejectedUsers,
                                tabKey: "rejected",
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
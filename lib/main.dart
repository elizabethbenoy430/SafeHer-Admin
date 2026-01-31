
import 'package:admin_app/admin_registration.dart';

import 'package:flutter/material.dart';


import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  await Supabase.initialize(
    url: 'https://oaodufxcoxopwdsrpzkb.supabase.co',
    anonKey: 'sb_publishable_sTCfZJCJ5CKRDmKke9omng_ACVqydil',
  );
  runApp( MainApp());
}
    final supabase = Supabase.instance.client;    

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home:AdminRegistration()
    );
  }
}

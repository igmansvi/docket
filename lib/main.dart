import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:docket/services/auth/auth_gate.dart';

Future<void> main() async {
  await dotenv.load(fileName: '.env.local');
  await Supabase.initialize(
    url: dotenv.env['BASE_URL']!,
    anonKey: dotenv.env['API_KEY']!,
  );
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthGate(),
    );
  }
}
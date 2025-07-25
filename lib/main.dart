import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:docket/themes/theme_provider.dart';

import 'package:docket/services/auth/auth_gate.dart';

import 'package:docket/pages/login.dart';
import 'package:docket/pages/register.dart';
import 'package:docket/pages/dashboard.dart';
import 'package:docket/pages/review.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await Supabase.initialize(
    url: dotenv.env['BASE_URL']!,
    anonKey: dotenv.env['API_KEY']!,
  );
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: Provider.of<ThemeProvider>(context).themeData,
      home: const AuthGate(),
      routes: {
        '/auth': (context) => const AuthGate(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/dashboard': (context) => const Dashboard(),
        '/review': (context) => const ReviewPage(),
      },
    );
  }
}

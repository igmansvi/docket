import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:docket/components/ui/loading.dart';
import 'package:docket/pages/login.dart';
import 'package:docket/pages/dashboard.dart';
import 'package:docket/pages/review.dart';
import 'package:docket/services/auth/auth_service.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final supabase = Supabase.instance.client;
  Session? _session;
  bool _isLoadingSession = true;

  @override
  void initState() {
    super.initState();
    _initializeAuthListener();
  }

  void _initializeAuthListener() {
    _session = supabase.auth.currentSession;
    _isLoadingSession = false;

    supabase.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;

      setState(() {
        _session = session;
      });

      if (event == AuthChangeEvent.signedOut) {}
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingSession) {
      return Loading();
    } else if (_session != null) {
      return FutureBuilder<Map<String, dynamic>?>(
        future: AuthService().getUserProfile(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Loading();
          }
          final role = snapshot.data?['role'];
          if (role == 'student') {
            return Dashboard();
          } else {
            return ReviewPage();
          }
        },
      );
    } else {
      return LoginPage();
    }
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:docket/components/ui/loading.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final _supabase = Supabase.instance.client;
  late StreamSubscription<AuthState> _authSubscription;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _authSubscription = _supabase.auth.onAuthStateChange.listen((data) {
      _handleAuthStateChange(data);
    });
  }

  void _handleAuthStateChange(AuthState data) async {
    if (!mounted || _isNavigating) return;

    _isNavigating = true;
    final Session? session = data.session;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      if (session == null) {
        if (ModalRoute.of(context)?.settings.name != '/login') {
          Navigator.of(context).pushReplacementNamed('/login');
        }
      } else {
        final role =
            session.user.userMetadata?['role'] ??
            session.user.appMetadata['role'];

        if (role != null && mounted) {
          final targetRoute = role == 'student' ? '/dashboard' : '/review';

          if (ModalRoute.of(context)?.settings.name != targetRoute) {
            Navigator.of(context).pushReplacementNamed(targetRoute);
          }
        } else {
          _showErrorAndSignOut(
            'Profile Error',
            'User role not found in session.',
          );
        }
      }

      if (mounted) {
        _isNavigating = false;
      }
    });
  }

  void _showErrorAndSignOut(String title, String content) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _supabase.auth.signOut();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Loading()));
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }
}

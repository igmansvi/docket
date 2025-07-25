import 'package:flutter/material.dart';
import 'package:docket/services/auth/auth_service.dart';

import 'package:docket/components/notesheet/create_notesheet.dart';
import 'package:docket/components/notesheet/view_notesheet.dart';

class SideMenu extends StatefulWidget {
  const SideMenu({super.key});

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  final AuthService _authService = AuthService();

  void _handleLogout() async {
    try {
      await _authService.logout();
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: Colors.grey[50],
            title: Text(
              'Logout Failed',
              style: TextStyle(color: Colors.grey[800]),
            ),
            content: Text(
              e.toString(),
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.grey[50],
      child: Column(
        children: [
          Container(
            height: 120,
            width: double.infinity,
            color: Colors.blue[50],
            child: Center(
              child: Text(
                'Docket',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              children: [
                _buildMenuItem(
                  icon: Icons.home_outlined,
                  title: 'Home',
                  color: Colors.blue[300]!,
                  onTap: () {},
                ),
                _buildMenuItem(
                  icon: Icons.add_circle_outline,
                  title: 'Create Notesheet',
                  color: Colors.orange[300]!,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => CreateNotesheet(),
                      ),
                    );
                  },
                ),
                _buildMenuItem(
                  icon: Icons.list_alt_outlined,
                  title: 'View Notesheets',
                  color: Colors.blue[300]!,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => ViewNotesheet()),
                    );
                  },
                ),
                _buildMenuItem(
                  icon: Icons.settings_outlined,
                  title: 'Settings',
                  color: Colors.grey[500]!,
                  onTap: () {},
                ),
              ],
            ),
          ),
          const Spacer(),
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!, width: 0.5),
            ),
            child: ListTile(
              leading: Icon(
                Icons.logout_outlined,
                color: Colors.orange[400],
                size: 20,
              ),
              title: Text(
                'Logout',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: _handleLogout,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 4,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        leading: Icon(icon, color: color, size: 20),
        title: Text(
          title,
          style: TextStyle(
            color: Colors.grey[700],
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        hoverColor: Colors.grey[200],
        focusColor: Colors.grey[200],
      ),
    );
  }
}

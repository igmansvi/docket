import 'package:flutter/material.dart';
import 'package:docket/pages/create-notesheet.dart';
import 'package:docket/pages/view-notesheet.dart';

class DashboardDrawer extends StatelessWidget {
  final VoidCallback? onClose;
  const DashboardDrawer({super.key, this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.blue[900],
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
        ],
      ),
      child: Column(
        children: [
          Container(
            height: 80,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                const FlutterLogo(size: 36),
                const SizedBox(width: 12),
                Text(
                  'Docket',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
                const Spacer(),
                if (onClose != null)
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: onClose,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _DrawerMenuItem(icon: Icons.dashboard, label: 'Home', onTap: () {}),
          _DrawerMenuItem(
            icon: Icons.note_add_outlined,
            label: 'Create Notesheet',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const CreateNotesheetPage(),
                ),
              );
            },
          ),
          _DrawerMenuItem(
            icon: Icons.description_outlined,
            label: 'View Notesheet',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ViewNotesheetPage(),
                ),
              );
            },
          ),
          _DrawerMenuItem(
            icon: Icons.settings_outlined,
            label: 'Settings',
            onTap: () {},
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(bottom: 24.0),
            child: _DrawerMenuItem(
              icon: Icons.logout,
              label: 'Logout',
              onTap: () {},
              color: Colors.red[200],
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color? color;
  const _DrawerMenuItem({
    required this.icon,
    required this.label,
    this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: color ?? Colors.white, size: 22),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                color: color ?? Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

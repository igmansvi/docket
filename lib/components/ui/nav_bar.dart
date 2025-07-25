import 'package:flutter/material.dart';

class NavBar extends StatelessWidget implements PreferredSizeWidget {
  final String userName;
  final VoidCallback onPress;

  const NavBar({super.key, required this.userName, required this.onPress});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.grey[50],
      elevation: 1,
      shadowColor: Colors.grey[300],
      surfaceTintColor: Colors.transparent,
      title: Text(
        'Notesheet Dashboard',
        style: TextStyle(
          color: Colors.grey[700],
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
      iconTheme: IconThemeData(color: Colors.grey[600]),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 12),
          child: TextButton(
            onPressed: onPress,
            style: TextButton.styleFrom(
              backgroundColor: Colors.blue[50],
              foregroundColor: Colors.grey[700],
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.grey[200]!, width: 0.5),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.verified_user_outlined,
                  color: Colors.blue[300],
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  userName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

import 'package:flutter/material.dart';

class QuickMenu extends StatelessWidget {
  final VoidCallback onCreateNotesheetPressed;
  final VoidCallback onViewNotesheetsPressed;
  final VoidCallback? onGenerateReportPressed;

  const QuickMenu({
    super.key,
    required this.onCreateNotesheetPressed,
    required this.onViewNotesheetsPressed,
    this.onGenerateReportPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: Colors.grey[50],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!, width: 0.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          height: 500,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                height: 1,
                color: Colors.grey[300],
              ),
              _buildMenuItem(
                icon: Icons.add_circle_outline,
                title: 'Create Notesheet',
                color: Colors.orange[300]!,
                onTap: onCreateNotesheetPressed,
              ),
              _buildMenuItem(
                icon: Icons.list_alt_outlined,
                title: 'View Notesheets',
                color: Colors.blue[300]!,
                onTap: onViewNotesheetsPressed,
              ),
              if (onGenerateReportPressed != null)
                _buildMenuItem(
                  icon: Icons.report_outlined,
                  title: 'Generate Report',
                  color: Colors.grey[500]!,
                  onTap: onGenerateReportPressed!,
                ),
            ],
          ),
        ),
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
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(6)),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: Colors.grey[700],
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        hoverColor: Colors.grey[200],
      ),
    );
  }
}

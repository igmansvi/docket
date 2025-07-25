import 'package:flutter/material.dart';

class NotesheetOverview extends StatelessWidget {
  final int totalDocuments;
  final int approvedDocuments;
  final int rejectedDocuments;
  final int pendingDocuments;

  const NotesheetOverview({
    super.key,
    required this.totalDocuments,
    required this.approvedDocuments,
    required this.rejectedDocuments,
    required this.pendingDocuments,
  });

  @override
  Widget build(BuildContext context) {
    final int draftDocuments =
        totalDocuments -
        (approvedDocuments + pendingDocuments + rejectedDocuments);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 16.0,
          runSpacing: 16.0,
          children: [
            StatusCard(
              title: 'Total Documents',
              count: totalDocuments,
              icon: Icons.description_outlined,
              color: Colors.blue[300]!,
            ),
            StatusCard(
              title: 'Approved',
              count: approvedDocuments,
              icon: Icons.check_circle_outline,
              color: Colors.grey[500]!,
            ),
            StatusCard(
              title: 'Rejected',
              count: rejectedDocuments,
              icon: Icons.cancel_outlined,
              color: Colors.orange[300]!,
            ),
            StatusCard(
              title: 'Pending',
              count: pendingDocuments,
              icon: Icons.hourglass_empty_outlined,
              color: Colors.blue[400]!,
            ),
            StatusCard(
              title: 'Draft',
              count: draftDocuments,
              icon: Icons.create_new_folder_outlined,
              color: Colors.grey[400]!,
            ),
          ],
        ),
      ],
    );
  }
}

class StatusCard extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;
  final Color color;

  const StatusCard({
    super.key,
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
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
      margin: const EdgeInsets.all(8.0),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        width: 200,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, size: 28, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

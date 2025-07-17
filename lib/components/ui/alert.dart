import 'package:flutter/material.dart';

enum AlertType { success, error }

class Alert extends StatelessWidget {
  final String message;
  final AlertType type;
  final VoidCallback? onClose;

  const Alert({
    super.key,
    required this.message,
    required this.type,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor = type == AlertType.success
        ? Colors.green[50]!
        : Colors.red[50]!;
    Color iconColor = type == AlertType.success ? Colors.green : Colors.red;
    IconData icon = type == AlertType.success
        ? Icons.check_circle
        : Icons.error;
    String title = type == AlertType.success ? 'Success' : 'Error';

    return AlertDialog(
      backgroundColor: bgColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(color: iconColor, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.blue),
            onPressed: onClose ?? () => Navigator.of(context).pop(),
          ),
        ],
      ),
      content: Text(
        message,
        style: TextStyle(color: Colors.blue[900], fontSize: 16),
      ),
      actions: [
        TextButton(
          onPressed: onClose ?? () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

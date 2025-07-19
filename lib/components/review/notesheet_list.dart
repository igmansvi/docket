import 'package:flutter/material.dart';

class NotesheetList extends StatelessWidget {
  final List<Map<String, dynamic>> notesheets;
  final String? selectedId;
  final void Function(String) onSelect;

  const NotesheetList({
    super.key,
    required this.notesheets,
    required this.selectedId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: notesheets.length,
      itemBuilder: (context, index) {
        final n = notesheets[index];
        final id = n['id']?.toString() ?? '';
        return ListTile(
          title: Text(n['title'] ?? 'Untitled'),
          subtitle: Text(n['event_date'] ?? ''),
          selected: id == selectedId,
          onTap: () => onSelect(id),
        );
      },
    );
  }
}

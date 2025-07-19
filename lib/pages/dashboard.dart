import 'package:flutter/material.dart';

import '../components/dashboard/dashboard_drawer.dart';
import '../components/dashboard/profile_panel.dart';
import '../components/dashboard/overview_card.dart';
import '../components/dashboard/recent_activity_card.dart';
import '../components/dashboard/quick_actions_card.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/notesheet/notesheet_service.dart';
import '../services/review/review_service.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  bool _drawerOpen = false;
  bool _profileOpen = false;
  bool _loading = true;
  List<Map<String, dynamic>> _notesheets = [];
  Map<String, List<Map<String, dynamic>>> _recentActivities = {};
  Map<String, List<String>> _reviewers = {};
  final NotesheetService _notesheetService = NotesheetService();
  final ReviewService _reviewService = ReviewService();

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _loading = true;
    });
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id ?? '';
      final notesheets = await _notesheetService.getNotesheetsForUser(userId);
      notesheets.sort((a, b) {
        final aDate =
            DateTime.tryParse(a['event_date'] ?? '') ?? DateTime(1970);
        final bDate =
            DateTime.tryParse(b['event_date'] ?? '') ?? DateTime(1970);
        return bDate.compareTo(aDate);
      });
      final Map<String, List<Map<String, dynamic>>> activitiesMap = {};
      final Map<String, List<String>> reviewersMap = {};
      for (final n in notesheets.take(3)) {
        final id = n['id']?.toString() ?? '';
        if (id.isEmpty) continue;
        final activities = await _reviewService.getCommentsForNotesheet(id);
        final reviewers = await _notesheetService.getReviewersForNotesheet(id);
        activitiesMap[id] = activities;
        reviewersMap[id] = reviewers;
      }
      setState(() {
        _notesheets = notesheets;
        _recentActivities = activitiesMap;
        _reviewers = reviewersMap;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;
    return Scaffold(
      backgroundColor: Colors.blue[50],
      body: Stack(
        children: [
          Row(
            children: [
              if (isWide || _drawerOpen)
                DashboardDrawer(
                  onClose: () => setState(() => _drawerOpen = false),
                ),
              Expanded(
                child: Column(
                  children: [
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          if (!isWide)
                            IconButton(
                              icon: const Icon(Icons.menu, color: Colors.blue),
                              onPressed: () =>
                                  setState(() => _drawerOpen = true),
                            ),
                          if (isWide) const SizedBox(width: 8),
                          Expanded(child: Container()),
                          GestureDetector(
                            onTap: () => setState(() => _profileOpen = true),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.blue[100],
                                  child: const Icon(
                                    Icons.person,
                                    color: Colors.blue,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _notesheets.isNotEmpty &&
                                          _notesheets
                                                  .first['created_by_name'] !=
                                              null
                                      ? _notesheets.first['created_by_name']
                                      : 'User',
                                  style: TextStyle(
                                    color: Colors.blue[900],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.keyboard_arrow_down,
                                  color: Colors.blue,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: _loading
                          ? Center(
                              child: CircularProgressIndicator(
                                color: Colors.blue[700],
                              ),
                            )
                          : Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: isWide ? 32 : 8,
                                vertical: isWide ? 32 : 8,
                              ),
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  return ListView(
                                    children: [
                                      for (final n in _notesheets.take(3)) ...[
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(height: 8),
                                            Text(
                                              n['title'] ??
                                                  'Notesheet Overview',
                                              style: const TextStyle(
                                                fontSize: 22,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.blue,
                                              ),
                                            ),
                                            const SizedBox(height: 16),
                                            OverviewCard(
                                              notesheet: n,
                                              reviewers:
                                                  _reviewers[n['id']] ?? [],
                                            ),
                                            const SizedBox(height: 24),
                                            RecentActivityCard(
                                              activities:
                                                  _recentActivities[n['id']] ??
                                                  [],
                                            ),
                                            const SizedBox(height: 8),
                                            QuickActionsCard(),
                                          ],
                                        ),
                                      ],
                                    ],
                                  );
                                },
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_profileOpen)
            ProfilePanel(onClose: () => setState(() => _profileOpen = false)),
        ],
      ),
    );
  }
}

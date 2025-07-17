import 'package:flutter/material.dart';
import '../components/dashboard/dashboard_drawer.dart';
import '../components/dashboard/profile_panel.dart';
import '../components/dashboard/overview_card.dart';
import '../components/dashboard/recent_activity_card.dart';
import '../components/dashboard/quick_actions_card.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  bool _drawerOpen = false;
  bool _profileOpen = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _loading = false;
      });
    });
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
                                  'Dr. Alex Sharma',
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
                                  return Flex(
                                    direction: isWide
                                        ? Axis.horizontal
                                        : Axis.vertical,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(height: 8),
                                            const Text(
                                              'Notesheet Overview',
                                              style: TextStyle(
                                                fontSize: 22,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.blue,
                                              ),
                                            ),
                                            const SizedBox(height: 16),
                                            OverviewCard(),
                                            const SizedBox(height: 24),
                                            RecentActivityCard(),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        width: isWide ? 32 : 0,
                                        height: isWide ? 0 : 32,
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Column(
                                          children: [
                                            const SizedBox(height: 8),
                                            QuickActionsCard(),
                                          ],
                                        ),
                                      ),
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

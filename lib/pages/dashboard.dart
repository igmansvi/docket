import 'package:flutter/material.dart';
import 'package:docket/data/models/notesheet.dart';
import 'package:docket/data/models/review.dart';

import 'package:docket/services/auth/auth_service.dart';
import 'package:docket/services/review/review_service.dart';
import 'package:docket/services/notesheet/notesheet_service.dart';

import 'package:docket/components/ui/nav_bar.dart';
import 'package:docket/components/ui/side-menu.dart';
import 'package:docket/components/ui/profile_panel.dart';
import 'package:docket/components/notesheet/create_notesheet.dart';
import 'package:docket/components/notesheet/view_notesheet.dart';
import 'package:docket/components/dashboard/notesheet_overview.dart';
import 'package:docket/components/dashboard/quick_menu.dart';
import 'package:docket/components/dashboard/recent_activities.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final GlobalKey<ScaffoldState> _scaffold = GlobalKey<ScaffoldState>();
  String userName = 'User';
  final NotesheetService _notesheetService = NotesheetService();
  final AuthService _authService = AuthService();
  final ReviewService _reviewService = ReviewService();

  List<Notesheet> _allNotesheets = [];
  List<Notesheet> _filteredNotesheets = [];
  List<Review> _recentReviews = [];
  Map<String, String> _userIdToNameMap = {};
  Map<String, Notesheet> _notesheetMap = {};

  final TextEditingController _searchController = TextEditingController();
  NotesheetStatus? _selectedStatusFilter;

  late Future<void> _fetchDashboardDataFuture;

  @override
  void initState() {
    super.initState();
    _fetchDashboardDataFuture = _initializeDashboardData();
    _searchController.addListener(_filterNotesheets);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterNotesheets);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initializeDashboardData() async {
    await _fetchCurrentUser();
    await _fetchNotesheets();
    await _fetchRecentReviews();
    await _fetchUserNames();
  }

  Future<void> _fetchCurrentUser() async {
    final userProfile = await _authService.getUserProfile();
    if (userProfile != null) {
      setState(() {
        userName = userProfile['name'] ?? 'User';
      });
    }
  }

  Future<void> _fetchNotesheets() async {
    final currentUser = _authService.getCurrentUser();
    if (currentUser == null) {
      return;
    }
    try {
      final notesheets = await _notesheetService.getNotesheetsByUser(
        currentUser.id,
      );
      setState(() {
        _allNotesheets = notesheets;
        // Create a map for quick lookup
        _notesheetMap = {
          for (var notesheet in notesheets) notesheet.id!: notesheet
        };
        _filterNotesheets();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load notesheets: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _fetchRecentReviews() async {
    final currentUser = _authService.getCurrentUser();
    if (currentUser == null) {
      return;
    }
    
    try {
      // Get reviews for notesheets created by current user
      List<Review> allReviews = [];
      
      for (var notesheet in _allNotesheets) {
        final reviews = await _reviewService.getReviewsForNotesheet(notesheet.id!);
        allReviews.addAll(reviews);
      }
      
      // Sort by creation date (most recent first) and take last 10
      allReviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      setState(() {
        _recentReviews = allReviews.take(10).toList();
      });
    } catch (e) {
      setState(() {
        _recentReviews = [];
      });
    }
  }

  Future<void> _fetchUserNames() async {
    try {
      Set<String> userIds = {};

      for (var notesheet in _allNotesheets) {
        userIds.add(notesheet.createdBy);
        userIds.addAll(notesheet.reviewers);
      }

      // Add reviewer IDs from reviews
      for (var review in _recentReviews) {
        userIds.add(review.reviewerId);
      }

      Map<String, String> userNames = {};
      if (userIds.isNotEmpty) {
        final users = await _authService.getUsersByIds(userIds.toList());
        for (var user in users) {
          userNames[user['id']] = user['name'] ?? 'Unknown User';
        }
      }

      setState(() {
        _userIdToNameMap = userNames;
      });
    } catch (e) {
      setState(() {
        _userIdToNameMap = {};
      });
    }
  }

  void _filterNotesheets() {
    setState(() {
      _filteredNotesheets = _allNotesheets.where((notesheet) {
        final searchText = _searchController.text.toLowerCase();

        final creatorName =
            _userIdToNameMap[notesheet.createdBy] ?? notesheet.createdBy;
        final reviewerNames = notesheet.reviewers
            .map((reviewerId) => _userIdToNameMap[reviewerId] ?? reviewerId)
            .join(' ');

        final matchesSearch =
            notesheet.title.toLowerCase().contains(searchText) ||
            notesheet.id!.toLowerCase().contains(searchText) ||
            notesheet.description.toLowerCase().contains(searchText) ||
            creatorName.toLowerCase().contains(searchText) ||
            reviewerNames.toLowerCase().contains(searchText);

        final matchesStatus =
            _selectedStatusFilter == null ||
            notesheet.status == _selectedStatusFilter;

        return matchesSearch && matchesStatus;
      }).toList();
    });
  }

  String getUserNameById(String userId) {
    return _userIdToNameMap[userId] ?? 'Unknown User';
  }

  List<String> getReviewerNames(List<String> reviewerIds) {
    return reviewerIds
        .map((id) => _userIdToNameMap[id] ?? 'Unknown User')
        .toList();
  }

  Notesheet? getNotesheetById(String notesheetId) {
    return _notesheetMap[notesheetId];
  }

  int get _totalDocuments => _allNotesheets.length;
  int get _approvedDocuments =>
      _allNotesheets.where((n) => n.status == NotesheetStatus.approved).length;
  int get _rejectedDocuments =>
      _allNotesheets.where((n) => n.status == NotesheetStatus.rejected).length;
  int get _pendingDocuments =>
      _allNotesheets.where((n) => n.status == NotesheetStatus.pending).length;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 250, child: SideMenu()),
        const VerticalDivider(width: 0),
        Expanded(
          child: Scaffold(
            key: _scaffold,
            appBar: NavBar(
              userName: userName,
              onPress: () => _scaffold.currentState?.openEndDrawer(),
            ),
            endDrawer: const ProfilePanel(),
            body: FutureBuilder(
              future: _fetchDashboardDataFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error loading dashboard: ${snapshot.error}'),
                  );
                } else {
                  return Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              NotesheetOverview(
                                totalDocuments: _totalDocuments,
                                approvedDocuments: _approvedDocuments,
                                rejectedDocuments: _rejectedDocuments,
                                pendingDocuments: _pendingDocuments,
                              ),
                              const SizedBox(height: 24),
                              Expanded(
                                child: RecentActivities(
                                  notesheets: _filteredNotesheets,
                                  recentReviews: _recentReviews,
                                  searchController: _searchController,
                                  selectedStatusFilter: _selectedStatusFilter,
                                  getUserNameById: getUserNameById,
                                  getReviewerNames: getReviewerNames,
                                  getNotesheetById: getNotesheetById,
                                  onSearchChanged: (text) {
                                    _filterNotesheets();
                                  },
                                  onStatusFilterChanged: (status) {
                                    setState(() {
                                      _selectedStatusFilter = status;
                                      _filterNotesheets();
                                    });
                                  },
                                  onViewDetails: (notesheet) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Viewing details for ${notesheet.title}',
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          flex: 1,
                          child: QuickMenu(
                            onCreateNotesheetPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => CreateNotesheet(),
                                ),
                              );
                            },
                            onViewNotesheetsPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => ViewNotesheet(),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
            floatingActionButton: Padding(
              padding: const EdgeInsets.only(right: 16.0, bottom: 16.0),
              child: FloatingActionButton.extended(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => CreateNotesheet()),
                  );
                },
                label: const Text('Add New Notesheet'),
                icon: const Icon(Icons.add),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
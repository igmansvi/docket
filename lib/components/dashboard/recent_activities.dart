import 'package:flutter/material.dart';
import 'package:docket/data/models/review.dart';
import 'package:docket/data/models/notesheet.dart';

class RecentActivities extends StatefulWidget {
  final List<Notesheet> notesheets;
  final List<Review> recentReviews;
  final Function(String) onSearchChanged;
  final Function(NotesheetStatus?) onStatusFilterChanged;
  final Function(Notesheet) onViewDetails;
  final TextEditingController searchController;
  final NotesheetStatus? selectedStatusFilter;
  final String Function(String) getUserNameById;
  final List<String> Function(List<String>) getReviewerNames;
  final Notesheet? Function(String) getNotesheetById;

  const RecentActivities({
    super.key,
    required this.notesheets,
    required this.recentReviews,
    required this.onSearchChanged,
    required this.onStatusFilterChanged,
    required this.onViewDetails,
    required this.searchController,
    required this.selectedStatusFilter,
    required this.getUserNameById,
    required this.getReviewerNames,
    required this.getNotesheetById,
  });

  @override
  State<RecentActivities> createState() => _RecentActivitiesState();
}

class _RecentActivitiesState extends State<RecentActivities>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        const SizedBox(height: 20),
        _buildTabBar(),
        const SizedBox(height: 16),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [_buildNotesheetsTab(), _buildReviewsTab()],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Text(
          'Recent Activities',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.blue.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${widget.notesheets.length + widget.recentReviews.length}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6366F1),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: const Color(0xFF6366F1),
        unselectedLabelColor: const Color(0xFF64748B),
        labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
        tabs: [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.description_outlined, size: 16),
                const SizedBox(width: 8),
                Text('Notesheets (${widget.notesheets.length})'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.rate_review_outlined, size: 16),
                const SizedBox(width: 8),
                Text('Reviews (${widget.recentReviews.length})'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesheetsTab() {
    return Column(
      children: [
        _buildSearchAndFilter(),
        const SizedBox(height: 16),
        Expanded(child: _buildNotesheetsList()),
      ],
    );
  }

  Widget _buildReviewsTab() {
    return _buildReviewsList();
  }

  Widget _buildSearchAndFilter() {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: widget.searchController,
              onChanged: widget.onSearchChanged,
              decoration: const InputDecoration(
                hintText: 'Search notesheets...',
                hintStyle: TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: Color(0xFF94A3B8),
                  size: 20,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 16,
                ),
              ),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<NotesheetStatus?>(
              value: widget.selectedStatusFilter,
              hint: const Text(
                'All Status',
                style: TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
              onChanged: widget.onStatusFilterChanged,
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Color(0xFF94A3B8),
                size: 20,
              ),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Color(0xFF1A1A1A),
              ),
              items: <NotesheetStatus?>[null, ...NotesheetStatus.values]
                  .map<DropdownMenuItem<NotesheetStatus?>>((status) {
                    return DropdownMenuItem<NotesheetStatus?>(
                      value: status,
                      child: Text(
                        status == null ? 'All Status' : _getStatusText(status),
                      ),
                    );
                  })
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotesheetsList() {
    if (widget.notesheets.isEmpty) {
      return _buildEmptyState(
        'No notesheets found',
        Icons.description_outlined,
      );
    }

    return ListView.separated(
      itemCount: widget.notesheets.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final notesheet = widget.notesheets[index];
        return _buildNotesheetCard(notesheet);
      },
    );
  }

  Widget _buildReviewsList() {
    if (widget.recentReviews.isEmpty) {
      return _buildEmptyState(
        'No recent reviews found',
        Icons.rate_review_outlined,
      );
    }

    return ListView.separated(
      itemCount: widget.recentReviews.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final review = widget.recentReviews[index];
        return _buildReviewCard(review);
      },
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Icon(icon, size: 40, color: const Color(0xFF94A3B8)),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Try adjusting your search or filter criteria',
            style: TextStyle(fontSize: 14, color: Color(0xFF94A3B8)),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesheetCard(Notesheet notesheet) {
    final creatorName = widget.getUserNameById(notesheet.createdBy);
    final reviewerNames = widget.getReviewerNames(notesheet.reviewers);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          notesheet.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildStatusChip(notesheet.status),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ID: ${notesheet.id}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF94A3B8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => widget.onViewDetails(notesheet),
                icon: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: Color(0xFF94A3B8),
                ),
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFFF8FAFC),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.all(8),
                ),
              ),
            ],
          ),
          if (notesheet.description.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              notesheet.description,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF64748B),
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              _buildInfoChip(
                icon: Icons.person_outline_rounded,
                label: creatorName,
              ),
              const SizedBox(width: 8),
              _buildInfoChip(
                icon: Icons.schedule_rounded,
                label: _formatDate(notesheet.createdAt),
              ),
              if (reviewerNames.isNotEmpty) ...[
                const SizedBox(width: 8),
                _buildReviewersChip(reviewerNames),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(Review review) {
    final reviewerName = widget.getUserNameById(review.reviewerId);
    final notesheet = widget.getNotesheetById(review.notesheetId);
    final notesheetTitle = notesheet?.title ?? 'Unknown Notesheet';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.rate_review_outlined,
                  size: 20,
                  color: Color(0xFF6366F1),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Review by $reviewerName',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    Text(
                      'For: $notesheetTitle',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusChip(review.status),
            ],
          ),
          if (review.comment!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                review.comment!,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF475569),
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              _buildInfoChip(
                icon: Icons.schedule_rounded,
                label: _formatDate(review.createdAt),
              ),
              const SizedBox(width: 8),
              _buildInfoChip(
                icon: Icons.description_outlined,
                label: 'ID: ${review.notesheetId.substring(0, 8)}...',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(NotesheetStatus status) {
    final statusData = _getStatusData(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: statusData['color'].withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        statusData['text'],
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: statusData['color'],
        ),
      ),
    );
  }

  Widget _buildInfoChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: const Color(0xFF64748B)),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewersChip(List<String> reviewerNames) {
    final displayText = reviewerNames.length > 2
        ? '${reviewerNames.take(2).join(', ')} +${reviewerNames.length - 2}'
        : reviewerNames.join(', ');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF6366F1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.people_outline_rounded,
            size: 12,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            displayText,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getStatusData(NotesheetStatus status) {
    switch (status) {
      case NotesheetStatus.approved:
        return {'color': const Color(0xFF059669), 'text': 'Approved'};
      case NotesheetStatus.rejected:
        return {'color': const Color(0xFFDC2626), 'text': 'Rejected'};
      case NotesheetStatus.pending:
        return {'color': const Color(0xFFD97706), 'text': 'Pending'};
      case NotesheetStatus.draft:
        return {'color': const Color(0xFF6B7280), 'text': 'Draft'};
    }
  }

  String _getStatusText(NotesheetStatus status) {
    switch (status) {
      case NotesheetStatus.approved:
        return 'Approved';
      case NotesheetStatus.rejected:
        return 'Rejected';
      case NotesheetStatus.pending:
        return 'Pending';
      case NotesheetStatus.draft:
        return 'Draft';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

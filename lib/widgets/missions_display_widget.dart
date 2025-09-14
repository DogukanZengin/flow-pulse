import 'package:flutter/material.dart';
import '../models/mission.dart';
import '../services/mission_service.dart';
import '../constants/mission_constants.dart';
import 'mission_card_widget.dart';

/// Missions Display Widget for Career Screen Integration
///
/// Displays active missions in a marine-themed layout that integrates seamlessly
/// with the career screen's achievements tab. Provides mission progress tracking,
/// celebration animations, and completion feedback.
class MissionsDisplayWidget extends StatefulWidget {
  final bool compactView;
  final int maxVisible;
  final VoidCallback? onMissionCompleted;

  const MissionsDisplayWidget({
    super.key,
    this.compactView = false,
    this.maxVisible = 5,
    this.onMissionCompleted,
  });

  @override
  State<MissionsDisplayWidget> createState() => _MissionsDisplayWidgetState();
}

class _MissionsDisplayWidgetState extends State<MissionsDisplayWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _celebrationController;
  List<Mission> _activeMissions = [];
  List<Mission> _recentlyCompleted = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _celebrationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _loadMissions();
  }

  @override
  void dispose() {
    _celebrationController.dispose();
    super.dispose();
  }

  Future<void> _loadMissions() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Load active missions
      final activeMissions = await MissionService.instance.getActiveMissions();

      // Load recently completed missions (for celebration)
      final completedMissions = await MissionService.instance.getCompletedMissions();
      final recentlyCompleted = completedMissions
          .where((mission) => mission.completedAt != null)
          .where((mission) => DateTime.now().difference(mission.completedAt!).inHours < 24)
          .toList();

      if (mounted) {
        setState(() {
          _activeMissions = activeMissions;
          _recentlyCompleted = recentlyCompleted;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load missions: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _refreshMissions() async {
    await _loadMissions();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildMissionHeader(),
        const SizedBox(height: 12),
        _buildMissionContent(),
      ],
    );
  }

  Widget _buildMissionHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.indigo.withValues(alpha: 0.2),
            Colors.blue.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.indigo.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.indigo.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.assignment,
              color: Colors.indigo,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Research Missions',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getMissionSummaryText(),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          _buildQuickStats(),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    final completedCount = _activeMissions.where((m) => m.isCompleted).length;
    final totalActive = _activeMissions.length;

    return Column(
      children: [
        Row(
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              '$completedCount',
              style: const TextStyle(
                color: Colors.green,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          'of $totalActive',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildMissionContent() {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    if (_activeMissions.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        // Recently completed missions (celebration section)
        if (_recentlyCompleted.isNotEmpty) ...[
          _buildCompletedMissionsSection(),
          const SizedBox(height: 16),
        ],

        // Active missions
        _buildActiveMissionsSection(),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          CircularProgressIndicator(
            color: Colors.cyan,
            strokeWidth: 3,
          ),
          const SizedBox(height: 16),
          Text(
            'Loading research missions...',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.red.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage!,
            style: const TextStyle(
              color: Colors.red,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _refreshMissions,
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.blue.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.explore,
            color: Colors.blue,
            size: 48,
          ),
          const SizedBox(height: 16),
          const Text(
            'No Active Missions',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'New research missions will be available soon.\nComplete focus sessions to unlock new challenges!',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 12,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _refreshMissions,
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Check for Missions'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedMissionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.celebration,
              color: Colors.amber,
              size: 16,
            ),
            const SizedBox(width: 6),
            const Text(
              'Recently Completed',
              style: TextStyle(
                color: Colors.amber,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ..._recentlyCompleted.take(3).map((mission) =>
          AnimatedBuilder(
            animation: _celebrationController,
            builder: (context, child) => Transform.scale(
              scale: 1.0 + (_celebrationController.value * 0.05),
              child: MissionCardWidget(
                mission: mission,
                compactView: true,
                showRewards: false,
                onTap: () => _showMissionDetails(mission),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActiveMissionsSection() {
    // Group missions by type for better organization
    final dailyMissions = _activeMissions
        .where((m) => m.type == MissionConstants.typeDaily && !m.isCompleted)
        .take(2)
        .toList();

    final weeklyMissions = _activeMissions
        .where((m) => m.type == MissionConstants.typeWeekly && !m.isCompleted)
        .take(2)
        .toList();

    final achievementMissions = _activeMissions
        .where((m) => m.type == MissionConstants.typeAchievement && !m.isCompleted)
        .take(2)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (dailyMissions.isNotEmpty) ...[
          _buildMissionTypeHeader('Daily Missions', Icons.today, Colors.orange),
          ...dailyMissions.map((mission) =>
            MissionCardWidget(
              mission: mission,
              compactView: widget.compactView,
              onTap: () => _showMissionDetails(mission),
            ),
          ),
          if (weeklyMissions.isNotEmpty || achievementMissions.isNotEmpty)
            const SizedBox(height: 12),
        ],

        if (weeklyMissions.isNotEmpty) ...[
          _buildMissionTypeHeader('Weekly Goals', Icons.calendar_view_week, Colors.indigo),
          ...weeklyMissions.map((mission) =>
            MissionCardWidget(
              mission: mission,
              compactView: widget.compactView,
              onTap: () => _showMissionDetails(mission),
            ),
          ),
          if (achievementMissions.isNotEmpty) const SizedBox(height: 12),
        ],

        if (achievementMissions.isNotEmpty) ...[
          _buildMissionTypeHeader('Achievements', Icons.emoji_events, Colors.purple),
          ...achievementMissions.map((mission) =>
            MissionCardWidget(
              mission: mission,
              compactView: widget.compactView,
              onTap: () => _showMissionDetails(mission),
            ),
          ),
        ],

        // Show more button if there are additional missions
        if (_activeMissions.length > widget.maxVisible) ...[
          const SizedBox(height: 12),
          _buildShowMoreButton(),
        ],
      ],
    );
  }

  Widget _buildMissionTypeHeader(String title, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 6),
          Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShowMoreButton() {
    final hiddenCount = _activeMissions.length - widget.maxVisible;

    return TextButton.icon(
      onPressed: () {
        // TODO: Navigate to full missions screen or expand view
        _showAllMissions();
      },
      icon: Icon(Icons.expand_more, size: 16),
      label: Text('Show $hiddenCount more missions'),
      style: TextButton.styleFrom(
        foregroundColor: Colors.cyan,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  void _showMissionDetails(Mission mission) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildMissionDetailsSheet(mission),
    );
  }

  Widget _buildMissionDetailsSheet(Mission mission) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF1E3A5F),
            Color(0xFF0A1628),
          ],
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MissionCardWidget(
                    mission: mission,
                    compactView: false,
                    showRewards: true,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Mission Details',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    mission.description,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Close'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAllMissions() {
    // TODO: Navigate to dedicated missions screen or expand current view
    // For now, just show a dialog with mission count
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('All Missions'),
        content: Text('You have ${_activeMissions.length} active missions.\n\nA dedicated missions view will be available in a future update.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String _getMissionSummaryText() {
    if (_activeMissions.isEmpty) {
      return 'No active missions available';
    }

    final completed = _activeMissions.where((m) => m.isCompleted).length;
    final active = _activeMissions.length - completed;

    return '$active active • $completed completed today';
  }
}
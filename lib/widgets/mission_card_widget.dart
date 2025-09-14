import 'package:flutter/material.dart';
import '../models/mission.dart';
import '../constants/mission_constants.dart';
import 'mission_progress_indicator.dart';

/// Mission Card Widget with marine biology theme
///
/// Displays individual missions with progress indicators, rewards, and completion status.
/// Integrated into the career screen's achievements tab for seamless progression tracking.
class MissionCardWidget extends StatelessWidget {
  final Mission mission;
  final VoidCallback? onTap;
  final bool showRewards;
  final bool compactView;

  const MissionCardWidget({
    super.key,
    required this.mission,
    this.onTap,
    this.showRewards = true,
    this.compactView = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: compactView ? 8 : 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(compactView ? 12 : 16),
          child: Container(
            padding: EdgeInsets.all(compactView ? 12 : 16),
            decoration: BoxDecoration(
              gradient: _getCardGradient(),
              borderRadius: BorderRadius.circular(compactView ? 12 : 16),
              border: Border.all(
                color: _getBorderColor(),
                width: mission.isCompleted ? 2 : 1,
              ),
              boxShadow: mission.isCompleted
                  ? [
                      BoxShadow(
                        color: _getBorderColor().withValues(alpha:0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                _buildHeader(),

                if (!compactView) ...[
                  const SizedBox(height: 8),
                  // Description
                  _buildDescription(),
                ],

                SizedBox(height: compactView ? 8 : 12),

                // Progress Section
                _buildProgress(),

                if (showRewards && !compactView) ...[
                  const SizedBox(height: 12),
                  // Rewards Section
                  _buildRewards(),
                ],

                // Time remaining (for non-achievement missions)
                if (mission.expiresAt != null && !mission.isCompleted) ...[
                  const SizedBox(height: 8),
                  _buildTimeRemaining(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        // Mission Icon and Category
        Container(
          padding: EdgeInsets.all(compactView ? 6 : 8),
          decoration: BoxDecoration(
            color: _getCategoryColor().withValues(alpha:0.2),
            borderRadius: BorderRadius.circular(compactView ? 6 : 8),
            border: Border.all(
              color: _getCategoryColor().withValues(alpha:0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                mission.icon,
                style: TextStyle(fontSize: compactView ? 12 : 14),
              ),
              if (!compactView) ...[
                const SizedBox(width: 4),
                Text(
                  mission.difficultyIcon,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(width: 12),

        // Mission Title and Type
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                mission.title,
                style: TextStyle(
                  fontSize: compactView ? 14 : 16,
                  fontWeight: FontWeight.bold,
                  color: mission.isCompleted ? Colors.amber : Colors.white,
                ),
                maxLines: compactView ? 1 : 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (!compactView) ...[
                const SizedBox(height: 2),
                Row(
                  children: [
                    _buildMissionTypeChip(),
                    const SizedBox(width: 8),
                    _buildDifficultyChip(),
                  ],
                ),
              ],
            ],
          ),
        ),

        // Status Icon
        _buildStatusIcon(),
      ],
    );
  }

  Widget _buildDescription() {
    return Text(
      mission.description,
      style: TextStyle(
        fontSize: 13,
        color: Colors.white.withValues(alpha:0.8),
        height: 1.3,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildProgress() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: MissionProgressIndicator(
                mission: mission,
                height: compactView ? 6 : 8,
                showText: !compactView,
              ),
            ),
            if (compactView) ...[
              const SizedBox(width: 8),
              Text(
                mission.formattedProgress,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white.withValues(alpha:0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),

        if (!compactView) ...[
          const SizedBox(height: 4),
          Text(
            mission.formattedProgress,
            style: TextStyle(
              fontSize: 12,
              color: _getCategoryColor(),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildRewards() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha:0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.amber.withValues(alpha:0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.star,
            color: Colors.amber,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            '${mission.rewardRP} RP',
            style: const TextStyle(
              fontSize: 13,
              color: Colors.amber,
              fontWeight: FontWeight.w600,
            ),
          ),

          if (mission.rewardBonus != null) ...[
            const SizedBox(width: 12),
            Icon(
              Icons.card_giftcard,
              color: Colors.cyan,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              'Bonus',
              style: TextStyle(
                fontSize: 11,
                color: Colors.cyan.withValues(alpha:0.8),
              ),
            ),
          ],

          const Spacer(),

          if (mission.isCompleted) ...[
            Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 16,
            ),
            const SizedBox(width: 4),
            const Text(
              'Completed',
              style: TextStyle(
                fontSize: 11,
                color: Colors.green,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimeRemaining() {
    final timeRemaining = mission.timeRemaining;
    if (timeRemaining == null || timeRemaining == Duration.zero) return const SizedBox.shrink();

    final isUrgent = timeRemaining.inHours < 6;
    final timeText = _formatTimeRemaining(timeRemaining);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: (isUrgent ? Colors.orange : Colors.blue).withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: (isUrgent ? Colors.orange : Colors.blue).withValues(alpha:0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isUrgent ? Icons.timer : Icons.schedule,
            color: isUrgent ? Colors.orange : Colors.blue,
            size: 12,
          ),
          const SizedBox(width: 4),
          Text(
            timeText,
            style: TextStyle(
              fontSize: 10,
              color: isUrgent ? Colors.orange : Colors.blue,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIcon() {
    if (mission.isCompleted) {
      return Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha:0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.check_circle,
          color: Colors.green,
          size: 20,
        ),
      );
    } else if (mission.isExpired) {
      return Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha:0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.timer_off,
          color: Colors.red,
          size: 20,
        ),
      );
    } else if (mission.currentProgress > 0) {
      return Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.orange.withValues(alpha:0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.trending_up,
          color: Colors.orange,
          size: 20,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha:0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(
        Icons.radio_button_unchecked,
        color: Colors.blue,
        size: 20,
      ),
    );
  }

  Widget _buildMissionTypeChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: _getTypeColor().withValues(alpha:0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: _getTypeColor().withValues(alpha:0.4),
          width: 0.5,
        ),
      ),
      child: Text(
        mission.type.toUpperCase(),
        style: TextStyle(
          fontSize: 9,
          color: _getTypeColor(),
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildDifficultyChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: _getDifficultyColor().withValues(alpha:0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: _getDifficultyColor().withValues(alpha:0.4),
          width: 0.5,
        ),
      ),
      child: Text(
        mission.difficulty.toUpperCase(),
        style: TextStyle(
          fontSize: 9,
          color: _getDifficultyColor(),
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  // Helper methods for styling
  LinearGradient _getCardGradient() {
    if (mission.isCompleted) {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.green.withValues(alpha:0.15),
          Colors.teal.withValues(alpha:0.1),
        ],
      );
    } else if (mission.isExpired) {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.red.withValues(alpha:0.1),
          Colors.grey.withValues(alpha:0.05),
        ],
      );
    } else {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          _getCategoryColor().withValues(alpha:0.15),
          _getCategoryColor().withValues(alpha:0.05),
        ],
      );
    }
  }

  Color _getBorderColor() {
    if (mission.isCompleted) return Colors.green;
    if (mission.isExpired) return Colors.red;
    return _getCategoryColor().withValues(alpha:0.3);
  }

  Color _getCategoryColor() {
    switch (mission.category) {
      case MissionConstants.categoryConsistency:
        return Colors.blue;
      case MissionConstants.categoryProductivity:
        return Colors.purple;
      case MissionConstants.categoryDiscovery:
        return Colors.teal;
      case MissionConstants.categoryQuality:
        return Colors.amber;
      default:
        return Colors.cyan;
    }
  }

  Color _getTypeColor() {
    switch (mission.type) {
      case MissionConstants.typeDaily:
        return Colors.orange;
      case MissionConstants.typeWeekly:
        return Colors.indigo;
      case MissionConstants.typeAchievement:
        return Colors.purple;
      default:
        return Colors.blue;
    }
  }

  Color _getDifficultyColor() {
    switch (mission.difficulty) {
      case MissionConstants.difficultyBeginner:
        return Colors.green;
      case MissionConstants.difficultyIntermediate:
        return Colors.yellow;
      case MissionConstants.difficultyAdvanced:
        return Colors.orange;
      case MissionConstants.difficultyExpert:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatTimeRemaining(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}d ${duration.inHours % 24}h';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else {
      return '${duration.inMinutes}m';
    }
  }
}
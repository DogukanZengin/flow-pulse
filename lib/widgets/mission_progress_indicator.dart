import 'package:flutter/material.dart';
import '../models/mission.dart';
import '../constants/mission_constants.dart';

/// Mission Progress Indicator with marine-themed animations
///
/// Provides visual progress tracking for missions with smooth animations,
/// milestone celebrations, and context-aware styling based on mission category.
class MissionProgressIndicator extends StatefulWidget {
  final Mission mission;
  final double height;
  final bool showText;
  final bool showMilestones;
  final Color? primaryColor;
  final Color? backgroundColor;

  const MissionProgressIndicator({
    super.key,
    required this.mission,
    this.height = 8.0,
    this.showText = true,
    this.showMilestones = false,
    this.primaryColor,
    this.backgroundColor,
  });

  @override
  State<MissionProgressIndicator> createState() => _MissionProgressIndicatorState();
}

class _MissionProgressIndicatorState extends State<MissionProgressIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  @override
  void didUpdateWidget(MissionProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mission.progressPercentage != widget.mission.progressPercentage) {
      _updateProgress();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.mission.progressPercentage,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));


    // Start animation
    _animationController.forward();
  }

  void _updateProgress() {
    final newProgress = widget.mission.progressPercentage;

    _progressAnimation = Tween<double>(
      begin: _progressAnimation.value,
      end: newProgress,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.reset();
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Progress Bar
        _buildProgressBar(),

        // Progress Text and Milestones
        if (widget.showText || widget.showMilestones) ...[
          const SizedBox(height: 6),
          _buildProgressInfo(),
        ],
      ],
    );
  }

  Widget _buildProgressBar() {
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.height / 2),
        color: widget.backgroundColor ?? Colors.white.withValues(alpha:0.1),
      ),
      child: Stack(
        children: [
          // Background track
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.height / 2),
              color: widget.backgroundColor ?? Colors.white.withValues(alpha:0.1),
            ),
          ),

          // Animated progress fill
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return FractionallySizedBox(
                widthFactor: _progressAnimation.value,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(widget.height / 2),
                    gradient: _getProgressGradient(),
                    boxShadow: widget.mission.isCompleted
                        ? [
                            BoxShadow(
                              color: _getProgressColor().withValues(alpha:0.4),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ]
                        : null,
                  ),
                ),
              );
            },
          ),

          // Milestone markers (if enabled)
          if (widget.showMilestones) _buildMilestoneMarkers(),

          // Completion sparkle effect
          if (widget.mission.isCompleted) _buildSparkleEffect(),
        ],
      ),
    );
  }

  Widget _buildProgressInfo() {
    return Row(
      children: [
        if (widget.showText) ...[
          Expanded(
            child: Text(
              _getProgressText(),
              style: TextStyle(
                fontSize: 11,
                color: _getProgressColor(),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],

        if (widget.showMilestones && _hasVisibleMilestones()) ...[
          _buildMilestoneInfo(),
        ],
      ],
    );
  }

  Widget _buildMilestoneMarkers() {
    final milestones = _getMilestonePositions();

    return Stack(
      children: milestones.entries.map((entry) {
        final position = entry.key;
        final isReached = entry.value;

        return Positioned(
          left: position * MediaQuery.of(context).size.width * 0.8,
          top: 0,
          bottom: 0,
          child: Container(
            width: 2,
            decoration: BoxDecoration(
              color: isReached ? Colors.amber : Colors.white.withValues(alpha:0.3),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMilestoneInfo() {
    final nextMilestone = _getNextMilestone();
    if (nextMilestone == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: Colors.amber.withValues(alpha:0.3),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.flag,
            color: Colors.amber,
            size: 10,
          ),
          const SizedBox(width: 2),
          Text(
            '$nextMilestone%',
            style: const TextStyle(
              fontSize: 9,
              color: Colors.amber,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSparkleEffect() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.height / 2),
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.white.withValues(alpha:0.3 * _animationController.value),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
        );
      },
    );
  }

  // Helper Methods
  Color _getProgressColor() {
    if (widget.primaryColor != null) return widget.primaryColor!;

    if (widget.mission.isCompleted) return Colors.green;
    if (widget.mission.isExpired) return Colors.red;

    switch (widget.mission.category) {
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

  LinearGradient _getProgressGradient() {
    final baseColor = _getProgressColor();

    if (widget.mission.isCompleted) {
      return LinearGradient(
        colors: [
          Colors.green.withValues(alpha:0.8),
          Colors.teal,
          Colors.green,
        ],
        stops: const [0.0, 0.5, 1.0],
      );
    }

    return LinearGradient(
      colors: [
        baseColor.withValues(alpha:0.7),
        baseColor,
        baseColor.withValues(alpha:0.9),
      ],
      stops: const [0.0, 0.7, 1.0],
    );
  }

  String _getProgressText() {
    if (widget.mission.isCompleted) {
      return 'Completed! 🎉';
    } else if (widget.mission.isExpired) {
      return 'Expired';
    }

    final percentage = (widget.mission.progressPercentage * 100).round();
    return '$percentage% • ${widget.mission.formattedProgress}';
  }

  Map<double, bool> _getMilestonePositions() {
    // Define milestone positions (25%, 50%, 75%)
    const milestonePercentages = [0.25, 0.50, 0.75];
    final currentProgress = widget.mission.progressPercentage;

    return Map.fromEntries(
      milestonePercentages.map((milestone) =>
        MapEntry(milestone, currentProgress >= milestone)
      ),
    );
  }

  bool _hasVisibleMilestones() {
    return widget.mission.targetValue > 4 && !widget.mission.isCompleted;
  }

  int? _getNextMilestone() {
    const milestones = [25, 50, 75, 100];
    final currentPercentage = (widget.mission.progressPercentage * 100).round();

    for (final milestone in milestones) {
      if (currentPercentage < milestone) {
        return milestone;
      }
    }

    return null;
  }
}

/// Specialized progress indicator for different mission types
class MissionTypeProgressIndicator extends StatelessWidget {
  final Mission mission;
  final double size;

  const MissionTypeProgressIndicator({
    super.key,
    required this.mission,
    this.size = 40.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      child: Stack(
        children: [
          // Background circle
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha:0.1),
            ),
          ),

          // Progress circle
          CircularProgressIndicator(
            value: mission.progressPercentage,
            strokeWidth: 3,
            backgroundColor: Colors.transparent,
            valueColor: AlwaysStoppedAnimation(_getProgressColor()),
          ),

          // Center content
          Center(
            child: _getCenterWidget(),
          ),
        ],
      ),
    );
  }

  Widget _getCenterWidget() {
    if (mission.isCompleted) {
      return Icon(
        Icons.check,
        color: Colors.green,
        size: size * 0.4,
      );
    } else if (mission.isExpired) {
      return Icon(
        Icons.timer_off,
        color: Colors.red,
        size: size * 0.4,
      );
    }

    return Text(
      mission.icon,
      style: TextStyle(fontSize: size * 0.3),
    );
  }

  Color _getProgressColor() {
    if (mission.isCompleted) return Colors.green;
    if (mission.isExpired) return Colors.red;

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
}
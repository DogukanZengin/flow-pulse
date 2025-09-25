import 'package:flutter/material.dart';
import '../../../utils/responsive_helper.dart';
import '../utils/surfacing_celebration_colors.dart';

/// A responsive progress indicator widget that displays progression
/// towards the next level, career advancement, or collection milestone.
///
/// Implements Task 2.2 from EXPEDITION_SUMMARY_IMPLEMENTATION_PLAN.md
class ProgressIndicatorWidget extends StatelessWidget {
  final double currentProgress;
  final double totalRequired;
  final String progressType; // "level", "career", "collection", "milestone"
  final Color? accentColor;
  final String? nextMilestone;
  final int? rpToNext;
  final bool showMilestonePreview;

  const ProgressIndicatorWidget({
    super.key,
    required this.currentProgress,
    required this.totalRequired,
    required this.progressType,
    this.accentColor,
    this.nextMilestone,
    this.rpToNext,
    this.showMilestonePreview = true,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = totalRequired > 0
        ? (currentProgress / totalRequired * 100).clamp(0.0, 100.0)
        : 0.0;

    return ResponsiveHelper.responsiveBuilder(
      context: context,
      mobile: _buildCompactProgress(context, percentage),
      tablet: _buildStandardProgress(context, percentage),
      desktop: _buildDetailedProgress(context, percentage),
      wideDesktop: _buildDetailedProgress(context, percentage),
    );
  }

  /// Compact layout for mobile - just the progress bar with inline percentage
  Widget _buildCompactProgress(BuildContext context, double percentage) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.getResponsiveSpacing(context, 'content_spacing'),
        vertical: ResponsiveHelper.getResponsiveSpacing(context, 'small_spacing'),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: percentage / 100,
                  backgroundColor: Colors.white.withValues(alpha: 0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    accentColor ?? SurfacingCelebrationColors.surfacingGradient[2],
                  ),
                  minHeight: ResponsiveHelper.responsiveValue(
                    context: context,
                    mobile: 20.0,
                    tablet: 24.0,
                    desktop: 28.0,
                  ),
                ),
              ),
              Positioned.fill(
                child: Center(
                  child: Text(
                    '${percentage.toStringAsFixed(0)}% to next $progressType',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'caption'),
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.5),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Standard layout for tablet - progress bar with text below
  Widget _buildStandardProgress(BuildContext context, double percentage) {
    return Container(
      padding: EdgeInsets.all(
        ResponsiveHelper.getResponsiveSpacing(context, 'content_spacing'),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: Colors.white.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation<Color>(
                accentColor ?? SurfacingCelebrationColors.surfacingGradient[2],
              ),
              minHeight: 24,
            ),
          ),
          SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 'small_spacing')),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${percentage.toStringAsFixed(1)}% to next $progressType',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'body'),
                ),
              ),
              if (rpToNext != null)
                Text(
                  '${rpToNext} RP needed',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'caption'),
                  ),
                ),
            ],
          ),
          if (showMilestonePreview && nextMilestone != null)
            _buildMilestonePreview(context),
        ],
      ),
    );
  }

  /// Detailed layout for desktop - includes milestone preview
  Widget _buildDetailedProgress(BuildContext context, double percentage) {
    return Container(
      padding: EdgeInsets.all(
        ResponsiveHelper.getResponsiveSpacing(context, 'card_padding'),
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.05),
            Colors.white.withValues(alpha: 0.02),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (accentColor ?? SurfacingCelebrationColors.surfacingGradient[2])
              .withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress to Next ${_capitalizeProgressType()}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'subtitle'),
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: (accentColor ?? SurfacingCelebrationColors.surfacingGradient[2])
                      .withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${percentage.toStringAsFixed(1)}%',
                  style: TextStyle(
                    color: accentColor ?? SurfacingCelebrationColors.surfacingGradient[2],
                    fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'body'),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 'content_spacing')),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(
                accentColor ?? SurfacingCelebrationColors.surfacingGradient[2],
              ),
              minHeight: 28,
            ),
          ),
          SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 'small_spacing')),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${currentProgress.toStringAsFixed(0)} / ${totalRequired.toStringAsFixed(0)} RP',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'body'),
                ),
              ),
              if (rpToNext != null)
                Text(
                  '${rpToNext} RP to go',
                  style: TextStyle(
                    color: (accentColor ?? SurfacingCelebrationColors.surfacingGradient[2]),
                    fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'body'),
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
          if (showMilestonePreview && nextMilestone != null) ...[
            SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 'content_spacing')),
            _buildMilestonePreview(context),
          ],
        ],
      ),
    );
  }

  /// Builds a preview of the next milestone/unlock
  Widget _buildMilestonePreview(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        top: ResponsiveHelper.getResponsiveSpacing(context, 'small_spacing'),
      ),
      padding: EdgeInsets.all(
        ResponsiveHelper.getResponsiveSpacing(context, 'content_spacing'),
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            SurfacingCelebrationColors.surfacingGradient[1].withValues(alpha: 0.1),
            SurfacingCelebrationColors.surfacingGradient[2].withValues(alpha: 0.05),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: SurfacingCelebrationColors.surfacingGradient[2].withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.lock_open_rounded,
            size: ResponsiveHelper.responsiveValue(
              context: context,
              mobile: 16.0,
              tablet: 18.0,
              desktop: 20.0,
            ),
            color: SurfacingCelebrationColors.surfacingGradient[2],
          ),
          SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, 'small_spacing')),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Next Unlock',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'caption'),
                  ),
                ),
                Text(
                  nextMilestone!,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'body'),
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (rpToNext != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: SurfacingCelebrationColors.surfacingGradient[2].withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${rpToNext} RP',
                style: TextStyle(
                  color: SurfacingCelebrationColors.surfacingGradient[2],
                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'caption'),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _capitalizeProgressType() {
    if (progressType.isEmpty) return '';
    return progressType[0].toUpperCase() + progressType.substring(1);
  }
}
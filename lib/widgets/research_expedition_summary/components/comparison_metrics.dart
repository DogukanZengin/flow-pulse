import 'package:flutter/material.dart';
import '../models/expedition_result.dart';
import '../utils/biome_color_inheritance.dart';

/// Widget that displays session performance compared to other sessions
/// Shows percentile rankings and comparative metrics with graceful fallbacks
///
/// RP Calculation System (based on actual ResearchPoints model):
/// - Base RP: minutes/25*10 (e.g., 25min = 10 RP, 50min = 20 RP, max 40 RP)
/// - Quality multipliers: Perfect = 1.0x, Good = 0.85x, Abandoned = 0x
/// - Bonuses: Break +2 RP, Streak +5 RP, Perfect +1 RP (max 8 bonus RP)
/// - Max total per session: 48 RP (40 base + 8 bonus)
/// - Daily cap: 200 RP maximum
class ComparisonMetrics extends StatelessWidget {
  final ExpeditionResult expeditionResult;
  final bool showDetailedMetrics;
  final Color? primaryColor;
  final Color? accentColor;

  const ComparisonMetrics({
    super.key,
    required this.expeditionResult,
    this.showDetailedMetrics = false,
    this.primaryColor,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final biomeType = expeditionResult.sessionBiome;
    final depth = expeditionResult.sessionDepthReached;

    final effectivePrimaryColor = primaryColor ?? BiomeColorInheritance.getBiomeAccentColor(biomeType);
    final effectiveAccentColor = accentColor ?? BiomeColorInheritance.getBorderColor(biomeType, depth);

    final metrics = _calculateComparisons();

    if (metrics.isEmpty) {
      // Graceful fallback if no comparison data available
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            effectivePrimaryColor.withValues(alpha: 0.1),
            effectiveAccentColor.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: effectiveAccentColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Icons.insights,
                color: effectiveAccentColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Session Performance',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: effectiveAccentColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...metrics.map((metric) => _buildMetricRow(
            metric,
            effectivePrimaryColor,
            effectiveAccentColor,
          )),
        ],
      ),
    );
  }

  Widget _buildMetricRow(
    ComparisonMetric metric,
    Color primaryColor,
    Color accentColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  metric.label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: _getPercentileColor(metric.percentile, accentColor),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  metric.displayValue,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          if (showDetailedMetrics && metric.detail != null) ...[
            const SizedBox(height: 4),
            Text(
              metric.detail!,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.6),
              ),
            ),
          ],
          const SizedBox(height: 4),
          _buildPercentileBar(metric.percentile, primaryColor, accentColor),
        ],
      ),
    );
  }

  Widget _buildPercentileBar(double percentile, Color primaryColor, Color accentColor) {
    return Container(
      height: 4,
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(2),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              Container(
                width: constraints.maxWidth * (percentile / 100),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      accentColor.withValues(alpha: 0.8),
                      accentColor,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Color _getPercentileColor(double percentile, Color baseColor) {
    if (percentile >= 90) {
      return Colors.purple.shade400; // Top 10%
    } else if (percentile >= 75) {
      return Colors.blue.shade400; // Top 25%
    } else if (percentile >= 50) {
      return baseColor; // Above average
    } else {
      return baseColor.withValues(alpha: 0.7); // Below average
    }
  }

  List<ComparisonMetric> _calculateComparisons() {
    final metrics = <ComparisonMetric>[];

    // RP Earned Comparison
    final rpPercentile = _calculateRPPercentile(expeditionResult.rpGained);
    if (rpPercentile > 0) {
      metrics.add(ComparisonMetric(
        label: 'Research Points',
        percentile: rpPercentile,
        displayValue: 'Top ${(100 - rpPercentile).toStringAsFixed(0)}%',
        detail: '${expeditionResult.rpGained} RP earned',
      ));
    }

    // Session Quality Comparison
    final qualityPercentile = _calculateQualityPercentile(expeditionResult.qualityAssessment.qualityTier);
    if (qualityPercentile > 0) {
      metrics.add(ComparisonMetric(
        label: 'Session Quality',
        percentile: qualityPercentile,
        displayValue: 'Better than ${qualityPercentile.toStringAsFixed(0)}%',
        detail: _getQualityDescription(expeditionResult.qualityAssessment.qualityTier),
      ));
    }

    // Focus Time Comparison (if available)
    final focusMinutes = expeditionResult.sessionDurationMinutes;
    if (focusMinutes > 0) {
      final focusPercentile = _calculateFocusPercentile(focusMinutes);
      metrics.add(ComparisonMetric(
        label: 'Focus Duration',
        percentile: focusPercentile,
        displayValue: 'Top ${(100 - focusPercentile).toStringAsFixed(0)}%',
        detail: '$focusMinutes minutes',
      ));
    }

    // Streak Comparison (if has streak)
    final streak = expeditionResult.currentStreak;
    if (streak > 0) {
      final streakPercentile = _calculateStreakPercentile(streak);
      metrics.add(ComparisonMetric(
        label: 'Streak Length',
        percentile: streakPercentile,
        displayValue: 'Top ${(100 - streakPercentile).toStringAsFixed(0)}%',
        detail: '$streak day streak',
      ));
    }

    // Discovery Count Comparison
    final discoveries = expeditionResult.allDiscoveredCreatures.length;
    if (discoveries > 0) {
      final discoveryPercentile = _calculateDiscoveryPercentile(discoveries);
      metrics.add(ComparisonMetric(
        label: 'Discoveries',
        percentile: discoveryPercentile,
        displayValue: 'Top ${(100 - discoveryPercentile).toStringAsFixed(0)}%',
        detail: '$discoveries new species',
      ));
    }

    return metrics;
  }

  double _calculateRPPercentile(int rp) {
    // Based on actual RP system: max 48 RP per session (40 base + 8 bonus)
    // Formula: minutes/25*10 + bonuses, daily cap 200 RP
    if (rp >= 45) return 98.0; // Top 2% - near perfect sessions (45+ min with all bonuses)
    if (rp >= 35) return 92.0; // Top 8% - excellent sessions (30-40+ min with bonuses)
    if (rp >= 25) return 80.0; // Top 20% - solid sessions (25+ min sessions)
    if (rp >= 18) return 65.0; // Top 35% - good sessions (20+ min)
    if (rp >= 12) return 45.0; // Average - medium sessions (15+ min)
    if (rp >= 8) return 25.0;  // Below average - short sessions (10+ min)
    if (rp >= 4) return 10.0;  // Bottom 90% - very short sessions (5+ min)
    return 5.0; // Bottom 95% - minimal RP
  }

  double _calculateQualityPercentile(String? quality) {
    // Quality percentiles based on typical distribution
    switch (quality?.toLowerCase()) {
      case 'legendary':
        return 98.0; // Top 2% achieve legendary
      case 'exceptional':
        return 92.0; // Top 8% achieve exceptional
      case 'excellent':
        return 75.0; // Top 25% achieve excellent
      case 'good':
        return 50.0; // Average
      case 'solid':
        return 25.0; // Below average
      case 'learning':
        return 10.0; // Bottom 90%
      default:
        return 0.0; // No data
    }
  }

  double _calculateFocusPercentile(int minutes) {
    // Based on RP system optimal ranges and user behavior
    // Max base RP at 100+ minutes, optimal at 25 minutes (Pomodoro)
    if (minutes >= 90) return 95.0;  // 90+ min: Top 5% (near max RP)
    if (minutes >= 60) return 85.0;  // 60+ min: Top 15% (24+ base RP)
    if (minutes >= 50) return 75.0;  // 50+ min: Top 25% (20+ base RP)
    if (minutes >= 45) return 65.0;  // 45+ min: Top 35% (18+ base RP)
    if (minutes >= 30) return 50.0;  // 30+ min: Average (12+ base RP)
    if (minutes >= 25) return 40.0;  // 25+ min: Standard Pomodoro (10+ base RP)
    if (minutes >= 20) return 30.0;  // 20+ min: Below average (8+ base RP)
    if (minutes >= 15) return 20.0;  // 15+ min: Short sessions (6+ base RP)
    if (minutes >= 10) return 10.0;  // 10+ min: Very short (4+ base RP)
    return 5.0; // < 10 min: Minimal sessions
  }

  double _calculateStreakPercentile(int days) {
    // Streak distribution - most users struggle to maintain
    if (days >= 30) return 98.0;  // Month streak: Top 2%
    if (days >= 14) return 92.0;  // Two weeks: Top 8%
    if (days >= 7) return 80.0;   // One week: Top 20%
    if (days >= 3) return 60.0;   // 3 days: Top 40%
    if (days >= 2) return 40.0;   // 2 days: Top 60%
    return 20.0; // Just started
  }

  double _calculateDiscoveryPercentile(int count) {
    // Discovery count distribution per session
    if (count >= 5) return 95.0;  // Many discoveries: Top 5%
    if (count >= 3) return 80.0;  // Several: Top 20%
    if (count >= 2) return 60.0;  // Couple: Top 40%
    if (count >= 1) return 40.0;  // One: Top 60%
    return 0.0; // None
  }

  String _getQualityDescription(String? quality) {
    switch (quality?.toLowerCase()) {
      case 'legendary':
        return 'Legendary research methodology';
      case 'exceptional':
        return 'Outstanding research session';
      case 'excellent':
        return 'Solid research work';
      case 'good':
        return 'Good research session';
      case 'solid':
        return 'Steady research progress';
      case 'learning':
        return 'Building research skills';
      default:
        return 'Session completed';
    }
  }
}

/// Data model for a comparison metric
class ComparisonMetric {
  final String label;
  final double percentile;
  final String displayValue;
  final String? detail;

  const ComparisonMetric({
    required this.label,
    required this.percentile,
    required this.displayValue,
    this.detail,
  });
}
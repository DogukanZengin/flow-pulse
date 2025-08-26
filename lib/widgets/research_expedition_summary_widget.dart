import 'package:flutter/material.dart';
import '../services/gamification_service.dart';
import 'research_expedition_summary/research_expedition_summary_controller.dart';

/// Research Expedition Summary Widget - Session Completion Celebration
/// Now uses modular architecture for better maintainability and enhanced theming
/// This is a wrapper that maintains backward compatibility while using the new system
class ResearchExpeditionSummaryWidget extends StatelessWidget {
  final GamificationReward reward;
  final VoidCallback onContinue;
  final VoidCallback? onSurfaceForBreak;

  const ResearchExpeditionSummaryWidget({
    super.key,
    required this.reward,
    required this.onContinue,
    this.onSurfaceForBreak,
  });

  @override
  Widget build(BuildContext context) {
    // Use the new modular controller
    return ResearchExpeditionSummaryController(
      reward: reward,
      onContinue: onContinue,
      onSurfaceForBreak: onSurfaceForBreak,
    );
  }
}
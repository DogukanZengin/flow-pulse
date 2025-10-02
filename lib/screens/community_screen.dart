import 'package:flutter/material.dart';
import '../theme/ocean_theme_colors.dart';

/// Community Screen - Phase 4 Social Hub
/// Houses leaderboards, collaborations, and community goals
class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    // Simulate a brief loading period for the coming soon screen
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }
  
  Widget _buildComingSoonOverlay() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ocean-themed coming soon icon
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    OceanThemeColors.deepOceanBlue.withValues(alpha: 0.3),
                    OceanThemeColors.deepOceanAccent.withValues(alpha: 0.2),
                  ],
                ),
                border: Border.all(
                  color: OceanThemeColors.seafoamGreen.withValues(alpha: 0.6),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.waves,
                size: 64,
                color: OceanThemeColors.seafoamGreen,
              ),
            ),

            const SizedBox(height: 32),

            // Coming Soon text
            const Text(
              'Coming Soon',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 16),

            // Description
            const Text(
              'The Research Community is currently under development.\nConnect with marine researchers worldwide in a future update!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 32),

            // Features preview
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    OceanThemeColors.deepOceanBlue.withValues(alpha: 0.3),
                    OceanThemeColors.deepOceanAccent.withValues(alpha: 0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: OceanThemeColors.deepOceanAccent.withValues(alpha: 0.4),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Upcoming Features:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: OceanThemeColors.seafoamGreen,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildFeatureItem(Icons.leaderboard, 'Global Leaderboards'),
                  _buildFeatureItem(Icons.group_work, 'Research Collaborations'),
                  _buildFeatureItem(Icons.flag, 'Community Goals'),
                  _buildFeatureItem(Icons.school, 'Mentorship Programs'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            color: OceanThemeColors.deepOceanAccent,
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0A1628), // Deep Ocean
              Color(0xFF1E3A5F), // Ocean Blue
              Color(0xFF2E5A7A), // Light Ocean
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(
                      Icons.groups,
                      color: OceanThemeColors.seafoamGreen,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Research Community',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Collaborate with marine researchers worldwide',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Main content
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: OceanThemeColors.seafoamGreen),
                      )
                    : _buildComingSoonOverlay(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
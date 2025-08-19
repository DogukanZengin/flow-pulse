import 'package:flutter/material.dart';
import '../widgets/social_research_display_widget.dart';
import '../services/social_research_service.dart';
import '../services/gamification_service.dart';

/// Community Screen - Phase 4 Social Hub
/// Houses leaderboards, collaborations, and community goals
class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  // Current user profile
  late ResearcherProfile _currentUser;
  
  // Leaderboard data
  List<ResearcherProfile> _leaderboard = [];
  LeaderboardCategory _selectedCategory = LeaderboardCategory.totalDiscoveries;
  
  // Collaboration data
  List<CollaborationOpportunity> _collaborations = [];
  
  // Community goals
  List<CommunityGoal> _communityGoals = [];
  
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadSocialData();
  }
  
  Future<void> _loadSocialData() async {
    // Create current user profile from gamification service
    final userLevel = GamificationService.instance.currentLevel;
    
    _currentUser = ResearcherProfile(
      id: 'current_user',
      name: 'You', // In production, this would come from user settings
      researchLevel: userLevel,
      totalDiscoveries: 15, // Mock value - would come from CreatureService
      currentStreak: GamificationService.instance.currentStreak,
      researchEfficiency: 7.5,
      weeklyDiscoveries: 5,
      legendaryDiscoveries: 1,
      specialization: 'Marine Biology Research',
      joinedDate: DateTime.now().subtract(const Duration(days: 30)),
      lastActiveDate: DateTime.now(),
      achievements: 8,
      publicationsCount: 3,
      collaborationsCount: 2,
      ranking: 0, // Will be set after leaderboard generation
    );
    
    setState(() {
      // Generate leaderboards
      _leaderboard = SocialResearchService.generateLeaderboards(
        _currentUser,
        _selectedCategory,
      );
      
      // Get collaboration opportunities
      _collaborations = SocialResearchService.getCollaborationOpportunities(_currentUser);
      
      // Get community goals
      _communityGoals = SocialResearchService.getCommunityGoals();
      
      _isLoading = false;
    });
  }
  
  void _onCategoryChange(LeaderboardCategory category) {
    setState(() {
      _selectedCategory = category;
      _leaderboard = SocialResearchService.generateLeaderboards(
        _currentUser,
        category,
      );
    });
  }
  
  void _onJoinCollaboration(CollaborationOpportunity collaboration) {
    // In production, this would handle joining a collaboration
    showDialog(
      context: context,
      builder: (context) => _buildCollaborationDialog(collaboration),
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
                      color: Colors.cyan,
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
                    // User rank badge
                    if (!_isLoading)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: _getRankColors(_currentUser.ranking),
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _currentUser.rankingDisplay,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              
              // Main content
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.cyan),
                      )
                    : SocialResearchDisplayWidget(
                        leaderboard: _leaderboard,
                        collaborations: _collaborations,
                        communityGoals: _communityGoals,
                        currentUser: _currentUser,
                        selectedCategory: _selectedCategory,
                        onCategoryChange: _onCategoryChange,
                        onJoinCollaboration: _onJoinCollaboration,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  List<Color> _getRankColors(int rank) {
    switch (rank) {
      case 1:
        return [Colors.amber, Colors.yellow];
      case 2:
        return [Colors.grey, Colors.white];
      case 3:
        return [Colors.orange, Colors.deepOrange];
      default:
        if (rank <= 10) return [Colors.blue, Colors.cyan];
        return [Colors.blue.shade800, Colors.blue.shade600];
    }
  }
  
  Widget _buildCollaborationDialog(CollaborationOpportunity collaboration) {
    return Dialog(
      backgroundColor: const Color(0xFF1E3A5F),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              collaboration.category.color.withValues(alpha: 0.3),
              collaboration.category.color.withValues(alpha: 0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: collaboration.category.color.withValues(alpha: 0.5),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getCollaborationIcon(collaboration.category),
                  color: collaboration.category.color,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    collaboration.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              collaboration.description,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Rewards:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.star, color: Colors.amber, size: 16),
                const SizedBox(width: 4),
                Text(
                  '+${collaboration.rewards.xpBonus} XP',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.amber,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(Icons.badge, color: Colors.purple, size: 16),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    collaboration.rewards.specialBadge,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.purple,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.pets, color: Colors.green, size: 16),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    collaboration.rewards.exclusiveSpecies,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.green,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Requirements:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            ...collaboration.requirements.map((req) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    collaboration.isEligible ? Icons.check_circle : Icons.cancel,
                    color: collaboration.isEligible ? Colors.green : Colors.red,
                    size: 14,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      req,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                ],
              ),
            )),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: collaboration.completionPercentage,
              backgroundColor: Colors.grey.withValues(alpha: 0.3),
              valueColor: AlwaysStoppedAnimation<Color>(collaboration.category.color),
            ),
            const SizedBox(height: 8),
            Text(
              '${collaboration.currentParticipants}/${collaboration.maxParticipants} participants',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${collaboration.daysRemaining} days remaining',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange.withValues(alpha: 0.8),
                  ),
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: collaboration.isEligible
                          ? () {
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Joined: ${collaboration.title}'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: collaboration.category.color,
                        disabledBackgroundColor: Colors.grey.withValues(alpha: 0.3),
                      ),
                      child: Text(
                        collaboration.isEligible ? 'Join Collaboration' : 'Requirements Not Met',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  IconData _getCollaborationIcon(CollaborationType type) {
    switch (type) {
      case CollaborationType.expedition:
        return Icons.explore;
      case CollaborationType.conservation:
        return Icons.eco;
      case CollaborationType.documentation:
        return Icons.description;
      case CollaborationType.mentorship:
        return Icons.school;
    }
  }
}
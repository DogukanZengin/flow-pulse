import 'package:flutter/material.dart';
import '../services/social_research_service.dart';

/// Social Research Display Widget - Phase 4 Social Hub UI
/// Multi-tab interface for leaderboards, collaborations, and community goals
class SocialResearchDisplayWidget extends StatefulWidget {
  final List<ResearcherProfile> leaderboard;
  final List<CollaborationOpportunity> collaborations;
  final List<CommunityGoal> communityGoals;
  final ResearcherProfile currentUser;
  final LeaderboardCategory selectedCategory;
  final Function(LeaderboardCategory) onCategoryChange;
  final Function(CollaborationOpportunity) onJoinCollaboration;

  const SocialResearchDisplayWidget({
    super.key,
    required this.leaderboard,
    required this.collaborations,
    required this.communityGoals,
    required this.currentUser,
    required this.selectedCategory,
    required this.onCategoryChange,
    required this.onJoinCollaboration,
  });

  @override
  State<SocialResearchDisplayWidget> createState() => _SocialResearchDisplayWidgetState();
}

class _SocialResearchDisplayWidgetState extends State<SocialResearchDisplayWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Clean Tab Bar - Matching Career Tab Style
        Container(
          margin: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.04,
          ),
          height: 48,
          child: TabBar(
            controller: _tabController,
            indicatorColor: Colors.cyan,
            indicatorWeight: 3,
            indicatorPadding: const EdgeInsets.symmetric(horizontal: 8),
            dividerColor: Colors.transparent,
            labelColor: Colors.cyan,
            unselectedLabelColor: Colors.white60,
            labelStyle: TextStyle(
              fontSize: MediaQuery.of(context).size.width < 400 ? 11 : 12,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: TextStyle(
              fontSize: MediaQuery.of(context).size.width < 400 ? 10 : 11,
              fontWeight: FontWeight.w400,
            ),
            labelPadding: const EdgeInsets.symmetric(horizontal: 4),
            tabAlignment: TabAlignment.fill,
            tabs: [
              Tab(
                icon: Icon(Icons.leaderboard, 
                  size: MediaQuery.of(context).size.width < 400 ? 18 : 20),
                text: MediaQuery.of(context).size.width < 400 ? 'Leaders' : 'Leaderboards',
                height: 48,
              ),
              Tab(
                icon: Icon(Icons.handshake, 
                  size: MediaQuery.of(context).size.width < 400 ? 18 : 20),
                text: MediaQuery.of(context).size.width < 400 ? 'Collabs' : 'Collaborations',
                height: 48,
              ),
              Tab(
                icon: Icon(Icons.groups, 
                  size: MediaQuery.of(context).size.width < 400 ? 18 : 20),
                text: 'Community',
                height: 48,
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Tab content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildLeaderboardsTab(),
              _buildCollaborationsTab(),
              _buildCommunityTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardsTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick Stats Card - Matching Career Tab Style
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.cyan.withValues(alpha: 0.2),
                  Colors.blue.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.cyan.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.leaderboard, color: Colors.cyan, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Research Rankings',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  'Your Rank: #${widget.currentUser.ranking}',
                  style: TextStyle(
                    color: Colors.cyan,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          // Category selector - Improved Mobile Design
          Container(
            height: 40,
            margin: const EdgeInsets.only(bottom: 16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: LeaderboardCategory.values.length,
              itemBuilder: (context, index) {
                final category = LeaderboardCategory.values[index];
                final isSelected = category == widget.selectedCategory;
                
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: ElevatedButton(
                    onPressed: () => widget.onCategoryChange(category),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSelected ? Colors.cyan : Colors.transparent,
                      side: BorderSide(color: Colors.cyan.withValues(alpha: 0.5)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    child: Text(
                      _getCategoryDisplayName(category),
                      style: TextStyle(
                        color: isSelected ? Colors.black : Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Leaderboard list - Enhanced Card Design
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.leaderboard.length,
            itemBuilder: (context, index) {
              final researcher = widget.leaderboard[index];
              final isCurrentUser = researcher.id == widget.currentUser.id;
              
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isCurrentUser
                        ? [Colors.cyan.withValues(alpha: 0.2), Colors.blue.withValues(alpha: 0.1)]
                        : [Colors.black.withValues(alpha: 0.2), Colors.black.withValues(alpha: 0.05)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isCurrentUser ? Colors.cyan : Colors.white.withValues(alpha: 0.1),
                    width: isCurrentUser ? 2 : 1,
                  ),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: _getRankColors(researcher.ranking),
                      ),
                      border: Border.all(color: Colors.white, width: 1),
                    ),
                    child: Center(
                      child: Text(
                        researcher.rankingDisplay,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    researcher.name,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text(
                    researcher.specialization,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8), 
                      fontSize: 12,
                    ),
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _getCategoryValue(researcher, widget.selectedCategory),
                        style: TextStyle(
                          color: Colors.cyan,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        'Level ${researcher.researchLevel}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCollaborationsTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Collaboration Overview Card
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.blue.withValues(alpha: 0.2),
                  Colors.indigo.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.blue.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.handshake, color: Colors.blue, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Research Collaborations',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  '${widget.collaborations.where((c) => c.isEligible).length} Available',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          // Collaborations List
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.collaborations.length,
            itemBuilder: (context, index) {
              final collaboration = widget.collaborations[index];
              
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _getCollaborationColor(collaboration.category).withValues(alpha: 0.2),
                      _getCollaborationColor(collaboration.category).withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _getCollaborationColor(collaboration.category).withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _getCollaborationIcon(collaboration.category),
                      color: _getCollaborationColor(collaboration.category),
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        collaboration.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getCollaborationColor(collaboration.category),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        collaboration.category.displayName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                Text(
                  collaboration.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Progress bar
                LinearProgressIndicator(
                  value: collaboration.completionPercentage,
                  backgroundColor: Colors.grey.withValues(alpha: 0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getCollaborationColor(collaboration.category),
                  ),
                ),
                
                const SizedBox(height: 8),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${collaboration.currentParticipants}/${collaboration.maxParticipants} participants',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                    Text(
                      '${collaboration.daysRemaining} days remaining',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Rewards:',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '+${collaboration.rewards.xpBonus} XP',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.amber,
                            ),
                          ),
                          Text(
                            collaboration.rewards.specialBadge,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.purple,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: collaboration.isEligible
                          ? () => widget.onJoinCollaboration(collaboration)
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _getCollaborationColor(collaboration.category),
                        disabledBackgroundColor: Colors.grey.withValues(alpha: 0.3),
                      ),
                      child: Text(
                        collaboration.isEligible ? 'Join' : 'Requirements Not Met',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
          ),
        ],
      ),
    );
  }

  Widget _buildCommunityTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Community Overview Card
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.purple.withValues(alpha: 0.2),
                  Colors.indigo.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.purple.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.groups, color: Colors.purple, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Community Goals',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  '${widget.communityGoals.where((g) => g.progressPercentage < 1.0).length} Active',
                  style: TextStyle(
                    color: Colors.purple,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          // Community Goals List
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.communityGoals.length,
            itemBuilder: (context, index) {
              final goal = widget.communityGoals[index];
              
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _getCommunityGoalColor(goal.category).withValues(alpha: 0.2),
                      _getCommunityGoalColor(goal.category).withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _getCommunityGoalColor(goal.category).withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _getCommunityGoalIcon(goal.category),
                      color: _getCommunityGoalColor(goal.category),
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        goal.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Text(
                      '${goal.daysRemaining} days',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                Text(
                  goal.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Progress display
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Progress: ${goal.currentProgress.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} / ${goal.targetProgress.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${(goal.progressPercentage * 100).toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 14,
                        color: _getCommunityGoalColor(goal.category),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                LinearProgressIndicator(
                  value: goal.progressPercentage,
                  backgroundColor: Colors.grey.withValues(alpha: 0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getCommunityGoalColor(goal.category),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Rewards section
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Community Rewards:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '+${goal.rewards.globalXpBonus} XP for all',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.amber,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.badge, color: Colors.purple, size: 16),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              goal.rewards.specialBadge,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.purple,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.lock_open, color: Colors.green, size: 16),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              goal.rewards.exclusiveContent,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.green,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
          ),
        ],
      ),
    );
  }

  String _getCategoryDisplayName(LeaderboardCategory category) {
    switch (category) {
      case LeaderboardCategory.totalDiscoveries:
        return 'Discoveries';
      case LeaderboardCategory.researchLevel:
        return 'Level';
      case LeaderboardCategory.currentStreak:
        return 'Streak';
      case LeaderboardCategory.researchEfficiency:
        return 'Efficiency';
      case LeaderboardCategory.weeklyDiscoveries:
        return 'Weekly';
      case LeaderboardCategory.legendaryDiscoveries:
        return 'Legendary';
    }
  }

  String _getCategoryValue(ResearcherProfile researcher, LeaderboardCategory category) {
    switch (category) {
      case LeaderboardCategory.totalDiscoveries:
        return researcher.totalDiscoveries.toString();
      case LeaderboardCategory.researchLevel:
        return 'Level ${researcher.researchLevel}';
      case LeaderboardCategory.currentStreak:
        return '${researcher.currentStreak} days';
      case LeaderboardCategory.researchEfficiency:
        return '${researcher.researchEfficiency.toStringAsFixed(1)}x';
      case LeaderboardCategory.weeklyDiscoveries:
        return '${researcher.weeklyDiscoveries} this week';
      case LeaderboardCategory.legendaryDiscoveries:
        return '${researcher.legendaryDiscoveries} legendary';
    }
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

  Color _getCollaborationColor(CollaborationType type) {
    switch (type) {
      case CollaborationType.expedition:
        return Colors.blue;
      case CollaborationType.conservation:
        return Colors.green;
      case CollaborationType.documentation:
        return Colors.purple;
      case CollaborationType.mentorship:
        return Colors.orange;
    }
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

  Color _getCommunityGoalColor(CommunityGoalCategory category) {
    switch (category) {
      case CommunityGoalCategory.discoveries:
        return Colors.cyan;
      case CommunityGoalCategory.conservation:
        return Colors.green;
      case CommunityGoalCategory.research:
        return Colors.purple;
    }
  }

  IconData _getCommunityGoalIcon(CommunityGoalCategory category) {
    switch (category) {
      case CommunityGoalCategory.discoveries:
        return Icons.explore;
      case CommunityGoalCategory.conservation:
        return Icons.eco;
      case CommunityGoalCategory.research:
        return Icons.science;
    }
  }
}
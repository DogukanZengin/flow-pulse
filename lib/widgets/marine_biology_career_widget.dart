import 'package:flutter/material.dart';
import '../models/creature.dart';
import '../services/marine_biology_career_service.dart';
import '../utils/responsive_helper.dart';

/// Marine Biology Career Progression Widget
/// Shows current level, title, XP progress, certifications, and achievements
class MarineBiologyCareerWidget extends StatefulWidget {
  final int totalXP;
  final List<Creature> discoveredCreatures;
  final VoidCallback? onTap;

  const MarineBiologyCareerWidget({
    super.key,
    required this.totalXP,
    required this.discoveredCreatures,
    this.onTap,
  });

  @override
  State<MarineBiologyCareerWidget> createState() => _MarineBiologyCareerWidgetState();
}

class _MarineBiologyCareerWidgetState extends State<MarineBiologyCareerWidget>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _levelUpController;
  late Animation<double> _progressAnimation;
  late Animation<double> _scaleAnimation;
  
  int _currentLevel = 1;
  int _nextLevelXP = 100;
  int _currentLevelXP = 0;
  String _careerTitle = 'Marine Biology Intern';
  String _specialization = 'General Marine Biology';
  List<ResearchCertification> _certifications = [];
  ResearchMetrics? _metrics;

  @override
  void initState() {
    super.initState();
    
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _levelUpController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _levelUpController,
      curve: Curves.elasticOut,
    ));
    
    _updateCareerStats();
    _progressController.forward();
  }

  @override
  void didUpdateWidget(MarineBiologyCareerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (oldWidget.totalXP != widget.totalXP || 
        oldWidget.discoveredCreatures.length != widget.discoveredCreatures.length) {
      final oldLevel = _currentLevel;
      _updateCareerStats();
      
      // Trigger level up animation if level increased
      if (_currentLevel > oldLevel) {
        _levelUpController.forward().then((_) {
          _levelUpController.reverse();
        });
      }
      
      _progressController.reset();
      _progressController.forward();
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    _levelUpController.dispose();
    super.dispose();
  }

  void _updateCareerStats() async {
    final level = MarineBiologyCareerService.getLevelFromXP(widget.totalXP);
    final title = MarineBiologyCareerService.getCareerTitle(level);
    final specialization = MarineBiologyCareerService.getResearchSpecialization(widget.discoveredCreatures);
    final certifications = MarineBiologyCareerService.getCertifications(
      widget.discoveredCreatures,
      widget.totalXP,
      level,
    );
    
    final nextLevelXP = MarineBiologyCareerService.getXPRequiredForLevel(level + 1);
    final currentLevelXP = level > 1 ? MarineBiologyCareerService.getXPRequiredForLevel(level) : 0;
    
    // Get session metrics (mock data for now - should come from actual session tracking)
    final metrics = MarineBiologyCareerService.calculateResearchMetrics(
      widget.discoveredCreatures,
      100, // Mock total sessions
      6000, // Mock total session time in minutes
    );
    
    setState(() {
      _currentLevel = level;
      _careerTitle = title;
      _specialization = specialization;
      _certifications = certifications;
      _nextLevelXP = nextLevelXP;
      _currentLevelXP = currentLevelXP;
      _metrics = metrics;
    });
  }

  @override
  Widget build(BuildContext context) {
    final progressToNextLevel = _nextLevelXP > _currentLevelXP 
        ? (widget.totalXP - _currentLevelXP) / (_nextLevelXP - _currentLevelXP)
        : 1.0;
    
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: EdgeInsets.all(ResponsiveHelper.getResponsiveSpacing(context, 'card')),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF1A237E).withValues(alpha: 0.9),
              const Color(0xFF3F51B5).withValues(alpha: 0.9),
              _getLevelColor().withValues(alpha: 0.3),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _getLevelColor().withValues(alpha: 0.5),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: _getLevelColor().withValues(alpha: 0.3),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with level and title
            Row(
              children: [
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    width: ResponsiveHelper.isMobile(context) ? 45 : 50,
                    height: ResponsiveHelper.isMobile(context) ? 45 : 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          _getLevelColor(),
                          _getLevelColor().withValues(alpha: 0.7),
                        ],
                      ),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.8),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '$_currentLevel',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'subtitle'),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                
                SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, 'card')),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _careerTitle,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'subtitle'),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _specialization,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 'element')),
                      Text(
                        '${widget.totalXP.toStringAsFixed(0)} XP',
                        style: TextStyle(
                          color: _getLevelColor(),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                
                if (_certifications.isNotEmpty) ...[
                  Container(
                    padding: EdgeInsets.all(ResponsiveHelper.getResponsiveSpacing(context, 'navigation')),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.verified,
                          color: Colors.amber,
                          size: ResponsiveHelper.getIconSize(context, 'small'),
                        ),
                        SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, 'element')),
                        Text(
                          '${_certifications.length}',
                          style: const TextStyle(
                            color: Colors.amber,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            
            SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 'card')),
            
            // XP Progress Bar
            Row(
              children: [
                Text(
                  'Level $_currentLevel',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                Text(
                  'Level ${_currentLevel + 1}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            
            SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 'navigation')),
            
            AnimatedBuilder(
              animation: _progressAnimation,
              builder: (context, child) {
                return LinearProgressIndicator(
                  value: progressToNextLevel * _progressAnimation.value,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(_getLevelColor()),
                  minHeight: 8,
                );
              },
            ),
            
            SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 'element')),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${widget.totalXP - _currentLevelXP} / ${_nextLevelXP - _currentLevelXP} XP',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'caption'),
                  ),
                ),
                Text(
                  '${(progressToNextLevel * 100).toStringAsFixed(1)}%',
                  style: TextStyle(
                    color: _getLevelColor(),
                    fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'caption'),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            
            if (_metrics != null) ...[
              SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 'card')),
              
              // Research Metrics
              Container(
                padding: EdgeInsets.all(ResponsiveHelper.getResponsiveSpacing(context, 'navigation')),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.analytics,
                          color: Colors.cyan,
                          size: ResponsiveHelper.getIconSize(context, 'small'),
                        ),
                        SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, 'navigation')),
                        const Text(
                          'Research Metrics',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 'navigation')),
                    
                    Row(
                      children: [
                        Expanded(
                          child: _buildMetricItem(
                            'Discoveries',
                            '${_metrics!.totalDiscoveries}',
                            Icons.explore,
                            Colors.green,
                          ),
                        ),
                        Expanded(
                          child: _buildMetricItem(
                            'Efficiency',
                            _metrics!.researchEfficiency.toStringAsFixed(1),
                            Icons.speed,
                            Colors.orange,
                          ),
                        ),
                        Expanded(
                          child: _buildMetricItem(
                            'Recent',
                            '${_metrics!.recentDiscoveries}',
                            Icons.trending_up,
                            Colors.purple,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
            
            // Recent Certifications Preview
            if (_certifications.isNotEmpty) ...[
              SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 'navigation')),
              Row(
                children: [
                  const Icon(
                    Icons.emoji_events,
                    color: Colors.amber,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Latest Certification:',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _certifications.last.name,
                      style: const TextStyle(
                        color: Colors.amber,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
            
            SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 'navigation')),
            
            // Tap indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.touch_app,
                  color: Colors.white.withValues(alpha: 0.5),
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  'Tap for details',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'caption'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: ResponsiveHelper.getIconSize(context, 'small'),
        ),
        SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 'element')),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 10,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Color _getLevelColor() {
    if (_currentLevel >= 100) return Colors.purple;
    if (_currentLevel >= 75) return Colors.orange;
    if (_currentLevel >= 50) return Colors.amber;
    if (_currentLevel >= 25) return Colors.green;
    return Colors.cyan;
  }
}

/// Detailed Career Progress Screen
class MarineBiologyCareerScreen extends StatefulWidget {
  final int totalXP;
  final List<Creature> discoveredCreatures;

  const MarineBiologyCareerScreen({
    super.key,
    required this.totalXP,
    required this.discoveredCreatures,
  });

  @override
  State<MarineBiologyCareerScreen> createState() => _MarineBiologyCareerScreenState();
}

class _MarineBiologyCareerScreenState extends State<MarineBiologyCareerScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  List<ResearchCertification> _certifications = [];
  List<ResearchAchievement> _achievements = [];
  ResearchMetrics? _metrics;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadCareerData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadCareerData() {
    final level = MarineBiologyCareerService.getLevelFromXP(widget.totalXP);
    final certifications = MarineBiologyCareerService.getCertifications(
      widget.discoveredCreatures,
      widget.totalXP,
      level,
    );
    
    final metrics = MarineBiologyCareerService.calculateResearchMetrics(
      widget.discoveredCreatures,
      100, // Mock data
      6000,
    );
    
    final achievements = MarineBiologyCareerService.getResearchAchievements(
      widget.discoveredCreatures,
      level,
      metrics,
    );
    
    setState(() {
      _certifications = certifications;
      _metrics = metrics;
      _achievements = achievements;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A237E),
        title: const Text(
          '🎓 Marine Biology Career',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.cyan,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withValues(alpha: 0.7),
          tabs: const [
            Tab(text: 'Overview', icon: Icon(Icons.person)),
            Tab(text: 'Certifications', icon: Icon(Icons.emoji_events)),
            Tab(text: 'Achievements', icon: Icon(Icons.star)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildCertificationsTab(),
          _buildAchievementsTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          MarineBiologyCareerWidget(
            totalXP: widget.totalXP,
            discoveredCreatures: widget.discoveredCreatures,
          ),
          
          const SizedBox(height: 20),
          
          if (_metrics != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF1A237E).withValues(alpha: 0.8),
                    const Color(0xFF3F51B5).withValues(alpha: 0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '📊 Detailed Research Metrics',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'title'),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 'card')),
                  
                  _buildDetailedMetric(
                    'Total Discoveries',
                    '${_metrics!.totalDiscoveries}',
                    'Species documented in research journal',
                    Icons.explore,
                    Colors.green,
                  ),
                  
                  _buildDetailedMetric(
                    'Research Efficiency',
                    _metrics!.researchEfficiency.toStringAsFixed(2),
                    'Weighted discoveries per hour',
                    Icons.speed,
                    Colors.orange,
                  ),
                  
                  _buildDetailedMetric(
                    'Discoveries per Session',
                    _metrics!.discoveriesPerSession.toStringAsFixed(2),
                    'Average species found per expedition',
                    Icons.schedule,
                    Colors.blue,
                  ),
                  
                  _buildDetailedMetric(
                    'Biodiversity Index',
                    '${(_metrics!.diversityIndex * 100).toStringAsFixed(1)}%',
                    'Research diversity across biomes',
                    Icons.eco,
                    Colors.purple,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailedMetric(String title, String value, String description, IconData icon, Color color) {
    return Container(
      margin: EdgeInsets.only(bottom: ResponsiveHelper.getResponsiveSpacing(context, 'card')),
      padding: EdgeInsets.all(ResponsiveHelper.getResponsiveSpacing(context, 'card')),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: ResponsiveHelper.isMobile(context) ? 35 : 40,
            height: ResponsiveHelper.isMobile(context) ? 35 : 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: ResponsiveHelper.getIconSize(context, 'small'),
            ),
          ),
          SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, 'card')),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'title'),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCertificationsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _certifications.length,
      itemBuilder: (context, index) {
        final certification = _certifications[index];
        return _buildCertificationCard(certification);
      },
    );
  }

  Widget _buildCertificationCard(ResearchCertification certification) {
    return Container(
      margin: EdgeInsets.only(bottom: ResponsiveHelper.getResponsiveSpacing(context, 'card')),
      padding: EdgeInsets.all(ResponsiveHelper.getResponsiveSpacing(context, 'card')),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1A237E).withValues(alpha: 0.8),
            Colors.amber.withValues(alpha: 0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.amber.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: ResponsiveHelper.isMobile(context) ? 45 : 50,
            height: ResponsiveHelper.isMobile(context) ? 45 : 50,
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                certification.icon,
                style: TextStyle(fontSize: ResponsiveHelper.getIconSize(context, 'large')),
              ),
            ),
          ),
          SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, 'card')),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  certification.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  certification.description,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 'element')),
                Text(
                  'Earned: ${certification.earnedAt}',
                  style: const TextStyle(
                    color: Colors.amber,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _achievements.length,
      itemBuilder: (context, index) {
        final achievement = _achievements[index];
        return _buildAchievementCard(achievement);
      },
    );
  }

  Widget _buildAchievementCard(ResearchAchievement achievement) {
    return Container(
      margin: EdgeInsets.only(bottom: ResponsiveHelper.getResponsiveSpacing(context, 'card')),
      padding: EdgeInsets.all(ResponsiveHelper.getResponsiveSpacing(context, 'card')),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1A237E).withValues(alpha: 0.8),
            Colors.green.withValues(alpha: 0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.green.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                achievement.icon,
                style: TextStyle(fontSize: ResponsiveHelper.getIconSize(context, 'large')),
              ),
              SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, 'navigation')),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      achievement.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      achievement.description,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${achievement.current}/${achievement.target}',
                style: const TextStyle(
                  color: Colors.green,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 'navigation')),
          LinearProgressIndicator(
            value: achievement.progress,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
          ),
        ],
      ),
    );
  }
}
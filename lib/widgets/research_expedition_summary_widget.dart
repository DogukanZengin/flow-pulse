import 'package:flutter/material.dart';
import 'dart:math';
import '../services/gamification_service.dart';
import '../models/creature.dart';

/// Research Expedition Summary Widget - Session Completion Celebration
/// Displays comprehensive session rewards and accomplishments with marine biology theme
class ResearchExpeditionSummaryWidget extends StatefulWidget {
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
  State<ResearchExpeditionSummaryWidget> createState() => _ResearchExpeditionSummaryWidgetState();
}

class _ResearchExpeditionSummaryWidgetState extends State<ResearchExpeditionSummaryWidget>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _surfacingController;
  late AnimationController _statsController;
  late AnimationController _celebrationController;
  late AnimationController _staggerController;
  
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _surfacingAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _statsAnimation;
  late Animation<double> _celebrationAnimation;
  
  // Staggered section reveal animations
  late Animation<double> _careerSectionAnimation;
  late Animation<double> _discoverySectionAnimation;
  late Animation<double> _equipmentSectionAnimation;
  late Animation<double> _streakSectionAnimation;
  
  // Dynamic celebration intensity based on session accomplishments
  late double _celebrationIntensity;
  
  // Pagination state
  int _currentPage = 0;
  late List<RewardPageData> _rewardPages;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();

    // Calculate celebration intensity based on session accomplishments
    _celebrationIntensity = _calculateCelebrationIntensity();
    
    // Initialize reward pages
    _initializeRewardPages();
    
    // Initialize page controller
    _pageController = PageController(initialPage: 0);

    // Initialize animation controllers with dynamic durations based on intensity
    _mainController = AnimationController(
      duration: Duration(milliseconds: (1000 * (0.7 + (_celebrationIntensity * 0.6))).round()),
      vsync: this,
    );
    
    _surfacingController = AnimationController(
      duration: Duration(milliseconds: (1500 * (0.8 + (_celebrationIntensity * 0.4))).round()),
      vsync: this,
    );
    
    _statsController = AnimationController(
      duration: Duration(milliseconds: (800 * (0.7 + (_celebrationIntensity * 0.6))).round()),
      vsync: this,
    );
    
    _celebrationController = AnimationController(
      duration: Duration(milliseconds: (2000 * _celebrationIntensity).round().clamp(500, 3000)),
      vsync: this,
    );
    
    _staggerController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Initialize animations with intensity-based curves
    final mainCurve = _celebrationIntensity > 0.7 ? Curves.elasticOut : Curves.easeInOut;
    final scaleCurve = _celebrationIntensity > 0.5 ? Curves.bounceOut : Curves.elasticOut;
    final statsCurve = _celebrationIntensity > 0.8 ? Curves.elasticOut : Curves.easeOutBack;
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: mainCurve,
    ));

    _surfacingAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _surfacingController,
      curve: _celebrationIntensity > 0.6 ? Curves.bounceOut : Curves.easeOutCubic,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8 - (_celebrationIntensity * 0.2), // More dramatic entrance for high intensity
      end: 1.0 + (_celebrationIntensity * 0.1),   // Slight overshoot for celebration
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: scaleCurve,
    ));

    _statsAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _statsController,
      curve: statsCurve,
    ));
    
    _celebrationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _celebrationController,
      curve: Curves.elasticOut,
    ));
    
    // Staggered section animations for smooth reveals
    _careerSectionAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _staggerController,
      curve: const Interval(0.0, 0.3, curve: Curves.easeOutBack),
    ));
    
    _discoverySectionAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _staggerController,
      curve: const Interval(0.15, 0.5, curve: Curves.easeOutBack),
    ));
    
    _equipmentSectionAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _staggerController,
      curve: const Interval(0.3, 0.7, curve: Curves.easeOutBack),
    ));
    
    _streakSectionAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _staggerController,
      curve: const Interval(0.5, 1.0, curve: Curves.easeOutBack),
    ));

    // Start animations
    _startAnimations();
  }

  void _startAnimations() async {
    // Surfacing from depth animation with intensity-based timing
    _surfacingController.forward();
    await Future.delayed(Duration(milliseconds: (500 * (1 - _celebrationIntensity * 0.3)).round()));
    
    // Main content fade in
    _mainController.forward();
    await Future.delayed(Duration(milliseconds: (300 * (1 - _celebrationIntensity * 0.2)).round()));
    
    // Statistics animation
    _statsController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    
    // Start staggered section reveals
    _staggerController.forward();
    
    // Celebration effects for high intensity sessions
    if (_celebrationIntensity > 0.6) {
      await Future.delayed(const Duration(milliseconds: 400));
      _celebrationController.forward();
    }
  }

  @override
  void dispose() {
    _mainController.dispose();
    _surfacingController.dispose();
    _statsController.dispose();
    _celebrationController.dispose();
    _staggerController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    
    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.95),
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _fadeAnimation, 
          _surfacingAnimation, 
          _scaleAnimation, 
          _statsAnimation, 
          _celebrationAnimation,
          _careerSectionAnimation,
          _discoverySectionAnimation,
          _equipmentSectionAnimation,
          _streakSectionAnimation,
        ]),
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: Stack(
              children: [
                // Deep ocean to research station background
                _buildBackgroundGradient(),
                
                // Surfacing animation overlay
                _buildSurfacingOverlay(),
                
                // Main expedition summary content
                _buildMainContent(screenSize),
                
                // Celebration particles for high intensity sessions
                if (_celebrationIntensity > 0.6)
                  _buildCelebrationParticles(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBackgroundGradient() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Color(0xFF0D1B2A), // Deep ocean blue
            Color(0xFF1B263B), // Mid-ocean
            Color(0xFF415A77), // Research station blue
            Color(0xFF778DA9), // Surface light
          ],
        ),
      ),
    );
  }

  Widget _buildSurfacingOverlay() {
    return AnimatedBuilder(
      animation: _surfacingController,
      builder: (context, child) {
        final progress = _surfacingController.value;
        
        return SlideTransition(
          position: _surfacingAnimation,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                stops: const [0.0, 0.2, 0.5, 0.8, 1.0],
                colors: [
                  // Deep ocean (start)
                  const Color(0xFF0B1426).withValues(alpha: 0.9 - progress * 0.9),
                  // Mid depth
                  const Color(0xFF1B4D72).withValues(alpha: 0.7 - progress * 0.7),
                  // Shallow waters  
                  Colors.blue.withValues(alpha: 0.5 - progress * 0.5),
                  // Near surface
                  Colors.lightBlue.withValues(alpha: 0.3 - progress * 0.3),
                  // Surface/research station
                  Colors.cyan.withValues(alpha: 0.1 - progress * 0.1),
                ],
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated surfacing icon
                  Transform.scale(
                    scale: 1.0 + (1.0 - progress) * 0.5,
                    child: Icon(
                      Icons.keyboard_double_arrow_up,
                      size: 48 + (1.0 - progress) * 24,
                      color: Colors.white.withValues(alpha: 1.0 - progress),
                    ),
                  ),
                  
                  SizedBox(height: 16 + (1.0 - progress) * 8),
                  
                  // Animated expedition complete text
                  Transform.scale(
                    scale: 1.0 + (1.0 - progress) * 0.2,
                    child: Text(
                      widget.reward.hasSignificantAccomplishments
                          ? '🏆 SURFACING WITH DISCOVERIES! 🏆'
                          : '🌊 SURFACING FROM EXPEDITION 🌊',
                      style: TextStyle(
                        fontSize: 20 + (1.0 - progress) * 8,
                        fontWeight: FontWeight.bold,
                        color: Colors.white.withValues(alpha: 1.0 - progress),
                        letterSpacing: 2.0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  
                  // Depth indicator with fade
                  SizedBox(height: 12 + (1.0 - progress) * 8),
                  
                  if (widget.reward.sessionDepthReached > 0)
                    FadeTransition(
                      opacity: AlwaysStoppedAnimation(1.0 - progress),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: Colors.cyan.withValues(alpha: 0.6),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.straighten, color: Colors.cyan, size: 16),
                            const SizedBox(width: 8),
                            Text(
                              'Max Depth: ${widget.reward.sessionDepthReached.toStringAsFixed(1)}m',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  
                  // Floating bubbles effect during surfacing
                  if (progress < 0.8)
                    CustomPaint(
                      size: const Size(200, 100),
                      painter: _BubbleEffectPainter(
                        progress: progress,
                        bubbleCount: (_celebrationIntensity * 15).round().clamp(5, 20),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMainContent(Size screenSize) {
    final isSmallScreen = screenSize.height < 700 || screenSize.width < 400;
    
    return Center(
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: screenSize.width * 0.92,
          height: screenSize.height * 0.85, // Limit height for smaller screens
          constraints: BoxConstraints(
            maxWidth: isSmallScreen ? 380 : 600,
            maxHeight: screenSize.height * 0.9,
          ),
          margin: EdgeInsets.all(isSmallScreen ? 12 : 20),
          padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF1A237E).withValues(alpha: 0.9),
                const Color(0xFF3F51B5).withValues(alpha: 0.9),
                const Color(0xFF2196F3).withValues(alpha: 0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
            border: Border.all(
              color: Colors.cyan.withValues(alpha: 0.5),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.cyan.withValues(alpha: 0.3),
                blurRadius: isSmallScreen ? 15 : 20,
                spreadRadius: isSmallScreen ? 3 : 5,
              ),
            ],
          ),
          child: Column(
            children: [
              // Expedition completion header (always visible)
              _buildExpeditionHeader(),
              
              const SizedBox(height: 16),
              
              // Page indicator
              _buildPageIndicator(),
              
              const SizedBox(height: 16),
              
              // Current page content
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _rewardPages.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    final page = _rewardPages[index];
                    return FadeTransition(
                      opacity: _statsAnimation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.3),
                          end: Offset.zero,
                        ).animate(_statsAnimation),
                        child: _buildPageContent(page),
                      ),
                    );
                  },
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Navigation buttons
              _buildNavigationButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpeditionHeader() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 350;
        
        return Column(
          children: [
            // Main title with celebration
            Text(
              widget.reward.hasSignificantAccomplishments
                  ? '🏆 EXPEDITION COMPLETE! 🏆'
                  : '⚓ RESEARCH DIVE COMPLETE ⚓',
              style: TextStyle(
                fontSize: isSmallScreen ? 18 : 24,
                fontWeight: FontWeight.bold,
                color: widget.reward.hasSignificantAccomplishments 
                    ? Colors.amber 
                    : Colors.cyan,
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.8),
                    blurRadius: 10,
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
            
            SizedBox(height: isSmallScreen ? 8 : 12),
            
            // Session type and duration
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 12 : 16, 
                vertical: isSmallScreen ? 6 : 8
              ),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: Colors.cyan.withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.schedule, color: Colors.white, size: isSmallScreen ? 16 : 20),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          '${widget.reward.sessionDurationMinutes} minutes',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 14 : 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (widget.reward.sessionDepthReached > 0) ...[
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.straighten, color: Colors.cyan, size: isSmallScreen ? 14 : 16),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'Depth: ${widget.reward.sessionDepthReached.toStringAsFixed(1)}m',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 12 : 14,
                              color: Colors.cyan,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSessionStatistics() {
    return AnimatedBuilder(
      animation: _statsAnimation,
      builder: (context, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final isSmallScreen = constraints.maxWidth < 350;
            
            return Column(
              children: [
                // Primary XP display with dynamic scaling based on celebration intensity
                Transform.scale(
                  scale: 1.0 + (_statsAnimation.value * (0.1 + _celebrationIntensity * 0.15)),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 16 : 20, 
                      vertical: isSmallScreen ? 12 : 16
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.green.withValues(alpha: 0.3),
                          Colors.teal.withValues(alpha: 0.3),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: Colors.green.withValues(alpha: 0.6),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('💎', style: TextStyle(fontSize: isSmallScreen ? 20 : 24)),
                            SizedBox(width: isSmallScreen ? 8 : 12),
                            Flexible(
                              child: Text(
                                '+${widget.reward.xpGained} Research XP',
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 20 : 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
            
                SizedBox(height: isSmallScreen ? 12 : 16),
                
                // XP breakdown
                if (widget.reward.streakBonusXP > 0 || 
                    widget.reward.depthBonusXP > 0 || 
                    widget.reward.completionBonusXP > 0)
                  _buildXPBreakdown(isSmallScreen: isSmallScreen),
                  
                SizedBox(height: isSmallScreen ? 12 : 16),
                  
                // Session quality indicator
                _buildSessionQuality(isSmallScreen: isSmallScreen),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildXPBreakdown({required bool isSmallScreen}) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.cyan.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Research Bonuses:',
            style: TextStyle(
              fontSize: isSmallScreen ? 12 : 14,
              color: Colors.cyan,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: isSmallScreen ? 6 : 8),
          
          if (widget.reward.streakBonusXP > 0) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '🔥 Consistency Streak (${widget.reward.currentStreak} days)',
                    style: TextStyle(fontSize: isSmallScreen ? 10 : 12, color: Colors.white),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '+${widget.reward.streakBonusXP} XP',
                  style: TextStyle(fontSize: isSmallScreen ? 10 : 12, color: Colors.orange),
                ),
              ],
            ),
          ],
          
          if (widget.reward.depthBonusXP > 0) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '🌊 Deep Research Bonus (${widget.reward.sessionDepthReached.toStringAsFixed(1)}m)',
                    style: TextStyle(fontSize: isSmallScreen ? 10 : 12, color: Colors.white),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '+${widget.reward.depthBonusXP} XP',
                  style: TextStyle(fontSize: isSmallScreen ? 10 : 12, color: Colors.blue),
                ),
              ],
            ),
          ],
          
          if (widget.reward.completionBonusXP > 0) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '✅ Session Completion',
                    style: TextStyle(fontSize: isSmallScreen ? 10 : 12, color: Colors.white),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '+${widget.reward.completionBonusXP} XP',
                  style: TextStyle(fontSize: isSmallScreen ? 10 : 12, color: Colors.green),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSessionQuality({required bool isSmallScreen}) {
    final efficiency = widget.reward.researchEfficiency;
    String qualityText = '';
    Color qualityColor = Colors.white;
    String qualityEmoji = '';
    
    if (efficiency >= 8.0) {
      qualityText = 'EXCEPTIONAL RESEARCH';
      qualityColor = Colors.amber;
      qualityEmoji = '🏆';
    } else if (efficiency >= 6.0) {
      qualityText = 'EXCELLENT RESEARCH';
      qualityColor = Colors.green;
      qualityEmoji = '⭐';
    } else if (efficiency >= 4.0) {
      qualityText = 'GOOD RESEARCH';
      qualityColor = Colors.lightBlue;
      qualityEmoji = '🎯';
    } else if (efficiency >= 2.0) {
      qualityText = 'SOLID RESEARCH';
      qualityColor = Colors.cyan;
      qualityEmoji = '📊';
    } else {
      qualityText = 'RESEARCH LOGGED';
      qualityColor = Colors.grey;
      qualityEmoji = '📝';
    }
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 12 : 16, 
        vertical: isSmallScreen ? 6 : 8
      ),
      decoration: BoxDecoration(
        color: qualityColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: qualityColor.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(qualityEmoji, style: TextStyle(fontSize: isSmallScreen ? 16 : 20)),
          SizedBox(width: isSmallScreen ? 6 : 8),
          Flexible(
            child: Text(
              qualityText,
              style: TextStyle(
                fontSize: isSmallScreen ? 12 : 14,
                fontWeight: FontWeight.bold,
                color: qualityColor,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCareerProgressSection() {
    return AnimatedBuilder(
      animation: _statsAnimation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.amber.withValues(alpha: 0.2),
                Colors.orange.withValues(alpha: 0.2),
                Colors.deepOrange.withValues(alpha: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: Colors.amber.withValues(alpha: 0.6),
              width: 2,
            ),
          ),
          child: Column(
            children: [
              // Career progression header
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    widget.reward.leveledUp ? Icons.trending_up : Icons.military_tech,
                    color: Colors.amber,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      widget.reward.leveledUp ? '🚀 RESEARCH ADVANCEMENT!' : '📋 CAREER UPDATE',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Level progression display
              if (widget.reward.leveledUp) 
                _buildLevelProgression(),
              
              const SizedBox(height: 12),
              
              // Career title changes
              if (widget.reward.careerTitleChanged)
                _buildCareerTitleTransition(),
                
              // Next milestone hint
              if (widget.reward.nextCareerMilestone != null)
                _buildNextCareerMilestone(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLevelProgression() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.amber.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Level transition display
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Old level
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Level ${widget.reward.oldLevel}',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Animated arrow
              AnimatedBuilder(
                animation: _statsAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 1.0 + (_statsAnimation.value * (0.3 + _celebrationIntensity * 0.2)),
                    child: const Icon(
                      Icons.arrow_forward,
                      color: Colors.amber,
                      size: 24,
                    ),
                  );
                },
              ),
              
              const SizedBox(width: 16),
              
              // New level with celebration
              AnimatedBuilder(
                animation: _statsAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 1.0 + (_statsAnimation.value * (0.2 + _celebrationIntensity * 0.15)),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.amber.withValues(alpha: 0.8),
                            Colors.orange.withValues(alpha: 0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.amber,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.amber.withValues(alpha: 0.5),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Text(
                        'Level ${widget.reward.newLevel}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Level up celebration text
          Text(
            '🎓 Advanced to Level ${widget.reward.newLevel} Research Capability!',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.amber,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCareerTitleTransition() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.blue.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.school, color: Colors.blue, size: 20),
              SizedBox(width: 8),
              Text(
                'CAREER ADVANCEMENT',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Title transition
          Column(
            children: [
              // Old title
              if (widget.reward.oldCareerTitle != null) ...[
                Text(
                  widget.reward.oldCareerTitle!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.withValues(alpha: 0.8),
                    decoration: TextDecoration.lineThrough,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
              ],
              
              // New title with celebration
              AnimatedBuilder(
                animation: _statsAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 1.0 + (_statsAnimation.value * 0.1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.blue.withValues(alpha: 0.3),
                            Colors.cyan.withValues(alpha: 0.3),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.blue.withValues(alpha: 0.6),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        widget.reward.newCareerTitle ?? 'Marine Researcher',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          Text(
            '🏆 Promoted to ${widget.reward.newCareerTitle}!',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.blue,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNextCareerMilestone() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.indigo.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.indigo.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.flag, color: Colors.indigo, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              widget.reward.nextCareerMilestone!,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.lightBlue,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpeciesDiscoverySection() {
    return AnimatedBuilder(
      animation: _statsAnimation,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.only(top: 24),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.teal.withValues(alpha: 0.2),
                Colors.green.withValues(alpha: 0.2),
                Colors.lightGreen.withValues(alpha: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: Colors.teal.withValues(alpha: 0.6),
              width: 2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Discovery section header
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.explore, color: Colors.teal, size: 24),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      '🐠 SPECIES DISCOVERED! 🐠',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Discovery summary
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.teal.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  'This expedition yielded ${widget.reward.allDiscoveredCreatures.length} new marine species for your research journal!',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Species cards
              ...widget.reward.allDiscoveredCreatures.map((creature) {
                if (creature is Creature) {
                  return _buildCreatureCard(creature);
                }
                return const SizedBox.shrink();
              }),
              
              // Research value summary
              _buildResearchValueSummary(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCreatureCard(Creature creature) {
    final rarityColor = _getCreatureRarityColor(creature.rarity);
    final rarityEmoji = _getCreatureRarityEmoji(creature.rarity);
    
    return AnimatedBuilder(
      animation: _statsAnimation,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: Transform.scale(
            scale: 1.0 + (_statsAnimation.value * 0.05),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.4),
                    rarityColor.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: rarityColor.withValues(alpha: 0.5),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: rarityColor.withValues(alpha: 0.3),
                    blurRadius: 6,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Creature emoji/icon
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          rarityColor.withValues(alpha: 0.3),
                          rarityColor.withValues(alpha: 0.1),
                        ],
                      ),
                      border: Border.all(
                        color: rarityColor.withValues(alpha: 0.5),
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        _getCreatureEmoji(creature.habitat),
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Creature details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name and rarity
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                creature.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: rarityColor.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: rarityColor.withValues(alpha: 0.6),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                '$rarityEmoji ${creature.rarity.displayName}',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: rarityColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 4),
                        
                        // Scientific name
                        Text(
                          creature.species,
                          style: TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                        
                        const SizedBox(height: 6),
                        
                        // Habitat and research value
                        Row(
                          children: [
                            Icon(
                              Icons.place,
                              size: 14,
                              color: Colors.teal.withValues(alpha: 0.8),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              creature.habitat.displayName,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.teal.withValues(alpha: 0.9),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '+${creature.pearlValue} XP',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.amber,
                                fontWeight: FontWeight.bold,
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
          ),
        );
      },
    );
  }

  Widget _buildResearchValueSummary() {
    final totalResearchValue = widget.reward.allDiscoveredCreatures
        .whereType<Creature>()
        .fold<int>(0, (sum, creature) => sum + creature.pearlValue);
        
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.amber.withValues(alpha: 0.2),
            Colors.orange.withValues(alpha: 0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.amber.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('📊', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 8),
          Text(
            'Total Research Value: +$totalResearchValue XP',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.amber,
            ),
          ),
        ],
      ),
    );
  }

  Color _getCreatureRarityColor(CreatureRarity rarity) {
    switch (rarity) {
      case CreatureRarity.common:
        return Colors.green;
      case CreatureRarity.uncommon:
        return Colors.blue;
      case CreatureRarity.rare:
        return Colors.purple;
      case CreatureRarity.legendary:
        return Colors.orange;
    }
  }

  String _getCreatureRarityEmoji(CreatureRarity rarity) {
    switch (rarity) {
      case CreatureRarity.common:
        return '⭐';
      case CreatureRarity.uncommon:
        return '⭐⭐';
      case CreatureRarity.rare:
        return '⭐⭐⭐';
      case CreatureRarity.legendary:
        return '⭐⭐⭐⭐';
    }
  }

  String _getCreatureEmoji(BiomeType habitat) {
    switch (habitat) {
      case BiomeType.shallowWaters:
        return '🐠'; // Tropical fish
      case BiomeType.coralGarden:
        return '🐟'; // Fish
      case BiomeType.deepOcean:
        return '🦈'; // Shark
      case BiomeType.abyssalZone:
        return '🐙'; // Octopus
    }
  }

  Widget _buildEquipmentAchievementSection() {
    return AnimatedBuilder(
      animation: _statsAnimation,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.only(top: 24),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.purple.withValues(alpha: 0.2),
                Colors.indigo.withValues(alpha: 0.2),
                Colors.blue.withValues(alpha: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: Colors.purple.withValues(alpha: 0.6),
              width: 2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section header
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.construction, color: Colors.purple, size: 24),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      '🎒 RESEARCH PROGRESS 🎒',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Equipment unlocks section
              if (widget.reward.unlockedEquipment.isNotEmpty)
                _buildEquipmentUnlocksSection(),
              
              // Achievement unlocks section  
              if (widget.reward.unlockedAchievements.isNotEmpty)
                _buildAchievementUnlocksSection(),
                
              // Progress hints section
              if (widget.reward.nextEquipmentHint != null)
                _buildProgressHintsSection(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEquipmentUnlocksSection() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.orange.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Equipment unlocks header
          Row(
            children: [
              const Icon(Icons.build_circle, color: Colors.orange, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'NEW RESEARCH EQUIPMENT UNLOCKED',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Equipment list
          ...widget.reward.unlockedEquipment.map((equipmentId) {
            return _buildEquipmentItem(equipmentId);
          }),
          
          // Summary
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.orange.withValues(alpha: 0.4),
                width: 1,
              ),
            ),
            child: Text(
              '🔬 ${widget.reward.unlockedEquipment.length} new research tools added to your marine biology laboratory!',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEquipmentItem(String equipmentId) {
    // Create a display name from equipment ID
    final displayName = _formatEquipmentName(equipmentId);
    final equipmentEmoji = _getEquipmentEmoji(equipmentId);
    
    return AnimatedBuilder(
      animation: _statsAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_statsAnimation.value * 0.03),
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.orange.withValues(alpha: 0.1),
                  Colors.amber.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.orange.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                // Equipment icon
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.orange.withValues(alpha: 0.3),
                        Colors.orange.withValues(alpha: 0.1),
                      ],
                    ),
                    border: Border.all(
                      color: Colors.orange.withValues(alpha: 0.4),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      equipmentEmoji,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // Equipment name
                Expanded(
                  child: Text(
                    displayName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                
                // "NEW" badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'NEW',
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAchievementUnlocksSection() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.amber.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Achievement unlocks header
          Row(
            children: [
              const Icon(Icons.emoji_events, color: Colors.amber, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'RESEARCH ACHIEVEMENTS EARNED',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.visible,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Achievement list
          ...widget.reward.unlockedAchievements.map((achievement) {
            return _buildAchievementItem(achievement);
          }),
          
          // Summary
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.amber.withValues(alpha: 0.4),
                width: 1,
              ),
            ),
            child: Text(
              '🏆 ${widget.reward.unlockedAchievements.length} new marine biology achievement${widget.reward.unlockedAchievements.length == 1 ? '' : 's'} earned!',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementItem(Achievement achievement) {
    return AnimatedBuilder(
      animation: _statsAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_statsAnimation.value * 0.03),
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  achievement.color.withValues(alpha: 0.1),
                  achievement.color.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: achievement.color.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                // Achievement icon
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        achievement.color.withValues(alpha: 0.3),
                        achievement.color.withValues(alpha: 0.1),
                      ],
                    ),
                    border: Border.all(
                      color: achievement.color.withValues(alpha: 0.4),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    achievement.icon,
                    size: 18,
                    color: achievement.color,
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // Achievement details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        achievement.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        achievement.description,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Achievement sparkle
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: achievement.color.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Text(
                    '✨',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressHintsSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.indigo.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.indigo.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress hints header
          Row(
            children: [
              const Icon(Icons.lightbulb, color: Colors.lightBlue, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'RESEARCH PROGRESS HINTS',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Equipment hint
          if (widget.reward.nextEquipmentHint != null)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: Colors.indigo.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  const Text('🔧', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.reward.nextEquipmentHint!,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.lightBlue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _formatEquipmentName(String equipmentId) {
    // Convert camelCase/snake_case to readable format
    return equipmentId
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  String _getEquipmentEmoji(String equipmentId) {
    // Map equipment IDs to emojis based on type
    final lowerCaseId = equipmentId.toLowerCase();
    
    if (lowerCaseId.contains('mask') || lowerCaseId.contains('snorkel')) return '🤿';
    if (lowerCaseId.contains('scuba') || lowerCaseId.contains('oxygen')) return '🛠️';
    if (lowerCaseId.contains('camera') || lowerCaseId.contains('photo')) return '📷';
    if (lowerCaseId.contains('light') || lowerCaseId.contains('torch')) return '🔦';
    if (lowerCaseId.contains('sonar') || lowerCaseId.contains('radar')) return '📡';
    if (lowerCaseId.contains('computer') || lowerCaseId.contains('digital')) return '💻';
    if (lowerCaseId.contains('sampler') || lowerCaseId.contains('collection')) return '🧪';
    if (lowerCaseId.contains('detector') || lowerCaseId.contains('scanner')) return '🔍';
    if (lowerCaseId.contains('boat') || lowerCaseId.contains('vessel')) return '⛵';
    if (lowerCaseId.contains('suit') || lowerCaseId.contains('armor')) return '🦺';
    
    // Default equipment emoji
    return '⚙️';
  }

  Widget _buildStreakEfficiencySection() {
    return AnimatedBuilder(
      animation: _statsAnimation,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.only(top: 24),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.deepOrange.withValues(alpha: 0.2),
                Colors.orange.withValues(alpha: 0.2),
                Colors.amber.withValues(alpha: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: Colors.orange.withValues(alpha: 0.6),
              width: 2,
            ),
          ),
          child: Column(
            children: [
              // Section header
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.local_fire_department, color: Colors.orange, size: 24),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      '🔥 RESEARCH CONSISTENCY 🔥',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.visible,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Streak and efficiency display
              Row(
                children: [
                  // Streak information
                  Expanded(
                    child: _buildStreakDisplay(),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Research efficiency
                  Expanded(
                    child: _buildEfficiencyDisplay(),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Streak progression and benefits
              _buildStreakBenefits(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStreakDisplay() {
    final streakTier = _getStreakTier(widget.reward.currentStreak);
    final streakColor = _getStreakTierColor(streakTier);
    final streakEmoji = _getStreakTierEmoji(streakTier);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.black.withValues(alpha: 0.4),
            streakColor.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: streakColor.withValues(alpha: 0.5),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          // Streak count with animation
          AnimatedBuilder(
            animation: _statsAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 + (_statsAnimation.value * 0.1),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      streakEmoji,
                      style: const TextStyle(fontSize: 24),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${widget.reward.currentStreak}',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: streakColor,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          
          const SizedBox(height: 8),
          
          // Streak tier
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: streakColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: streakColor.withValues(alpha: 0.4),
                width: 1,
              ),
            ),
            child: Text(
              streakTier,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: streakColor,
              ),
            ),
          ),
          
          const SizedBox(height: 6),
          
          Text(
            'Day${widget.reward.currentStreak == 1 ? '' : 's'} Consecutive',
            style: const TextStyle(
              fontSize: 11,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEfficiencyDisplay() {
    final efficiency = widget.reward.researchEfficiency;
    final efficiencyTier = _getEfficiencyTier(efficiency);
    final efficiencyColor = _getEfficiencyTierColor(efficiencyTier);
    final efficiencyEmoji = _getEfficiencyTierEmoji(efficiencyTier);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.black.withValues(alpha: 0.4),
            efficiencyColor.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: efficiencyColor.withValues(alpha: 0.5),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          // Efficiency score with animation
          AnimatedBuilder(
            animation: _statsAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 + (_statsAnimation.value * 0.1),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      efficiencyEmoji,
                      style: const TextStyle(fontSize: 24),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      efficiency.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: efficiencyColor,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          
          const SizedBox(height: 8),
          
          // Efficiency tier
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: efficiencyColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: efficiencyColor.withValues(alpha: 0.4),
                width: 1,
              ),
            ),
            child: Text(
              efficiencyTier,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: efficiencyColor,
              ),
            ),
          ),
          
          const SizedBox(height: 6),
          
          const Text(
            'Research Efficiency',
            style: TextStyle(
              fontSize: 11,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakBenefits() {
    final multiplier = widget.reward.streakMultiplier;
    final nextStreakMilestone = _getNextStreakMilestone(widget.reward.currentStreak);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.orange.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Current streak benefits
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // XP Multiplier
              Column(
                children: [
                  Text(
                    '${(multiplier * 100).round()}%',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'XP Bonus',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              
              // Streak bonus XP earned this session
              Column(
                children: [
                  Text(
                    '+${widget.reward.streakBonusXP}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Streak XP',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              
              // Research quality indicator
              Column(
                children: [
                  Text(
                    _getResearchQualityIcon(widget.reward.researchEfficiency),
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Quality',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          // Next streak milestone
          if (nextStreakMilestone != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.deepOrange.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.deepOrange.withValues(alpha: 0.4),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.flag, color: Colors.deepOrange, size: 16),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      nextStreakMilestone,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.deepOrange,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Helper methods for streak and efficiency tiers
  String _getStreakTier(int streak) {
    if (streak >= 100) return 'Ocean Legend';
    if (streak >= 30) return 'Abyss Master';
    if (streak >= 14) return 'Ocean Pioneer';
    if (streak >= 7) return 'Current Rider';
    if (streak >= 3) return 'Reef Navigator';
    if (streak >= 1) return 'Tide Pool Explorer';
    return 'Starting Out';
  }

  Color _getStreakTierColor(String tier) {
    switch (tier) {
      case 'Ocean Legend': return Colors.purple;
      case 'Abyss Master': return Colors.deepPurple;
      case 'Ocean Pioneer': return Colors.indigo;
      case 'Current Rider': return Colors.blue;
      case 'Reef Navigator': return Colors.teal;
      case 'Tide Pool Explorer': return Colors.green;
      default: return Colors.grey;
    }
  }

  String _getStreakTierEmoji(String tier) {
    switch (tier) {
      case 'Ocean Legend': return '👑';
      case 'Abyss Master': return '🌊';
      case 'Ocean Pioneer': return '⚡';
      case 'Current Rider': return '🌟';
      case 'Reef Navigator': return '💪';
      case 'Tide Pool Explorer': return '🌱';
      default: return '🆕';
    }
  }

  String _getEfficiencyTier(double efficiency) {
    if (efficiency >= 10.0) return 'Legendary';
    if (efficiency >= 8.0) return 'Exceptional';
    if (efficiency >= 6.0) return 'Excellent';
    if (efficiency >= 4.0) return 'Good';
    if (efficiency >= 2.0) return 'Solid';
    return 'Learning';
  }

  Color _getEfficiencyTierColor(String tier) {
    switch (tier) {
      case 'Legendary': return Colors.purple;
      case 'Exceptional': return Colors.amber;
      case 'Excellent': return Colors.green;
      case 'Good': return Colors.lightBlue;
      case 'Solid': return Colors.cyan;
      default: return Colors.grey;
    }
  }

  String _getEfficiencyTierEmoji(String tier) {
    switch (tier) {
      case 'Legendary': return '🏆';
      case 'Exceptional': return '⭐';
      case 'Excellent': return '🎯';
      case 'Good': return '📊';
      case 'Solid': return '📈';
      default: return '📝';
    }
  }

  String? _getNextStreakMilestone(int currentStreak) {
    if (currentStreak < 3) return 'Reach 3 days to become a Reef Navigator';
    if (currentStreak < 7) return 'Reach 7 days to become a Current Rider';
    if (currentStreak < 14) return 'Reach 14 days to become an Ocean Pioneer';
    if (currentStreak < 30) return 'Reach 30 days to become an Abyss Master';
    if (currentStreak < 100) return 'Reach 100 days to become an Ocean Legend';
    return null; // Already at max tier
  }

  String _getResearchQualityIcon(double efficiency) {
    if (efficiency >= 8.0) return '🏆';
    if (efficiency >= 6.0) return '⭐';
    if (efficiency >= 4.0) return '🎯';
    if (efficiency >= 2.0) return '📊';
    return '📝';
  }


  /// Initialize reward pages based on available rewards
  void _initializeRewardPages() {
    _rewardPages = [];
    
    // Page 1: Session Statistics (always present)
    _rewardPages.add(RewardPageData(
      title: 'Session Results',
      emoji: '💎',
      accentColor: Colors.green,
      type: RewardPageType.sessionStats,
      contentBuilder: (isSmallScreen) => _buildSessionStatistics(),
    ));
    
    // Page 2: Career Progress (if leveled up or title changed)
    if (widget.reward.leveledUp || widget.reward.careerTitleChanged) {
      _rewardPages.add(RewardPageData(
        title: 'Career Advancement',
        emoji: '🚀',
        accentColor: Colors.amber,
        type: RewardPageType.careerProgress,
        contentBuilder: (isSmallScreen) => _buildCareerProgressSection(),
      ));
    }
    
    // Page 3: Species Discoveries (if any discoveries)
    if (widget.reward.allDiscoveredCreatures.isNotEmpty) {
      _rewardPages.add(RewardPageData(
        title: 'Species Discovered',
        emoji: '🐠',
        accentColor: Colors.teal,
        type: RewardPageType.discoveries,
        contentBuilder: (isSmallScreen) => _buildSpeciesDiscoverySection(),
      ));
    }
    
    // Page 4: Equipment & Achievements (if any unlocks)
    if (widget.reward.unlockedEquipment.isNotEmpty || 
        widget.reward.unlockedAchievements.isNotEmpty ||
        widget.reward.nextEquipmentHint != null) {
      _rewardPages.add(RewardPageData(
        title: 'Progress & Unlocks',
        emoji: '🎒',
        accentColor: Colors.purple,
        type: RewardPageType.equipment,
        contentBuilder: (isSmallScreen) => _buildEquipmentAchievementSection(),
      ));
    }
    
    // Page 5: Streak & Efficiency (always present)
    _rewardPages.add(RewardPageData(
      title: 'Research Consistency',
      emoji: '🔥',
      accentColor: Colors.orange,
      type: RewardPageType.streakEfficiency,
      contentBuilder: (isSmallScreen) => _buildStreakEfficiencySection(),
    ));
    
    // Final page: Summary & Actions
    _rewardPages.add(RewardPageData(
      title: 'Expedition Complete',
      emoji: widget.reward.hasSignificantAccomplishments ? '🏆' : '⚓',
      accentColor: widget.reward.hasSignificantAccomplishments ? Colors.amber : Colors.cyan,
      type: RewardPageType.summary,
      contentBuilder: (isSmallScreen) => _buildSummaryPage(isSmallScreen),
    ));
  }

  /// Build page indicator dots
  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_rewardPages.length, (index) {
        final isActive = index == _currentPage;
        final page = _rewardPages[index];
        
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 32 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? page.accentColor : page.accentColor.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(4),
          ),
          child: isActive ? Center(
            child: Text(
              page.emoji,
              style: const TextStyle(fontSize: 6),
            ),
          ) : null,
        );
      }),
    );
  }

  /// Build page content wrapper
  Widget _buildPageContent(RewardPageData page) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 350;
        
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // Page title
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 12 : 16,
                  vertical: isSmallScreen ? 8 : 10,
                ),
                decoration: BoxDecoration(
                  color: page.accentColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: page.accentColor.withValues(alpha: 0.5),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(page.emoji, style: TextStyle(fontSize: isSmallScreen ? 16 : 20)),
                    SizedBox(width: isSmallScreen ? 6 : 8),
                    Text(
                      page.title,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 14 : 16,
                        fontWeight: FontWeight.bold,
                        color: page.accentColor,
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: isSmallScreen ? 12 : 16),
              
              // Page content
              page.contentBuilder(isSmallScreen),
            ],
          ),
        );
      },
    );
  }

  /// Build navigation buttons
  Widget _buildNavigationButtons() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 350;
        final isFirstPage = _currentPage == 0;
        final isLastPage = _currentPage == _rewardPages.length - 1;
        
        return Row(
          children: [
            // Previous button
            if (!isFirstPage)
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    if (_currentPage > 0) {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  icon: Icon(Icons.arrow_back, size: isSmallScreen ? 16 : 18),
                  label: Text(
                    'Previous',
                    style: TextStyle(fontSize: isSmallScreen ? 12 : 14),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.cyan,
                    side: const BorderSide(color: Colors.cyan, width: 1),
                    padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 8 : 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              )
            else
              const Spacer(),
            
            SizedBox(width: isSmallScreen ? 8 : 12),
            
            // Page counter
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 8 : 12,
                vertical: isSmallScreen ? 4 : 6,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: Colors.cyan.withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
              child: Text(
                '${_currentPage + 1} of ${_rewardPages.length}',
                style: TextStyle(
                  fontSize: isSmallScreen ? 10 : 12,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            
            SizedBox(width: isSmallScreen ? 8 : 12),
            
            // Next/Done button
            Expanded(
              child: ElevatedButton.icon(
                onPressed: isLastPage ? widget.onContinue : () {
                  if (_currentPage < _rewardPages.length - 1) {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                },
                icon: Icon(
                  isLastPage ? Icons.check : Icons.arrow_forward,
                  size: isSmallScreen ? 16 : 18,
                ),
                label: Text(
                  isLastPage ? 'Continue' : 'Next',
                  style: TextStyle(fontSize: isSmallScreen ? 12 : 14),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isLastPage ? Colors.teal : Colors.blue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 8 : 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 3,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Build summary page with final actions
  Widget _buildSummaryPage(bool isSmallScreen) {
    return Column(
      children: [
        // Summary stats
        Container(
          padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.teal.withValues(alpha: 0.2),
                Colors.blue.withValues(alpha: 0.2),
              ],
            ),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: Colors.teal.withValues(alpha: 0.5),
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          '${widget.reward.xpGained}',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 20 : 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        Text(
                          'Total XP',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 10 : 12,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          '${widget.reward.currentStreak}',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 20 : 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                        Text(
                          'Day Streak',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 10 : 12,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          widget.reward.researchEfficiency.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: isSmallScreen ? 20 : 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.cyan,
                          ),
                        ),
                        Text(
                          'Efficiency',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 10 : 12,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        SizedBox(height: isSmallScreen ? 16 : 20),
        
        // Celebration message
        Text(
          widget.reward.hasSignificantAccomplishments
              ? '🎉 Outstanding research session! 🎉'
              : '✅ Research session completed successfully!',
          style: TextStyle(
            fontSize: isSmallScreen ? 14 : 16,
            fontWeight: FontWeight.w600,
            color: widget.reward.hasSignificantAccomplishments ? Colors.amber : Colors.cyan,
          ),
          textAlign: TextAlign.center,
        ),
        
        SizedBox(height: isSmallScreen ? 12 : 16),
        
        // Surface for break button (if applicable)
        if (widget.onSurfaceForBreak != null)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: widget.onSurfaceForBreak,
              icon: Icon(Icons.wb_sunny, color: Colors.orange, size: isSmallScreen ? 16 : 18),
              label: Text(
                'Surface for Break',
                style: TextStyle(
                  color: Colors.orange,
                  fontSize: isSmallScreen ? 12 : 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.orange, width: 2),
                padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 8 : 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// Calculate celebration intensity based on session accomplishments
  /// Returns a value between 0.0 (minimal celebration) and 1.0 (maximum celebration)
  double _calculateCelebrationIntensity() {
    double intensity = 0.0;
    
    // Base intensity from session completion
    intensity += 0.1;
    
    // Level progression bonus
    if (widget.reward.leveledUp) {
      intensity += 0.3;
      // Extra bonus for multiple level jumps
      final levelJump = widget.reward.newLevel - widget.reward.oldLevel;
      if (levelJump > 1) {
        intensity += 0.1 * (levelJump - 1);
      }
    }
    
    // Career advancement bonus
    if (widget.reward.careerTitleChanged) {
      intensity += 0.25;
    }
    
    // Equipment unlocks
    intensity += widget.reward.unlockedEquipment.length * 0.15;
    
    // Achievement unlocks
    intensity += widget.reward.unlockedAchievements.length * 0.2;
    
    // Species discovery bonus
    if (widget.reward.allDiscoveredCreatures.isNotEmpty) {
      intensity += 0.2;
      // Rare creature discovery bonus
      for (final creature in widget.reward.allDiscoveredCreatures) {
        if (creature is Creature) {
          switch (creature.rarity) {
            case CreatureRarity.uncommon:
              intensity += 0.05;
              break;
            case CreatureRarity.rare:
              intensity += 0.1;
              break;
            case CreatureRarity.legendary:
              intensity += 0.2;
              break;
            case CreatureRarity.common:
              break;
          }
        }
      }
    }
    
    // Streak milestone bonuses
    if (widget.reward.currentStreak >= 100) {
      intensity += 0.3; // Ocean Legend
    } else if (widget.reward.currentStreak >= 30) {
      intensity += 0.2; // Abyss Master
    } else if (widget.reward.currentStreak >= 14) {
      intensity += 0.15; // Ocean Pioneer
    } else if (widget.reward.currentStreak >= 7) {
      intensity += 0.1; // Current Rider
    }
    
    // Research efficiency bonus
    if (widget.reward.researchEfficiency >= 8.0) {
      intensity += 0.2; // Exceptional research
    } else if (widget.reward.researchEfficiency >= 6.0) {
      intensity += 0.15; // Excellent research
    } else if (widget.reward.researchEfficiency >= 4.0) {
      intensity += 0.1; // Good research
    }
    
    // Session depth bonus (longer sessions = more accomplishment)
    if (widget.reward.sessionDurationMinutes >= 60) {
      intensity += 0.1;
    } else if (widget.reward.sessionDurationMinutes >= 45) {
      intensity += 0.05;
    }
    
    // XP threshold bonuses (significant XP gains deserve celebration)
    if (widget.reward.xpGained >= 200) {
      intensity += 0.15;
    } else if (widget.reward.xpGained >= 100) {
      intensity += 0.1;
    } else if (widget.reward.xpGained >= 50) {
      intensity += 0.05;
    }
    
    // Clamp intensity between 0.0 and 1.0
    return intensity.clamp(0.0, 1.0);
  }

  /// Build celebration particle effects for high intensity sessions
  Widget _buildCelebrationParticles() {
    return AnimatedBuilder(
      animation: _celebrationAnimation,
      builder: (context, child) {
        if (_celebrationAnimation.value < 0.1) return const SizedBox.shrink();
        
        return Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _CelebrationParticlesPainter(
                progress: _celebrationAnimation.value,
                intensity: _celebrationIntensity,
                hasLevelUp: widget.reward.leveledUp,
                hasDiscoveries: widget.reward.allDiscoveredCreatures.isNotEmpty,
                hasAchievements: widget.reward.unlockedAchievements.isNotEmpty,
                hasEquipmentUnlock: widget.reward.unlockedEquipment.isNotEmpty,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Custom painter for celebration particles
class _CelebrationParticlesPainter extends CustomPainter {
  final double progress;
  final double intensity;
  final bool hasLevelUp;
  final bool hasDiscoveries;
  final bool hasAchievements;
  final bool hasEquipmentUnlock;

  _CelebrationParticlesPainter({
    required this.progress,
    required this.intensity,
    required this.hasLevelUp,
    required this.hasDiscoveries,
    required this.hasAchievements,
    required this.hasEquipmentUnlock,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..blendMode = BlendMode.screen;
    final random = Random(42); // Fixed seed for consistent animation
    
    final particleCount = (intensity * 30).round().clamp(5, 50);
    
    for (int i = 0; i < particleCount; i++) {
      final t = (progress + (i / particleCount)) % 1.0;
      final particleProgress = Curves.easeOut.transform(t);
      
      // Particle position
      final startX = random.nextDouble() * size.width;
      final startY = size.height;
      final endX = startX + (random.nextDouble() - 0.5) * 100;
      final endY = random.nextDouble() * size.height * 0.3;
      
      final x = startX + (endX - startX) * particleProgress;
      final y = startY - (startY - endY) * particleProgress;
      
      // Particle properties based on celebration type
      Color color;
      double baseSize;
      
      if (hasLevelUp && i % 4 == 0) {
        color = Colors.amber;
        baseSize = 6.0;
      } else if (hasDiscoveries && i % 4 == 1) {
        color = Colors.teal;
        baseSize = 5.0;
      } else if (hasAchievements && i % 4 == 2) {
        color = Colors.purple;
        baseSize = 4.0;
      } else if (hasEquipmentUnlock && i % 4 == 3) {
        color = Colors.orange;
        baseSize = 5.0;
      } else {
        color = Colors.cyan;
        baseSize = 3.0;
      }
      
      // Fade out particle
      final alpha = (1.0 - particleProgress).clamp(0.0, 1.0);
      paint.color = color.withValues(alpha: alpha * intensity);
      
      // Scale particle size with animation
      final particleSize = baseSize * intensity * (1.0 + Curves.elasticOut.transform(particleProgress) * 0.5);
      
      canvas.drawCircle(Offset(x, y), particleSize, paint);
      
      // Add sparkle effect for high intensity
      if (intensity > 0.8 && i % 6 == 0) {
        paint.color = Colors.white.withValues(alpha: alpha * 0.8);
        canvas.drawCircle(Offset(x, y), particleSize * 0.3, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _CelebrationParticlesPainter oldDelegate) {
    return progress != oldDelegate.progress;
  }
}

/// Custom painter for bubble effects during surfacing animation
class _BubbleEffectPainter extends CustomPainter {
  final double progress;
  final int bubbleCount;

  _BubbleEffectPainter({
    required this.progress,
    required this.bubbleCount,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.cyan.withValues(alpha: 0.6)
      ..blendMode = BlendMode.screen;
    
    final random = Random(123); // Fixed seed for consistent bubbles
    
    for (int i = 0; i < bubbleCount; i++) {
      final bubbleProgress = (progress + (i * 0.1)) % 1.0;
      final bubbleLifetime = Curves.easeOut.transform(bubbleProgress);
      
      // Bubble position - rising effect
      final startX = random.nextDouble() * size.width;
      final endX = startX + (random.nextDouble() - 0.5) * 30;
      final x = startX + (endX - startX) * bubbleLifetime;
      final y = size.height - (size.height * bubbleLifetime);
      
      // Bubble size and opacity
      final bubbleSize = (2.0 + random.nextDouble() * 4.0) * (1.0 - bubbleLifetime * 0.3);
      final alpha = (1.0 - bubbleLifetime).clamp(0.0, 1.0) * 0.6;
      
      paint.color = Colors.cyan.withValues(alpha: alpha);
      canvas.drawCircle(Offset(x, y), bubbleSize, paint);
      
      // Add inner highlight for bubble effect
      paint.color = Colors.white.withValues(alpha: alpha * 0.5);
      canvas.drawCircle(Offset(x - bubbleSize * 0.3, y - bubbleSize * 0.3), bubbleSize * 0.2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BubbleEffectPainter oldDelegate) {
    return progress != oldDelegate.progress;
  }
}

/// Data class for reward pages
class RewardPageData {
  final String title;
  final String emoji;
  final Color accentColor;
  final RewardPageType type;
  final Widget Function(bool isSmallScreen) contentBuilder;

  RewardPageData({
    required this.title,
    required this.emoji,
    required this.accentColor,
    required this.type,
    required this.contentBuilder,
  });
}

enum RewardPageType {
  sessionStats,
  careerProgress,
  discoveries,
  equipment,
  streakEfficiency,
  summary,
}
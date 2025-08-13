import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math' as math;
import '../services/gamification_service.dart';

class AchievementBadgesWidget extends StatefulWidget {
  const AchievementBadgesWidget({Key? key}) : super(key: key);

  @override
  State<AchievementBadgesWidget> createState() => _AchievementBadgesWidgetState();
}

class _AchievementBadgesWidgetState extends State<AchievementBadgesWidget> 
    with TickerProviderStateMixin {
  late AnimationController _floatController;
  late AnimationController _shimmerController;
  late Animation<double> _floatAnimation;
  late Animation<double> _shimmerAnimation;
  
  final List<AchievementData> _allAchievements = [
    AchievementData(
      id: 'first_session',
      title: 'Getting Started',
      description: 'Complete your first focus session',
      icon: Icons.play_arrow,
      color: Colors.green,
      rarity: 'Common',
    ),
    AchievementData(
      id: 'streak_3',
      title: 'On Fire!',
      description: 'Maintain a 3-day streak',
      icon: Icons.local_fire_department,
      color: Colors.orange,
      rarity: 'Uncommon',
    ),
    AchievementData(
      id: 'streak_7',
      title: 'Week Warrior',
      description: 'Maintain a 7-day streak',
      icon: Icons.military_tech,
      color: Colors.purple,
      rarity: 'Rare',
    ),
    AchievementData(
      id: 'sessions_25',
      title: 'Quarter Century',
      description: 'Complete 25 focus sessions',
      icon: Icons.star,
      color: Colors.amber,
      rarity: 'Rare',
    ),
    AchievementData(
      id: 'sessions_100',
      title: 'Centurion',
      description: 'Complete 100 focus sessions',
      icon: Icons.diamond,
      color: Colors.cyan,
      rarity: 'Epic',
    ),
    AchievementData(
      id: 'focus_10_hours',
      title: 'Deep Diver',
      description: 'Accumulate 10 hours of focus time',
      icon: Icons.psychology,
      color: Colors.blue,
      rarity: 'Rare',
    ),
    AchievementData(
      id: 'level_10',
      title: 'Expert',
      description: 'Reach level 10',
      icon: Icons.emoji_events,
      color: Colors.amber,
      rarity: 'Epic',
    ),
    AchievementData(
      id: 'level_25',
      title: 'Master',
      description: 'Reach level 25',
      icon: Icons.workspace_premium,
      color: Colors.deepPurple,
      rarity: 'Legendary',
    ),
  ];
  
  @override
  void initState() {
    super.initState();
    
    _floatController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    
    _shimmerController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    
    _floatAnimation = Tween<double>(
      begin: -5.0,
      end: 5.0,
    ).animate(CurvedAnimation(
      parent: _floatController,
      curve: Curves.easeInOut,
    ));
    
    _shimmerAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.linear,
    ));
  }
  
  @override
  void dispose() {
    _floatController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }
  
  Color _getRarityColor(String rarity) {
    switch (rarity) {
      case 'Common':
        return Colors.grey;
      case 'Uncommon':
        return Colors.green;
      case 'Rare':
        return Colors.blue;
      case 'Epic':
        return Colors.purple;
      case 'Legendary':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final unlockedAchievements = GamificationService.instance.unlockedAchievements;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Achievements',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${unlockedAchievements.length}/${_allAchievements.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    childAspectRatio: 1,
                  ),
                  itemCount: _allAchievements.length,
                  itemBuilder: (context, index) {
                    final achievement = _allAchievements[index];
                    final isUnlocked = unlockedAchievements.contains(achievement.id);
                    
                    return _buildAchievementBadge(achievement, isUnlocked);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildAchievementBadge(AchievementData achievement, bool isUnlocked) {
    return GestureDetector(
      onTap: () => _showAchievementDetails(achievement, isUnlocked),
      child: AnimatedBuilder(
        animation: _floatAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, isUnlocked ? _floatAnimation.value : 0),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: isUnlocked
                    ? RadialGradient(
                        colors: [
                          achievement.color.withOpacity(0.3),
                          achievement.color.withOpacity(0.1),
                        ],
                      )
                    : null,
                color: !isUnlocked ? Colors.white.withOpacity(0.05) : null,
                border: Border.all(
                  color: isUnlocked
                      ? achievement.color.withOpacity(0.5)
                      : Colors.white.withOpacity(0.1),
                  width: 2,
                ),
                boxShadow: isUnlocked
                    ? [
                        BoxShadow(
                          color: achievement.color.withOpacity(0.3),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ]
                    : [],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (isUnlocked) ...[
                    // Shimmer effect for unlocked badges
                    AnimatedBuilder(
                      animation: _shimmerAnimation,
                      builder: (context, child) {
                        return CustomPaint(
                          size: const Size(60, 60),
                          painter: ShimmerPainter(
                            progress: _shimmerAnimation.value,
                            color: achievement.color,
                          ),
                        );
                      },
                    ),
                  ],
                  Icon(
                    achievement.icon,
                    color: isUnlocked
                        ? achievement.color
                        : Colors.white.withOpacity(0.3),
                    size: 28,
                  ),
                  if (!isUnlocked)
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black.withOpacity(0.5),
                      ),
                      child: const Icon(
                        Icons.lock_outline,
                        color: Colors.white30,
                        size: 20,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
  
  void _showAchievementDetails(AchievementData achievement, bool isUnlocked) {
    showDialog(
      context: context,
      builder: (context) => AchievementDetailDialog(
        achievement: achievement,
        isUnlocked: isUnlocked,
      ),
    );
  }
}

class AchievementData {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String rarity;
  
  AchievementData({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.rarity,
  });
}

class AchievementDetailDialog extends StatefulWidget {
  final AchievementData achievement;
  final bool isUnlocked;
  
  const AchievementDetailDialog({
    Key? key,
    required this.achievement,
    required this.isUnlocked,
  }) : super(key: key);
  
  @override
  State<AchievementDetailDialog> createState() => _AchievementDetailDialogState();
}

class _AchievementDetailDialogState extends State<AchievementDetailDialog> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));
    
    _rotationAnimation = Tween<double>(
      begin: -0.5,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));
    
    _controller.forward();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  Color _getRarityColor(String rarity) {
    switch (rarity) {
      case 'Common':
        return Colors.grey;
      case 'Uncommon':
        return Colors.green;
      case 'Rare':
        return Colors.blue;
      case 'Epic':
        return Colors.purple;
      case 'Legendary':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Transform.rotate(
              angle: _rotationAnimation.value,
              child: Container(
                width: 300,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: widget.achievement.color.withOpacity(0.5),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: widget.achievement.color.withOpacity(0.3),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            widget.achievement.color.withOpacity(0.3),
                            widget.achievement.color.withOpacity(0.1),
                          ],
                        ),
                        border: Border.all(
                          color: widget.achievement.color,
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: widget.achievement.color.withOpacity(0.5),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Icon(
                        widget.achievement.icon,
                        color: widget.achievement.color,
                        size: 50,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      widget.achievement.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getRarityColor(widget.achievement.rarity).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _getRarityColor(widget.achievement.rarity).withOpacity(0.5),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        widget.achievement.rarity,
                        style: TextStyle(
                          color: _getRarityColor(widget.achievement.rarity),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.achievement.description,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (widget.isUnlocked) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Unlocked!',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.lock_outline,
                            color: Colors.white30,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Locked',
                            style: TextStyle(
                              color: Colors.white30,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class ShimmerPainter extends CustomPainter {
  final double progress;
  final Color color;
  
  ShimmerPainter({
    required this.progress,
    required this.color,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment(-1 + 2 * progress, -1 + 2 * progress),
        end: Alignment(-1 + 2 * progress + 0.3, -1 + 2 * progress + 0.3),
        colors: [
          Colors.transparent,
          color.withOpacity(0.3),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width / 2,
      paint,
    );
  }
  
  @override
  bool shouldRepaint(ShimmerPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
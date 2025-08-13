import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:shared_preferences/shared_preferences.dart';

class GoalsTrackerWidget extends StatefulWidget {
  const GoalsTrackerWidget({Key? key}) : super(key: key);

  @override
  State<GoalsTrackerWidget> createState() => _GoalsTrackerWidgetState();
}

class _GoalsTrackerWidgetState extends State<GoalsTrackerWidget> with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _pulseController;
  late Animation<double> _progressAnimation;
  late Animation<double> _pulseAnimation;
  
  // Daily goals
  int _dailySessionsGoal = 4;
  int _dailySessionsCompleted = 0;
  int _dailyMinutesGoal = 120;
  int _dailyMinutesCompleted = 0;
  
  // Weekly goals
  int _weeklySessionsGoal = 20;
  int _weeklySessionsCompleted = 0;
  int _weeklyMinutesGoal = 600;
  int _weeklyMinutesCompleted = 0;
  
  bool _showWeekly = false;
  
  @override
  void initState() {
    super.initState();
    
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.elasticOut,
    ));
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _loadGoals();
    _progressController.forward();
  }
  
  @override
  void dispose() {
    _progressController.dispose();
    _pulseController.dispose();
    super.dispose();
  }
  
  Future<void> _loadGoals() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final todayKey = '${now.year}-${now.month}-${now.day}';
    final weekKey = '${now.year}-week-${_getWeekNumber(now)}';
    
    setState(() {
      _dailySessionsCompleted = prefs.getInt('daily_sessions_$todayKey') ?? 0;
      _dailyMinutesCompleted = prefs.getInt('daily_minutes_$todayKey') ?? 0;
      _weeklySessionsCompleted = prefs.getInt('weekly_sessions_$weekKey') ?? 0;
      _weeklyMinutesCompleted = prefs.getInt('weekly_minutes_$weekKey') ?? 0;
      
      // Load custom goals if set
      _dailySessionsGoal = prefs.getInt('daily_sessions_goal') ?? 4;
      _dailyMinutesGoal = prefs.getInt('daily_minutes_goal') ?? 120;
      _weeklySessionsGoal = prefs.getInt('weekly_sessions_goal') ?? 20;
      _weeklyMinutesGoal = prefs.getInt('weekly_minutes_goal') ?? 600;
    });
  }
  
  int _getWeekNumber(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final daysSinceFirstDay = date.difference(firstDayOfYear).inDays;
    return ((daysSinceFirstDay + firstDayOfYear.weekday - 1) / 7).ceil();
  }
  
  @override
  Widget build(BuildContext context) {
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
                    Text(
                      _showWeekly ? 'Weekly Goals' : 'Daily Goals',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    _buildToggleButton(),
                  ],
                ),
                const SizedBox(height: 20),
                AnimatedBuilder(
                  animation: _progressAnimation,
                  builder: (context, child) {
                    return Column(
                      children: [
                        _buildGoalItem(
                          icon: Icons.timer,
                          title: 'Sessions',
                          current: _showWeekly ? _weeklySessionsCompleted : _dailySessionsCompleted,
                          goal: _showWeekly ? _weeklySessionsGoal : _dailySessionsGoal,
                          color: Colors.purple,
                          animation: _progressAnimation.value,
                        ),
                        const SizedBox(height: 15),
                        _buildGoalItem(
                          icon: Icons.access_time,
                          title: 'Minutes',
                          current: _showWeekly ? _weeklyMinutesCompleted : _dailyMinutesCompleted,
                          goal: _showWeekly ? _weeklyMinutesGoal : _dailyMinutesGoal,
                          color: Colors.blue,
                          animation: _progressAnimation.value,
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 15),
                _buildMotivationalMessage(),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildToggleButton() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showWeekly = !_showWeekly;
        });
        _progressController.reset();
        _progressController.forward();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              _showWeekly ? Icons.calendar_view_week : Icons.calendar_today,
              size: 16,
              color: Colors.white,
            ),
            const SizedBox(width: 5),
            Text(
              _showWeekly ? 'Week' : 'Day',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildGoalItem({
    required IconData icon,
    required String title,
    required int current,
    required int goal,
    required Color color,
    required double animation,
  }) {
    final progress = (current / goal).clamp(0.0, 1.0);
    final isCompleted = current >= goal;
    
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: isCompleted ? _pulseAnimation.value : 1.0,
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: isCompleted 
                    ? color.withOpacity(0.5)
                    : Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        icon,
                        color: color,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$current / $goal',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isCompleted)
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.green,
                          size: 20,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                Stack(
                  children: [
                    Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: 8,
                      width: MediaQuery.of(context).size.width * 0.7 * progress * animation,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            color,
                            color.withOpacity(0.7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [
                          BoxShadow(
                            color: color.withOpacity(0.5),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildMotivationalMessage() {
    final dailyProgress = ((_dailySessionsCompleted / _dailySessionsGoal + 
                          _dailyMinutesCompleted / _dailyMinutesGoal) / 2)
                          .clamp(0.0, 1.0);
    
    String message;
    IconData icon;
    Color color;
    
    if (dailyProgress >= 1.0) {
      message = "Perfect! All goals completed!";
      icon = Icons.celebration;
      color = Colors.green;
    } else if (dailyProgress >= 0.75) {
      message = "Almost there! Keep pushing!";
      icon = Icons.trending_up;
      color = Colors.amber;
    } else if (dailyProgress >= 0.5) {
      message = "Great progress! Halfway done!";
      icon = Icons.emoji_events;
      color = Colors.orange;
    } else if (dailyProgress >= 0.25) {
      message = "Good start! Keep going!";
      icon = Icons.thumb_up;
      color = Colors.blue;
    } else {
      message = "Let's get started!";
      icon = Icons.rocket_launch;
      color = Colors.purple;
    }
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
import '../models/session.dart';
import 'persistence/persistence_service.dart';

class AnalyticsData {
  final DateTime date;
  final int totalFocusTime; // in minutes
  final int totalBreakTime; // in minutes
  final int sessionsCompleted;
  final double completionRate; // 0.0 to 1.0
  final int streak;

  AnalyticsData({
    required this.date,
    required this.totalFocusTime,
    required this.totalBreakTime,
    required this.sessionsCompleted,
    required this.completionRate,
    required this.streak,
  });
}

class ProductivityInsight {
  final String title;
  final String description;
  final InsightType type;
  final double impact; // 0.0 to 1.0

  ProductivityInsight({
    required this.title,
    required this.description,
    required this.type,
    required this.impact,
  });
}

enum InsightType {
  positive,
  neutral,
  negative,
  suggestion,
}

class WeeklyPattern {
  final Map<int, double> hourlyFocus; // hour -> minutes
  final Map<int, double> dailyFocus; // weekday -> minutes
  final int mostProductiveHour;
  final int mostProductiveDay;

  WeeklyPattern({
    required this.hourlyFocus,
    required this.dailyFocus,
    required this.mostProductiveHour,
    required this.mostProductiveDay,
  });
}

class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  // Cache for performance
  final Map<String, AnalyticsData> _dailyCache = {};
  DateTime? _cacheDate;

  /// Get analytics data for a specific date range
  Future<List<AnalyticsData>> getAnalyticsData({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final sessions = await PersistenceService.instance.sessions.getSessionsByDateRange(startDate, endDate);
    final List<AnalyticsData> analyticsData = [];

    // Group sessions by date
    final Map<String, List<Session>> sessionsByDate = {};
    for (final session in sessions) {
      final dateKey = _dateKey(session.startTime);
      sessionsByDate[dateKey] ??= [];
      sessionsByDate[dateKey]!.add(session);
    }

    // Generate analytics for each date
    DateTime currentDate = startDate;
    while (currentDate.isBefore(endDate) || currentDate.isAtSameMomentAs(endDate)) {
      final dateKey = _dateKey(currentDate);
      final daySessions = sessionsByDate[dateKey] ?? [];
      
      analyticsData.add(await _calculateDayAnalytics(currentDate, daySessions));
      currentDate = currentDate.add(const Duration(days: 1));
    }

    return analyticsData;
  }

  /// Get analytics for today
  Future<AnalyticsData> getTodayAnalytics() async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    final cacheKey = _dateKey(today);
    if (_dailyCache.containsKey(cacheKey) && 
        _cacheDate != null && 
        _cacheDate!.day == today.day) {
      return _dailyCache[cacheKey]!;
    }

    final sessions = await PersistenceService.instance.sessions.getSessionsByDateRange(startOfDay, endOfDay);
    final analytics = await _calculateDayAnalytics(today, sessions);
    
    _dailyCache[cacheKey] = analytics;
    _cacheDate = today;
    
    return analytics;
  }

  /// Get weekly pattern analysis
  Future<WeeklyPattern> getWeeklyPattern() async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 7));
    
    final sessions = await PersistenceService.instance.sessions.getSessionsByDateRange(
      startOfWeek,
      endOfWeek,
    );

    final hourlyFocus = <int, double>{};
    final dailyFocus = <int, double>{};

    // Initialize maps
    for (int i = 0; i < 24; i++) {
      hourlyFocus[i] = 0.0;
    }
    for (int i = 1; i <= 7; i++) {
      dailyFocus[i] = 0.0;
    }

    // Process sessions
    for (final session in sessions) {
      if (session.type == SessionType.focus && session.completed) {
        final hour = session.startTime.hour;
        final weekday = session.startTime.weekday;
        final minutes = session.duration / 60.0;

        hourlyFocus[hour] = (hourlyFocus[hour] ?? 0) + minutes;
        dailyFocus[weekday] = (dailyFocus[weekday] ?? 0) + minutes;
      }
    }

    // Find most productive times
    int mostProductiveHour = 0;
    int mostProductiveDay = 1;
    double maxHourly = 0;
    double maxDaily = 0;

    hourlyFocus.forEach((hour, minutes) {
      if (minutes > maxHourly) {
        maxHourly = minutes;
        mostProductiveHour = hour;
      }
    });

    dailyFocus.forEach((day, minutes) {
      if (minutes > maxDaily) {
        maxDaily = minutes;
        mostProductiveDay = day;
      }
    });

    return WeeklyPattern(
      hourlyFocus: hourlyFocus,
      dailyFocus: dailyFocus,
      mostProductiveHour: mostProductiveHour,
      mostProductiveDay: mostProductiveDay,
    );
  }

  /// Generate productivity insights based on recent data
  Future<List<ProductivityInsight>> getProductivityInsights() async {
    final insights = <ProductivityInsight>[];
    final now = DateTime.now();
    
    // Get last 7 days of data
    final lastWeekData = await getAnalyticsData(
      startDate: now.subtract(const Duration(days: 7)),
      endDate: now,
    );

    // Get previous 7 days for comparison
    final previousWeekData = await getAnalyticsData(
      startDate: now.subtract(const Duration(days: 14)),
      endDate: now.subtract(const Duration(days: 7)),
    );

    // Calculate trends (with safety checks)
    double thisWeekAvg = 0.0;
    if (lastWeekData.isNotEmpty) {
      final sum = lastWeekData.map((d) => d.totalFocusTime).reduce((a, b) => a + b);
      thisWeekAvg = sum / lastWeekData.length;
      // Safety check for NaN or Infinity
      if (thisWeekAvg.isNaN || thisWeekAvg.isInfinite) {
        thisWeekAvg = 0.0;
      }
    }
    
    double prevWeekAvg = 0.0;
    if (previousWeekData.isNotEmpty) {
      final sum = previousWeekData.map((d) => d.totalFocusTime).reduce((a, b) => a + b);
      prevWeekAvg = sum / previousWeekData.length;
      // Safety check for NaN or Infinity
      if (prevWeekAvg.isNaN || prevWeekAvg.isInfinite) {
        prevWeekAvg = 0.0;
      }
    }

    // Trend analysis (only if we have previous week data to compare)
    if (prevWeekAvg > 0) {
      if (thisWeekAvg > prevWeekAvg * 1.1) {
        final percentChange = ((thisWeekAvg - prevWeekAvg) / prevWeekAvg * 100).round();
        insights.add(ProductivityInsight(
          title: "Productivity Trend ↗️",
          description: "Your focus time increased by $percentChange% this week!",
          type: InsightType.positive,
          impact: 0.8,
        ));
      } else if (thisWeekAvg < prevWeekAvg * 0.9) {
        final percentChange = ((prevWeekAvg - thisWeekAvg) / prevWeekAvg * 100).round();
        insights.add(ProductivityInsight(
          title: "Focus Time Declining ↘️",
          description: "Your focus time decreased by $percentChange% this week.",
          type: InsightType.negative,
          impact: 0.7,
        ));
      }
    } else if (thisWeekAvg > 0) {
      // No previous week data, but we have current week data
      insights.add(ProductivityInsight(
        title: "Getting Started 🚀",
        description: "Great job starting your focus journey! Keep building momentum.",
        type: InsightType.positive,
        impact: 0.6,
      ));
    }

    // Completion rate insights (with safety checks)
    double avgCompletionRate = 0.0;
    if (lastWeekData.isNotEmpty) {
      final sum = lastWeekData.map((d) => d.completionRate).reduce((a, b) => a + b);
      avgCompletionRate = sum / lastWeekData.length;
      // Safety check for NaN or Infinity
      if (avgCompletionRate.isNaN || avgCompletionRate.isInfinite) {
        avgCompletionRate = 0.0;
      }
    }
    
    if (avgCompletionRate > 0.85) {
      insights.add(ProductivityInsight(
        title: "Excellent Completion Rate! ⭐",
        description: "You're completing ${(avgCompletionRate * 100).round()}% of your focus sessions.",
        type: InsightType.positive,
        impact: 0.9,
      ));
    } else if (avgCompletionRate < 0.6) {
      insights.add(ProductivityInsight(
        title: "Consider Shorter Sessions",
        description: "Try reducing your focus session length to improve completion rates.",
        type: InsightType.suggestion,
        impact: 0.6,
      ));
    }

    // Weekly pattern insights
    final pattern = await getWeeklyPattern();
    insights.add(ProductivityInsight(
      title: "Peak Performance Time",
      description: "You're most productive at ${_formatHour(pattern.mostProductiveHour)} on ${_formatDay(pattern.mostProductiveDay)}s.",
      type: InsightType.neutral,
      impact: 0.5,
    ));

    return insights..sort((a, b) => b.impact.compareTo(a.impact));
  }

  /// Calculate analytics for a single day
  Future<AnalyticsData> _calculateDayAnalytics(DateTime date, List<Session> sessions) async {
    int totalFocusTime = 0; // in minutes - includes both completed and abandoned focus sessions
    int totalBreakTime = 0; // in minutes
    int completedFocusSessions = 0;
    int totalFocusSessions = 0;

    for (final session in sessions) {
      // Ensure duration is valid before converting to minutes
      if (session.duration.isNaN || session.duration.isInfinite) {
        continue; // Skip invalid sessions
      }
      final minutes = (session.duration / 60).round();
      
      if (session.type == SessionType.focus) {
        totalFocusTime += minutes; // Include both completed and abandoned focus sessions
        totalFocusSessions++;
        if (session.completed) {
          completedFocusSessions++;
        }
      } else {
        totalBreakTime += minutes;
      }
    }

    // Success rate calculation: only consider focus sessions
    final completionRate = totalFocusSessions == 0 ? 0.0 : completedFocusSessions / totalFocusSessions;
    final streak = await _calculateCurrentStreak(date);

    return AnalyticsData(
      date: date,
      totalFocusTime: totalFocusTime,
      totalBreakTime: totalBreakTime,
      sessionsCompleted: completedFocusSessions, // Only completed focus sessions
      completionRate: completionRate,
      streak: streak,
    );
  }

  /// Calculate current streak ending on or before the given date
  Future<int> _calculateCurrentStreak(DateTime endDate) async {
    int streak = 0;
    DateTime currentDate = DateTime(endDate.year, endDate.month, endDate.day);
    
    while (true) {
      final nextDay = currentDate.add(const Duration(days: 1));
      final sessions = await PersistenceService.instance.sessions.getSessionsByDateRange(currentDate, nextDay);
      
      // Check if this day has at least one completed focus session
      final hasCompletedFocus = sessions.any(
        (s) => s.type == SessionType.focus && s.completed,
      );
      
      if (hasCompletedFocus) {
        streak++;
        currentDate = currentDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
      
      // Prevent infinite loops
      if (streak > 365) break;
    }
    
    return streak;
  }

  String _dateKey(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  String _formatHour(int hour) {
    if (hour == 0) return "12 AM";
    if (hour < 12) return "$hour AM";
    if (hour == 12) return "12 PM";
    return "${hour - 12} PM";
  }

  String _formatDay(int weekday) {
    const days = ["", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"];
    return days[weekday];
  }

  void clearCache() {
    _dailyCache.clear();
    _cacheDate = null;
  }
}
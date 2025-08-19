import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'dart:ui';
import '../services/analytics_service.dart';
import '../widgets/streak_rewards_display_widget.dart';
import '../services/streak_rewards_service.dart';
import '../services/gamification_service.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final AnalyticsService _analyticsService = AnalyticsService();
  
  // Helper methods for responsive design
  bool get _isNarrowScreen => MediaQuery.of(context).size.width < 400;
  
  double _getResponsiveFontSize(double baseSize) {
    return _isNarrowScreen ? baseSize + 2 : baseSize;
  }
  
  double _getResponsiveSpacing() {
    return _isNarrowScreen ? 16 : 24;
  }

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
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1A365D), // Deep Ocean Blue
              Color(0xFF2D5A87), // Mid Ocean Blue  
              Color(0xFF3182CE), // Bright Ocean Blue
              Color(0xFF00B4D8), // Tropical Water
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Compact Mobile Header - matching Career Tab style
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.04,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.teal, Colors.cyan],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.analytics,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Marine Research Data Log',
                            style: TextStyle(
                              fontSize: MediaQuery.of(context).size.width < 400 ? 16 : 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Expedition Analytics & Performance',
                            style: TextStyle(
                              fontSize: MediaQuery.of(context).size.width < 400 ? 11 : 12,
                              color: Colors.cyan,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Export Action Button
                    Container(
                      constraints: const BoxConstraints(minHeight: 44, minWidth: 44),
                      child: IconButton(
                        icon: const Icon(Icons.file_download, color: Colors.white),
                        onPressed: () {
                          // Export data functionality
                        },
                        tooltip: 'Export Research Data',
                        iconSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Clean Tab Bar - matching Career Tab style
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
                      icon: Icon(Icons.scuba_diving, 
                        size: MediaQuery.of(context).size.width < 400 ? 18 : 20),
                      text: MediaQuery.of(context).size.width < 400 ? 'Performance' : 'Dive Performance',
                      height: 48,
                    ),
                    Tab(
                      icon: Icon(Icons.trending_up, 
                        size: MediaQuery.of(context).size.width < 400 ? 18 : 20),
                      text: MediaQuery.of(context).size.width < 400 ? 'Trends' : 'Discovery Trends',
                      height: 48,
                    ),
                    Tab(
                      icon: Icon(Icons.lightbulb, 
                        size: MediaQuery.of(context).size.width < 400 ? 18 : 20),
                      text: MediaQuery.of(context).size.width < 400 ? 'Insights' : 'Research Insights',
                      height: 48,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 12),
              // Tab Content
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).padding.bottom,
                    left: MediaQuery.of(context).size.width * 0.02,
                    right: MediaQuery.of(context).size.width * 0.02,
                  ),
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildDivePerformanceTab(),
                      _buildDiscoveryTrendsTab(),
                      _buildResearchInsightsTab(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivePerformanceTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: MediaQuery.of(context).size.width * 0.04,
        right: MediaQuery.of(context).size.width * 0.04,
        top: 8,
        bottom: 80, // Adjusted bottom padding for tab bar
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTodayStats(),
          SizedBox(height: _getResponsiveSpacing()),
          _buildStreakRewardsSection(),
          SizedBox(height: _getResponsiveSpacing()),
          _buildWeeklyChart(),
          SizedBox(height: _getResponsiveSpacing()),
          _buildCompletionRateChart(),
        ],
      ),
    );
  }

  Widget _buildDiscoveryTrendsTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: MediaQuery.of(context).size.width * 0.04,
        right: MediaQuery.of(context).size.width * 0.04,
        top: 8,
        bottom: 80, // Adjusted bottom padding for tab bar
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMonthlyTrendChart(),
          SizedBox(height: _getResponsiveSpacing()),
          _buildHourlyPatternChart(),
          SizedBox(height: _getResponsiveSpacing()),
          _buildWeeklyPatternChart(),
        ],
      ),
    );
  }

  Widget _buildResearchInsightsTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: MediaQuery.of(context).size.width * 0.04,
        right: MediaQuery.of(context).size.width * 0.04,
        top: 8,
        bottom: 80, // Adjusted bottom padding for tab bar
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Research Insights Overview Card - matching Career Tab style
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
                Icon(Icons.lightbulb, color: Colors.purple, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Research Lab Insights',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          _buildInsightsList(),
        ],
      ),
    );
  }

  Widget _buildTodayStats() {
    return FutureBuilder<AnalyticsData>(
      future: _analyticsService.getTodayAnalytics(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data!;

        return Container(
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.scuba_diving, color: Colors.cyan, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    _isNarrowScreen ? 'Today\'s Performance' : 'Today\'s Expedition Performance',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Dive Time',
                      '${data.totalFocusTime}m',
                      Icons.access_time,
                      Colors.cyan,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Expeditions',
                      '${data.sessionsCompleted}',
                      Icons.explore,
                      Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Success Rate',
                      '${(data.completionRate * 100).round()}%',
                      Icons.check_circle,
                      Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Research Streak',
                      '${data.streak} days',
                      Icons.local_fire_department,
                      Colors.amber,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: _getResponsiveFontSize(18),
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: _getResponsiveFontSize(13),
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyChart() {
    return FutureBuilder<List<AnalyticsData>>(
      future: _getLastWeekData(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()));
        }

        final data = snapshot.data!;
        final theme = Theme.of(context);

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📊 Weekly Dive Hours',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: _getResponsiveFontSize(18),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 200,
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(show: false),
                          titlesData: FlTitlesData(
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  if (value.toInt() < data.length) {
                                    return Text(
                                      DateFormat('E').format(data[value.toInt()].date),
                                      style: const TextStyle(fontSize: 12),
                                    );
                                  }
                                  return const Text('');
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  return Text('${value.toInt()}m');
                                },
                              ),
                            ),
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          ),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: data.asMap().entries.map((entry) {
                                return FlSpot(entry.key.toDouble(), entry.value.totalFocusTime.toDouble());
                              }).toList(),
                              isCurved: true,
                              color: theme.colorScheme.primary,
                              barWidth: 3,
                              belowBarData: BarAreaData(
                                show: true,
                                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                              ),
                              dotData: const FlDotData(show: false),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCompletionRateChart() {
    return FutureBuilder<List<AnalyticsData>>(
      future: _getLastWeekData(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()));
        }

        final data = snapshot.data!;
        final avgCompletionRate = data.isEmpty ? 0.0 : 
            data.map((d) => d.completionRate).reduce((a, b) => a + b) / data.length;

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🎯 Average Expedition Success Rate',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        // Pie Chart
                        Expanded(
                          flex: 2,
                          child: SizedBox(
                            height: 120,
                            child: PieChart(
                              PieChartData(
                                sectionsSpace: 3,
                                centerSpaceRadius: 30,
                                startDegreeOffset: -90,
                                sections: [
                                  PieChartSectionData(
                                    value: avgCompletionRate * 100,
                                    color: Colors.green.withValues(alpha: 0.8),
                                    title: '',
                                    radius: 35,
                                    borderSide: BorderSide(
                                      color: Colors.white.withValues(alpha: 0.3),
                                      width: 1,
                                    ),
                                  ),
                                  PieChartSectionData(
                                    value: (1 - avgCompletionRate) * 100,
                                    color: Colors.white.withValues(alpha: 0.1),
                                    title: '',
                                    radius: 35,
                                    borderSide: BorderSide(
                                      color: Colors.white.withValues(alpha: 0.2),
                                      width: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Statistics Text
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Expedition Success Rate',
                                style: TextStyle(
                                  fontSize: _getResponsiveFontSize(16),
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white.withValues(alpha: 0.9),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: Colors.green.withValues(alpha: 0.8),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Successful Dives: ${(avgCompletionRate * 100).round()}%',
                                    style: TextStyle(
                                      fontSize: _getResponsiveFontSize(14),
                                      color: Colors.white.withValues(alpha: 0.8),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.3),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Aborted Dives: ${((1 - avgCompletionRate) * 100).round()}%',
                                    style: TextStyle(
                                      fontSize: _getResponsiveFontSize(14),
                                      color: Colors.white.withValues(alpha: 0.8),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  avgCompletionRate >= 0.8
                                      ? 'Excellent! 🎉'
                                      : avgCompletionRate >= 0.6
                                          ? 'Good progress! 👍'
                                          : avgCompletionRate >= 0.4
                                              ? 'Keep improving! 💪'
                                              : 'Focus on consistency! 🎯',
                                  style: TextStyle(
                                    fontSize: _getResponsiveFontSize(12),
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white.withValues(alpha: 0.9),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMonthlyTrendChart() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '📈 Monthly Research Trend',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: _getResponsiveFontSize(18),
                  ),
                ),
                SizedBox(height: _getResponsiveSpacing() * 0.7),
                SizedBox(
                  height: 200,
                  child: FutureBuilder<List<AnalyticsData>>(
                    future: _getLastMonthData(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      
                      final data = snapshot.data!;
                      if (data.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.analytics_outlined,
                                size: 48,
                                color: Colors.white.withValues(alpha: 0.5),
                              ),
                              SizedBox(height: _getResponsiveSpacing() * 0.5),
                              Text(
                                'Complete more research expeditions\nto see monthly trends',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.7),
                                  fontSize: _getResponsiveFontSize(14),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      
                      return LineChart(
                        LineChartData(
                          gridData: FlGridData(show: false),
                          titlesData: FlTitlesData(
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 40,
                                getTitlesWidget: (value, meta) {
                                  if (value.toInt() < data.length && value.toInt() >= 0) {
                                    return Text(
                                      '${data[value.toInt()].date.day}',
                                      style: TextStyle(
                                        fontSize: _getResponsiveFontSize(10),
                                        color: Colors.white.withValues(alpha: 0.7),
                                      ),
                                    );
                                  }
                                  return const Text('');
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 40,
                                getTitlesWidget: (value, meta) {
                                  return Text(
                                    '${value.toInt()}m',
                                    style: TextStyle(
                                      fontSize: _getResponsiveFontSize(10),
                                      color: Colors.white.withValues(alpha: 0.7),
                                    ),
                                  );
                                },
                              ),
                            ),
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          ),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: data.asMap().entries.map((entry) {
                                return FlSpot(entry.key.toDouble(), entry.value.totalFocusTime.toDouble());
                              }).toList(),
                              isCurved: true,
                              color: const Color(0xFF00BFFF),
                              barWidth: 3,
                              belowBarData: BarAreaData(
                                show: true,
                                color: const Color(0xFF00BFFF).withValues(alpha: 0.2),
                              ),
                              dotData: FlDotData(
                                show: true,
                                getDotPainter: (spot, percent, barData, index) {
                                  return FlDotCirclePainter(
                                    radius: 3,
                                    color: Colors.white,
                                    strokeWidth: 2,
                                    strokeColor: const Color(0xFF00BFFF),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHourlyPatternChart() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '⏰ Daily Research Pattern',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: _getResponsiveFontSize(18),
                  ),
                ),
                SizedBox(height: _getResponsiveSpacing() * 0.7),
                SizedBox(
                  height: 200,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Time blocks representation
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildTimeBlock('6-9', 'AM', 0.3, 'Light'),
                              SizedBox(width: _isNarrowScreen ? 4 : 8),
                              _buildTimeBlock('9-12', 'AM', 0.7, 'Moderate'),
                              SizedBox(width: _isNarrowScreen ? 4 : 8),
                              _buildTimeBlock('12-3', 'PM', 0.5, 'Light'),
                              SizedBox(width: _isNarrowScreen ? 4 : 8),
                              _buildTimeBlock('3-6', 'PM', 0.8, 'High'),
                              SizedBox(width: _isNarrowScreen ? 4 : 8),
                              _buildTimeBlock('6-9', 'PM', 0.4, 'Light'),
                              SizedBox(width: _isNarrowScreen ? 4 : 8),
                              _buildTimeBlock('9-12', 'PM', 0.1, 'Very Low'),
                            ],
                          ),
                        ),
                        SizedBox(height: _getResponsiveSpacing()),
                        // Legend
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildLegendItem(Colors.blue.withValues(alpha: 0.3), 'Low'),
                            SizedBox(width: _isNarrowScreen ? 12 : 16),
                            _buildLegendItem(Colors.blue.withValues(alpha: 0.6), 'Moderate'),
                            SizedBox(width: _isNarrowScreen ? 12 : 16),
                            _buildLegendItem(Colors.blue.withValues(alpha: 0.9), 'High'),
                          ],
                        ),
                        SizedBox(height: _getResponsiveSpacing() * 0.5),
                        Text(
                          'Your most productive hours: 3-6 PM',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: _getResponsiveFontSize(13),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeeklyPatternChart() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '📅 Weekly Expedition Pattern',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: _getResponsiveFontSize(18),
                  ),
                ),
                SizedBox(height: _getResponsiveSpacing() * 0.7),
                SizedBox(
                  height: 200,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Week days with activity levels
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildWeekDayBlock('Mon', 0.8),
                              SizedBox(width: _isNarrowScreen ? 4 : 8),
                              _buildWeekDayBlock('Tue', 0.6),
                              SizedBox(width: _isNarrowScreen ? 4 : 8),
                              _buildWeekDayBlock('Wed', 0.9),
                              SizedBox(width: _isNarrowScreen ? 4 : 8),
                              _buildWeekDayBlock('Thu', 0.7),
                              SizedBox(width: _isNarrowScreen ? 4 : 8),
                              _buildWeekDayBlock('Fri', 0.5),
                              SizedBox(width: _isNarrowScreen ? 4 : 8),
                              _buildWeekDayBlock('Sat', 0.2),
                              SizedBox(width: _isNarrowScreen ? 4 : 8),
                              _buildWeekDayBlock('Sun', 0.3),
                            ],
                          ),
                        ),
                        SizedBox(height: _getResponsiveSpacing()),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Best research days: Mon, Wed, Thu',
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: _getResponsiveFontSize(13),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        SizedBox(height: _getResponsiveSpacing() * 0.5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.lightbulb_outline,
                              color: Colors.amber,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                'Consider scheduling important tasks on Wednesdays',
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.7),
                                  fontSize: _getResponsiveFontSize(11),
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInsightsList() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  size: 48,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No research insights yet',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontSize: _getResponsiveFontSize(18),
                  ),
                ),
                SizedBox(height: _getResponsiveSpacing() * 0.5),
                Text(
                  'Complete more research expeditions to get marine biology insights',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: _getResponsiveFontSize(14),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<List<AnalyticsData>> _getLastWeekData() async {
    final now = DateTime.now();
    return await _analyticsService.getAnalyticsData(
      startDate: now.subtract(const Duration(days: 7)),
      endDate: now,
    );
  }
  
  Future<List<AnalyticsData>> _getLastMonthData() async {
    final now = DateTime.now();
    return await _analyticsService.getAnalyticsData(
      startDate: now.subtract(const Duration(days: 30)),
      endDate: now,
    );
  }
  
  Widget _buildStreakRewardsSection() {
    final currentStreak = GamificationService.instance.currentStreak;
    final currentTier = StreakRewardsService.getCurrentStreakTier(currentStreak);
    final availableRewards = StreakRewardsService.getStreakRewards(currentStreak);
    
    // Create a daily reward for display
    final baseXP = 50;
    final streakBonusXP = currentStreak * 5;
    final todaysReward = currentStreak > 0 
        ? DailyStreakReward(
            baseXP: baseXP,
            streakBonusXP: streakBonusXP,
            timeBonusXP: 0,
            totalXP: baseXP + streakBonusXP,
            tier: currentTier,
            sessionsCompleted: 0,
            focusTimeMinutes: 0,
            discoveryRateBonus: currentStreak >= 7 ? 0.1 : 0.0,
          )
        : null;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.orange.withValues(alpha: 0.2),
            Colors.red.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.orange.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.local_fire_department, color: Colors.orange, size: 20),
              const SizedBox(width: 8),
              Text(
                'Research Streak Rewards',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          StreakRewardsDisplayWidget(
            currentStreak: currentStreak,
            currentTier: currentTier,
            availableRewards: availableRewards,
            todaysReward: todaysReward,
            showCompact: false,
          ),
        ],
      ),
    );
  }
  
  Widget _buildTimeBlock(String time, String period, double intensity, String label) {
    return Column(
      children: [
        Container(
          width: _isNarrowScreen ? 40 : 50,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: intensity),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  time,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: _getResponsiveFontSize(10),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  period,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: _getResponsiveFontSize(8),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: _getResponsiveFontSize(9),
          ),
        ),
      ],
    );
  }
  
  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 0.5,
            ),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: _getResponsiveFontSize(11),
          ),
        ),
      ],
    );
  }
  
  Widget _buildWeekDayBlock(String day, double intensity) {
    return Column(
      children: [
        Container(
          width: _isNarrowScreen ? 35 : 45,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.teal.withValues(alpha: intensity),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${(intensity * 10).toInt()}h',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: _getResponsiveFontSize(12),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                width: 20,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: intensity),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          day,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: _getResponsiveFontSize(11),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

}
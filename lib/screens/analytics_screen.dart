import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'dart:ui';
import '../services/analytics_service.dart';
import '../widgets/streak_rewards_display_widget.dart';
import '../services/streak_rewards_service.dart';
import '../utils/responsive_helper.dart';
import '../theme/ocean_theme_colors.dart';

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
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              OceanThemeColors.deepOceanBlue, // Deep Ocean Blue
              OceanThemeColors.deepOceanAccent, // Mid Ocean Blue
              OceanThemeColors.shallowWatersAccent, // Sky Blue
              OceanThemeColors.celebrationAccent, // Turquoise
            ],
            stops: const [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Responsive Header - adapts to screen size
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveHelper.getResponsiveSpacing(context, 'screen'),
                  vertical: ResponsiveHelper.getResponsiveSpacing(context, 'screen') * 0.75,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [OceanThemeColors.deepOceanBlue, OceanThemeColors.deepOceanAccent],
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
                              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'title'),
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Expedition Analytics & Performance',
                            style: TextStyle(
                              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'subtitle'),
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Responsive Tab Bar - adapts to screen size
              Container(
                margin: EdgeInsets.symmetric(
                  horizontal: ResponsiveHelper.getResponsiveSpacing(context, 'screen'),
                ),
                height: ResponsiveHelper.responsiveValue(
                  context: context,
                  mobile: 48.0,
                  tablet: 56.0,
                  desktop: 64.0,
                ),
                child: TabBar(
                  controller: _tabController,
                  indicatorColor: OceanThemeColors.seafoamGreen,
                  indicatorWeight: 3,
                  indicatorPadding: const EdgeInsets.symmetric(horizontal: 8),
                  dividerColor: Colors.transparent,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white60,
                  labelStyle: TextStyle(
                    fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'caption'),
                    fontWeight: FontWeight.w600,
                  ),
                  unselectedLabelStyle: TextStyle(
                    fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'caption') * 0.9,
                    fontWeight: FontWeight.w400,
                  ),
                  labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                  tabAlignment: TabAlignment.fill,
                  tabs: [
                    Tab(
                      icon: Icon(Icons.scuba_diving,
                          size: ResponsiveHelper.getIconSize(context, 'small')),
                      text: ResponsiveHelper.responsiveValue(
                        context: context,
                        mobile: 'Performance',
                        tablet: 'Dive Performance',
                        desktop: 'Dive Performance',
                      ),
                      height: ResponsiveHelper.responsiveValue(
                        context: context,
                        mobile: 48.0,
                        tablet: 56.0,
                        desktop: 64.0,
                      ),
                    ),
                    Tab(
                      icon: Icon(Icons.trending_up,
                          size: ResponsiveHelper.getIconSize(context, 'small')),
                      text: ResponsiveHelper.responsiveValue(
                        context: context,
                        mobile: 'Trends',
                        tablet: 'Discovery Trends',
                        desktop: 'Discovery Trends',
                      ),
                      height: ResponsiveHelper.responsiveValue(
                        context: context,
                        mobile: 48.0,
                        tablet: 56.0,
                        desktop: 64.0,
                      ),
                    ),
                    Tab(
                      icon: Icon(Icons.lightbulb,
                          size: ResponsiveHelper.getIconSize(context, 'small')),
                      text: ResponsiveHelper.responsiveValue(
                        context: context,
                        mobile: 'Insights',
                        tablet: 'Research Insights',
                        desktop: 'Research Insights',
                      ),
                      height: ResponsiveHelper.responsiveValue(
                        context: context,
                        mobile: 48.0,
                        tablet: 56.0,
                        desktop: 64.0,
                      ),
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
            child: Row(
              children: [
                Icon(Icons.lightbulb, color: OceanThemeColors.deepOceanAccent, size: 20),
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
              Row(
                children: [
                  Icon(Icons.scuba_diving, color: OceanThemeColors.deepOceanAccent, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    _isNarrowScreen
                        ? 'Today\'s Performance'
                        : 'Today\'s Expedition Performance',
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
                      Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Expeditions',
                      '${data.sessionsCompleted}',
                      Icons.explore,
                      OceanThemeColors.seafoamGreen,
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
                      Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Research Streak',
                      '${data.streak} days',
                      Icons.local_fire_department,
                      Colors.white.withValues(alpha: 0.8),
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

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
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
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
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
            child: const SizedBox(
                height: 200, child: Center(child: CircularProgressIndicator())),
          );
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
              Row(
                children: [
                  Icon(Icons.timeline, color: OceanThemeColors.deepOceanAccent, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Weekly Dive Hours',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: data.isEmpty || data.every((d) => d.totalFocusTime == 0)
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.scuba_diving,
                              size: 48,
                              color: Colors.white.withValues(alpha: 0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Complete research expeditions\nto see weekly dive hours',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: _getResponsiveFontSize(14),
                              ),
                            ),
                          ],
                        ),
                      )
                    : LineChart(
                        LineChartData(
                          gridData: FlGridData(show: false),
                          titlesData: FlTitlesData(
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 30,
                                getTitlesWidget: (value, meta) {
                                  if (value.toInt() < data.length &&
                                      value.toInt() >= 0) {
                                    return Text(
                                      DateFormat('E')
                                          .format(data[value.toInt()].date),
                                      style: TextStyle(
                                        fontSize: _getResponsiveFontSize(10),
                                        color:
                                            Colors.white.withValues(alpha: 0.7),
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
                                  final hours = value / 60;
                                  return Text(
                                    hours >= 1
                                        ? '${hours.toStringAsFixed(0)}h'
                                        : '${value.toInt()}m',
                                    style: TextStyle(
                                      fontSize: _getResponsiveFontSize(10),
                                      color:
                                          Colors.white.withValues(alpha: 0.7),
                                    ),
                                  );
                                },
                              ),
                            ),
                            topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                          ),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: data.asMap().entries.map((entry) {
                                return FlSpot(entry.key.toDouble(),
                                    entry.value.totalFocusTime.toDouble());
                              }).toList(),
                              isCurved: true,
                              color: OceanThemeColors.seafoamGreen,
                              barWidth: 3,
                              belowBarData: BarAreaData(
                                show: true,
                                color: OceanThemeColors.seafoamGreen.withValues(alpha: 0.2),
                              ),
                              dotData: FlDotData(
                                show: true,
                                getDotPainter: (spot, percent, barData, index) {
                                  return FlDotCirclePainter(
                                    radius: 3,
                                    color: Colors.white,
                                    strokeWidth: 2,
                                    strokeColor: OceanThemeColors.seafoamGreen,
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ],
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
                                  if (value.toInt() < data.length &&
                                      value.toInt() >= 0) {
                                    return Text(
                                      '${data[value.toInt()].date.day}',
                                      style: TextStyle(
                                        fontSize: _getResponsiveFontSize(10),
                                        color:
                                            Colors.white.withValues(alpha: 0.7),
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
                                      color:
                                          Colors.white.withValues(alpha: 0.7),
                                    ),
                                  );
                                },
                              ),
                            ),
                            topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                          ),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: data.asMap().entries.map((entry) {
                                return FlSpot(entry.key.toDouble(),
                                    entry.value.totalFocusTime.toDouble());
                              }).toList(),
                              isCurved: true,
                              color: OceanThemeColors.celebrationAccent,
                              barWidth: 3,
                              belowBarData: BarAreaData(
                                show: true,
                                color: OceanThemeColors.celebrationAccent
                                    .withValues(alpha: 0.2),
                              ),
                              dotData: FlDotData(
                                show: true,
                                getDotPainter: (spot, percent, barData, index) {
                                  return FlDotCirclePainter(
                                    radius: 3,
                                    color: Colors.white,
                                    strokeWidth: 2,
                                    strokeColor: OceanThemeColors.celebrationAccent,
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
                  child: FutureBuilder<WeeklyPattern>(
                    future: _analyticsService.getWeeklyPattern(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 48,
                                color: Colors.white.withValues(alpha: 0.5),
                              ),
                              SizedBox(height: _getResponsiveSpacing() * 0.5),
                              Text(
                                'Error loading pattern data',
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

                      if (!snapshot.hasData) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.schedule,
                                size: 48,
                                color: Colors.white.withValues(alpha: 0.5),
                              ),
                              SizedBox(height: _getResponsiveSpacing() * 0.5),
                              Text(
                                'No pattern data available',
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

                      final pattern = snapshot.data!;
                      final hourlyData = pattern.hourlyFocus;

                      // Find max value for normalization
                      final maxMinutes = hourlyData.values.isEmpty
                          ? 1.0
                          : hourlyData.values.reduce((a, b) => a > b ? a : b);

                      // Group hours into time blocks for display
                      final timeBlocks = [
                        {
                          'range': '6-9',
                          'period': 'AM',
                          'hours': [6, 7, 8]
                        },
                        {
                          'range': '9-12',
                          'period': 'AM',
                          'hours': [9, 10, 11]
                        },
                        {
                          'range': '12-3',
                          'period': 'PM',
                          'hours': [12, 13, 14]
                        },
                        {
                          'range': '3-6',
                          'period': 'PM',
                          'hours': [15, 16, 17]
                        },
                        {
                          'range': '6-9',
                          'period': 'PM',
                          'hours': [18, 19, 20]
                        },
                        {
                          'range': '9-12',
                          'period': 'PM',
                          'hours': [21, 22, 23]
                        },
                      ];

                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Time blocks representation
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: timeBlocks.map((block) {
                                  final hours = block['hours'] as List<int>;
                                  final totalMinutes = hours.fold<double>(
                                      0,
                                      (sum, hour) =>
                                          sum + (hourlyData[hour] ?? 0));
                                  final avgMinutes =
                                      totalMinutes / hours.length;
                                  final intensity = maxMinutes > 0
                                      ? (avgMinutes / maxMinutes)
                                          .clamp(0.0, 1.0)
                                      : 0.0;

                                  String label;
                                  if (intensity >= 0.7) {
                                    label = 'High';
                                  } else if (intensity >= 0.4) {
                                    label = 'Moderate';
                                  } else if (intensity >= 0.1) {
                                    label = 'Light';
                                  } else {
                                    label = 'Very Low';
                                  }

                                  return Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: _isNarrowScreen ? 2 : 4),
                                    child: _buildTimeBlock(
                                      block['range'] as String,
                                      block['period'] as String,
                                      intensity,
                                      label,
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                            SizedBox(height: _getResponsiveSpacing()),
                            // Legend
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildLegendItem(
                                    Colors.blue.withValues(alpha: 0.3), 'Low'),
                                SizedBox(width: _isNarrowScreen ? 12 : 16),
                                _buildLegendItem(
                                    Colors.blue.withValues(alpha: 0.6),
                                    'Moderate'),
                                SizedBox(width: _isNarrowScreen ? 12 : 16),
                                _buildLegendItem(
                                    Colors.blue.withValues(alpha: 0.9), 'High'),
                              ],
                            ),
                            SizedBox(height: _getResponsiveSpacing() * 0.5),
                            Text(
                              pattern.mostProductiveHour > 0
                                  ? 'Your most productive hour: ${_getHourFormat(pattern.mostProductiveHour)}'
                                  : 'Complete focus sessions to see patterns',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: _getResponsiveFontSize(13),
                                fontWeight: FontWeight.w500,
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
                  child: FutureBuilder<WeeklyPattern>(
                    future: _analyticsService.getWeeklyPattern(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 48,
                                color: Colors.white.withValues(alpha: 0.5),
                              ),
                              SizedBox(height: _getResponsiveSpacing() * 0.5),
                              Text(
                                'Error loading weekly pattern',
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

                      if (!snapshot.hasData) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 48,
                                color: Colors.white.withValues(alpha: 0.5),
                              ),
                              SizedBox(height: _getResponsiveSpacing() * 0.5),
                              Text(
                                'Complete more research expeditions\nto see weekly patterns',
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

                      final pattern = snapshot.data!;
                      final dailyData = pattern.dailyFocus;

                      // Find max value for normalization
                      final maxMinutes = dailyData.values.isEmpty
                          ? 1.0
                          : dailyData.values.reduce((a, b) => a > b ? a : b);

                      final dayNames = [
                        'Mon',
                        'Tue',
                        'Wed',
                        'Thu',
                        'Fri',
                        'Sat',
                        'Sun'
                      ];

                      // Find best research days
                      final sortedDays = dailyData.entries.toList()
                        ..sort((a, b) => b.value.compareTo(a.value));
                      final topDays = sortedDays
                          .take(3)
                          .map((e) => _getDayFormat(e.key).substring(0, 3))
                          .toList();

                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Week days with activity levels
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: List.generate(7, (index) {
                                  final weekday =
                                      index + 1; // Monday = 1, Sunday = 7
                                  final minutes = dailyData[weekday] ?? 0.0;
                                  final intensity = maxMinutes > 0
                                      ? (minutes / maxMinutes).clamp(0.0, 1.0)
                                      : 0.0;

                                  return Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: _isNarrowScreen ? 2 : 4),
                                    child: _buildWeekDayBlock(
                                        dayNames[index], intensity),
                                  );
                                }),
                              ),
                            ),
                            SizedBox(height: _getResponsiveSpacing()),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                topDays.isNotEmpty
                                    ? 'Best research days: ${topDays.join(', ')}'
                                    : 'Complete research expeditions to see patterns',
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
                                  color: OceanThemeColors.seafoamGreen,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    pattern.mostProductiveDay > 0
                                        ? 'Consider scheduling important tasks on ${_getDayFormat(pattern.mostProductiveDay)}s'
                                        : 'Build a routine to establish productive patterns',
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color:
                                          Colors.white.withValues(alpha: 0.7),
                                      fontSize: _getResponsiveFontSize(11),
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                              ],
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

  Widget _buildInsightsList() {
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
            child: FutureBuilder<List<ProductivityInsight>>(
              future: _analyticsService.getProductivityInsights(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 100,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (snapshot.hasError) {
                  return Column(
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading insights',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.white,
                                  fontSize: _getResponsiveFontSize(18),
                                ),
                      ),
                    ],
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Column(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No research insights yet',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
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
                  );
                }

                final insights = snapshot.data!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🔍 Research Lab Insights',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: _getResponsiveFontSize(18),
                          ),
                    ),
                    SizedBox(height: _getResponsiveSpacing()),
                    ...insights.map((insight) => _buildInsightCard(insight)),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInsightCard(ProductivityInsight insight) {
    Color cardColor;
    Color iconColor;
    IconData iconData;

    switch (insight.type) {
      case InsightType.positive:
        cardColor = OceanThemeColors.seafoamGreen.withValues(alpha: 0.2);
        iconColor = OceanThemeColors.seafoamGreen;
        iconData = Icons.trending_up;
        break;
      case InsightType.negative:
        cardColor = OceanThemeColors.deepOceanBlue.withValues(alpha: 0.3);
        iconColor = Colors.white.withValues(alpha: 0.8);
        iconData = Icons.trending_down;
        break;
      case InsightType.suggestion:
        cardColor = OceanThemeColors.deepOceanAccent.withValues(alpha: 0.3);
        iconColor = OceanThemeColors.deepOceanAccent;
        iconData = Icons.lightbulb_outline;
        break;
      case InsightType.neutral:
        cardColor = OceanThemeColors.deepOceanBlue.withValues(alpha: 0.2);
        iconColor = Colors.white.withValues(alpha: 0.8);
        iconData = Icons.info_outline;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: iconColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              iconData,
              color: iconColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  insight.title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: _getResponsiveFontSize(15),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  insight.description,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: _getResponsiveFontSize(13),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${(insight.impact * 100).round()}%',
              style: TextStyle(
                color: iconColor,
                fontSize: _getResponsiveFontSize(11),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getHourFormat(int hour) {
    if (hour == 0) return "12 AM";
    if (hour < 12) return "$hour AM";
    if (hour == 12) return "12 PM";
    return "${hour - 12} PM";
  }

  String _getDayFormat(int weekday) {
    const days = [
      "",
      "Monday",
      "Tuesday",
      "Wednesday",
      "Thursday",
      "Friday",
      "Saturday",
      "Sunday"
    ];
    return days[weekday];
  }

  Future<List<AnalyticsData>> _getLastWeekData() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    // Get exactly 7 days: 6 previous days + today
    return await _analyticsService.getAnalyticsData(
      startDate: today.subtract(const Duration(days: 6)),
      endDate: today.add(const Duration(days: 1)), // Add 1 day to include today
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
    // Use analytics service streak calculation (database-based) for consistency
    return FutureBuilder<AnalyticsData>(
      future: _analyticsService.getTodayAnalytics(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
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
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        final currentStreak = snapshot.data!.streak;
        final currentTier =
            StreakRewardsService.getCurrentStreakTier(currentStreak);
        final availableRewards =
            StreakRewardsService.getStreakRewards(currentStreak);

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

        return _buildStreakRewardsContainer(
            currentStreak, currentTier, availableRewards, todaysReward);
      },
    );
  }

  Widget _buildStreakRewardsContainer(int currentStreak, StreakTier currentTier,
      List<StreakReward> availableRewards, DailyStreakReward? todaysReward) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
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
          Row(
            children: [
              Icon(Icons.local_fire_department, color: OceanThemeColors.seafoamGreen, size: 20),
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

  Widget _buildTimeBlock(
      String time, String period, double intensity, String label) {
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

  // Close the extra Container wrapper added for dark overlay
}

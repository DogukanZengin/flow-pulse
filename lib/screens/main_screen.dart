import 'package:flutter/material.dart';
import 'timer_screen.dart';
import 'analytics_screen.dart';
import 'career_screen.dart';
import 'community_screen.dart';
import 'settings_screen.dart';
import '../widgets/ocean_navigation_bar.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  late List<Widget> _screens;
  final GlobalKey<TimerScreenState> _timerKey = GlobalKey<TimerScreenState>();

  @override
  void initState() {
    super.initState();
    _screens = [
      TimerScreen(key: _timerKey),
      const AnalyticsScreen(),
      const CareerScreen(),
      const CommunityScreen(),
      const SettingsScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4A8FA0), // Match navigation bar bottom color
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      extendBody: false,
      bottomNavigationBar: OceanNavigationBar(
        currentIndex: _currentIndex,
        onTap: _selectTab,
      ),
    );
  }

  void _selectTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
}
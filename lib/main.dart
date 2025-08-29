import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'providers/timer_provider.dart';
import 'services/gamification_service.dart';
import 'services/notification_service.dart';
import 'services/live_activities_service.dart';
import 'services/persistence/persistence_service.dart';
import 'services/efficient_background_timer_service.dart';
import 'screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize core services
  await PersistenceService.instance.initialize();
  await GamificationService.instance.initialize();
  
  // Mobile-only services
  if (!kIsWeb) {
    await NotificationService().initialize();
    await LiveActivitiesService().initialize();
    await EfficientBackgroundTimerService().initialize();
  }
  
  runApp(const FlowPulseApp());
}

class FlowPulseApp extends StatelessWidget {
  const FlowPulseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844), // iPhone 14 design reference
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return ChangeNotifierProvider(
          create: (context) => TimerProvider()..loadSettings(),
          child: MaterialApp(
            title: 'FlowPulse',
            theme: ThemeData.light(useMaterial3: true),
            darkTheme: ThemeData.dark(useMaterial3: true),
            themeMode: ThemeMode.system, // Follow system theme
            home: const MainScreen(),
          ),
        );
      },
    );
  }
}


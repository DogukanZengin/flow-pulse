import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

/// Widget that manages app lifecycle events and ensures proper background processing
class LifecycleManager extends StatefulWidget {
  final Widget child;
  
  const LifecycleManager({
    super.key,
    required this.child,
  });

  @override
  State<LifecycleManager> createState() => _LifecycleManagerState();
}

class _LifecycleManagerState extends State<LifecycleManager> with WidgetsBindingObserver {
  DateTime? _backgroundTime;
  bool _wasInBackground = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    if (kDebugMode) {
      debugPrint('LifecycleManager: Initialized');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    if (kDebugMode) {
      debugPrint('LifecycleManager: App lifecycle state changed to $state');
    }

    switch (state) {
      case AppLifecycleState.resumed:
        _handleAppResumed();
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
        _handleAppPaused();
        break;
      case AppLifecycleState.hidden:
        _handleAppHidden();
        break;
    }
  }

  void _handleAppResumed() {
    if (kDebugMode) {
      debugPrint('LifecycleManager: App resumed');
    }

    if (_wasInBackground && _backgroundTime != null) {
      final backgroundDuration = DateTime.now().difference(_backgroundTime!);
      
      if (kDebugMode) {
        debugPrint('LifecycleManager: App was in background for ${backgroundDuration.inSeconds} seconds');
      }

      // Check if we need to sync any timer state
      _syncTimerStateAfterBackground(backgroundDuration);
    }

    _wasInBackground = false;
    _backgroundTime = null;

    // Cancel any stale notifications
    _cleanupNotifications();
  }

  void _handleAppPaused() {
    if (kDebugMode) {
      debugPrint('LifecycleManager: App paused');
    }

    _backgroundTime = DateTime.now();
    _wasInBackground = true;

    // Ensure timer state is persisted
    _persistTimerState();

    // Update notifications if timer is running
    _updateBackgroundNotifications();
  }

  void _handleAppHidden() {
    if (kDebugMode) {
      debugPrint('LifecycleManager: App hidden');
    }
    
    // App is hidden but may still be running
    // Save state as a precaution
    _persistTimerState();
  }

  Future<void> _syncTimerStateAfterBackground(Duration backgroundDuration) async {
    // This will be handled by the BackgroundTimerService automatically
    // but we can add additional UI-specific logic here if needed
    
    try {
      // Force a rebuild to ensure UI is in sync
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('LifecycleManager: Error syncing timer state: $e');
      }
    }
  }

  void _persistTimerState() {
    // The BackgroundTimerService handles this automatically
    // This is just a placeholder for any additional state persistence
    if (kDebugMode) {
      debugPrint('LifecycleManager: Persisting timer state');
    }
  }

  void _updateBackgroundNotifications() {
    // Update any active notifications to reflect current timer state
    // The timer controller handles this, but we can add cleanup here
    if (kDebugMode) {
      debugPrint('LifecycleManager: Updating background notifications');
    }
  }

  void _cleanupNotifications() {
    // Clean up any stale notifications when app returns to foreground
    Future.delayed(const Duration(milliseconds: 500), () {
      // Give time for the timer controller to update notifications
      // Then clean up any that shouldn't be there
      if (kDebugMode) {
        debugPrint('LifecycleManager: Cleaning up notifications');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
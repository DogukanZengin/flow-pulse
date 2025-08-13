import 'package:flutter/foundation.dart';
import 'package:quick_actions/quick_actions.dart';

class QuickActionsService {
  static final QuickActionsService _instance = QuickActionsService._internal();
  factory QuickActionsService() => _instance;
  QuickActionsService._internal();
  
  final QuickActions _quickActions = const QuickActions();
  Function(String)? _onActionCallback;
  
  Future<void> initialize() async {
    if (kIsWeb) return; // Quick actions not supported on web
    
    // Set up quick actions
    await _quickActions.setShortcutItems([
      const ShortcutItem(
        type: 'start_focus',
        localizedTitle: '▶️ Start Focus',
        icon: 'focus',
      ),
      const ShortcutItem(
        type: 'start_break',
        localizedTitle: '☕ Start Break',
        icon: 'break',
      ),
      const ShortcutItem(
        type: 'view_stats',
        localizedTitle: '📊 View Stats',
        icon: 'stats',
      ),
      const ShortcutItem(
        type: 'ambient_mode',
        localizedTitle: '🧘 Ambient Mode',
        icon: 'ambient',
      ),
    ]);
    
    // Listen for quick action taps
    _quickActions.initialize((type) {
      if (_onActionCallback != null) {
        _onActionCallback!(type);
      }
    });
  }
  
  void setActionCallback(Function(String) callback) {
    _onActionCallback = callback;
  }
  
  Future<void> updateShortcuts({
    required bool isTimerRunning,
    required bool isStudySession,
  }) async {
    if (kIsWeb) return;
    
    final shortcuts = <ShortcutItem>[];
    
    if (isTimerRunning) {
      shortcuts.add(const ShortcutItem(
        type: 'pause_timer',
        localizedTitle: '⏸️ Pause Timer',
        icon: 'pause',
      ));
      shortcuts.add(const ShortcutItem(
        type: 'reset_timer',
        localizedTitle: '🔄 Reset Timer',
        icon: 'reset',
      ));
    } else {
      shortcuts.add(ShortcutItem(
        type: 'resume_timer',
        localizedTitle: isStudySession ? '▶️ Resume Focus' : '▶️ Resume Break',
        icon: 'play',
      ));
      shortcuts.add(const ShortcutItem(
        type: 'start_focus',
        localizedTitle: '🎯 Start Focus',
        icon: 'focus',
      ));
    }
    
    shortcuts.add(const ShortcutItem(
      type: 'view_stats',
      localizedTitle: '📊 View Stats',
      icon: 'stats',
    ));
    
    shortcuts.add(const ShortcutItem(
      type: 'ambient_mode',
      localizedTitle: '🧘 Ambient Mode',
      icon: 'ambient',
    ));
    
    await _quickActions.setShortcutItems(shortcuts);
  }
}
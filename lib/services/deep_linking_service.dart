import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';

class DeepLinkingService {
  static final DeepLinkingService _instance = DeepLinkingService._internal();
  factory DeepLinkingService() => _instance;
  DeepLinkingService._internal();
  
  final AppLinks _appLinks = AppLinks();
  Function(String)? _onLinkCallback;
  
  Future<void> initialize() async {
    if (kIsWeb) return; // App links work differently on web
    
    try {
      // Handle app launch from link
      final initialLink = await _appLinks.getInitialLink();
      if (initialLink != null) {
        _handleDeepLink(initialLink);
      }
      
      // Listen for incoming links when app is already running
      _appLinks.uriLinkStream.listen((uri) {
        _handleDeepLink(uri);
      });
    } catch (e) {
      if (kDebugMode) {
        print('Deep linking error: $e');
      }
    }
  }
  
  void setLinkCallback(Function(String) callback) {
    _onLinkCallback = callback;
  }
  
  void _handleDeepLink(Uri uri) {
    if (kDebugMode) {
      print('Deep link received: $uri');
    }
    
    final action = _parseDeepLink(uri);
    if (action != null && _onLinkCallback != null) {
      _onLinkCallback!(action);
    }
  }
  
  String? _parseDeepLink(Uri uri) {
    // Handle different deep link formats
    // flowpulse://action/start_focus
    // flowpulse://action/start_break
    // flowpulse://action/view_stats
    // flowpulse://action/ambient_mode
    
    if (uri.scheme == 'flowpulse' && uri.host == 'action') {
      final pathSegments = uri.pathSegments;
      if (pathSegments.isNotEmpty) {
        return pathSegments.first;
      }
    }
    
    // Handle universal links
    // https://flowpulse.app/start/focus
    // https://flowpulse.app/start/break
    if (uri.host == 'flowpulse.app') {
      final pathSegments = uri.pathSegments;
      if (pathSegments.length >= 2) {
        final action = pathSegments[0];
        final type = pathSegments[1];
        
        switch (action) {
          case 'start':
            return type == 'focus' ? 'start_focus' : 'start_break';
          case 'view':
            return 'view_stats';
          case 'ambient':
            return 'ambient_mode';
        }
      }
    }
    
    return null;
  }
  
  // Generate shareable links
  static String generateStartFocusLink() {
    return 'https://flowpulse.app/start/focus';
  }
  
  static String generateStartBreakLink() {
    return 'https://flowpulse.app/start/break';
  }
  
  static String generateStatsLink() {
    return 'https://flowpulse.app/view/stats';
  }
  
  static String generateAmbientModeLink() {
    return 'https://flowpulse.app/ambient';
  }
}
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

enum UISound {
  buttonTap,
  navigationSwitch,
  timerStart,
  timerPause,
  sessionComplete,
  achievement,
  error,
  success,
}

class UISoundService {
  static final UISoundService _instance = UISoundService._internal();
  factory UISoundService() => _instance;
  UISoundService._internal();

  static UISoundService get instance => _instance;

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _soundEnabled = true;

  // Enable/disable UI sounds
  void setSoundEnabled(bool enabled) {
    _soundEnabled = enabled;
  }


  // Play UI sound with haptic feedback
  Future<void> playSound(UISound sound) async {
    if (!_soundEnabled) return;

    try {
      // Add subtle haptic feedback for certain sounds
      switch (sound) {
        case UISound.buttonTap:
        case UISound.navigationSwitch:
          HapticFeedback.lightImpact();
          break;
        case UISound.timerStart:
        case UISound.timerPause:
          HapticFeedback.mediumImpact();
          break;
        case UISound.sessionComplete:
        case UISound.achievement:
          HapticFeedback.heavyImpact();
          break;
        case UISound.error:
          HapticFeedback.lightImpact();
          break;
        case UISound.success:
          HapticFeedback.mediumImpact();
          break;
      }

      // Generate sound programmatically for web compatibility
      await _generateTone(_getSoundFrequency(sound), _getSoundDuration(sound));
      
    } catch (e) {
      // Silently fail if sound can't be played
    }
  }

  // Get frequency for each sound type
  double _getSoundFrequency(UISound sound) {
    switch (sound) {
      case UISound.buttonTap:
        return 800.0; // Higher pitch for quick feedback
      case UISound.navigationSwitch:
        return 600.0; // Medium pitch for navigation
      case UISound.timerStart:
        return 440.0; // Pleasant A note
      case UISound.timerPause:
        return 349.0; // F note (lower)
      case UISound.sessionComplete:
        return 523.0; // C note (celebratory)
      case UISound.achievement:
        return 659.0; // E note (bright)
      case UISound.error:
        return 200.0; // Low pitch for errors
      case UISound.success:
        return 784.0; // G note (positive)
    }
  }

  // Get duration for each sound type
  int _getSoundDuration(UISound sound) {
    switch (sound) {
      case UISound.buttonTap:
      case UISound.navigationSwitch:
        return 50; // Very brief
      case UISound.timerStart:
      case UISound.timerPause:
        return 150; // Short but noticeable
      case UISound.sessionComplete:
      case UISound.achievement:
        return 300; // Longer for celebration
      case UISound.error:
        return 200; // Medium length
      case UISound.success:
        return 150; // Pleasant feedback
    }
  }

  // Generate simple tone (for web compatibility)
  Future<void> _generateTone(double frequency, int durationMs) async {
    // This is a placeholder for tone generation
    // In a real implementation, you would use a tone generator
    // For now, we'll just use the existing audio system
    
    // Since we don't have actual audio files, we'll rely on haptic feedback
    // In a production app, you would have actual sound files in assets/sounds/
    
    await Future.delayed(Duration(milliseconds: durationMs ~/ 10));
  }

  // Convenience methods for common UI interactions
  Future<void> buttonTap() => playSound(UISound.buttonTap);
  Future<void> navigationSwitch() => playSound(UISound.navigationSwitch);
  Future<void> timerStart() => playSound(UISound.timerStart);
  Future<void> timerPause() => playSound(UISound.timerPause);
  Future<void> sessionComplete() => playSound(UISound.sessionComplete);
  Future<void> achievement() => playSound(UISound.achievement);
  Future<void> error() => playSound(UISound.error);
  Future<void> success() => playSound(UISound.success);

  // Dispose resources
  void dispose() {
    _audioPlayer.dispose();
  }
}
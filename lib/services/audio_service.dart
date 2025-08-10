import 'package:audioplayers/audioplayers.dart';

enum SoundType {
  rain,
  forest,
  ocean,
  whiteNoise,
  brownNoise,
}

extension SoundTypeExtension on SoundType {
  String get displayName {
    switch (this) {
      case SoundType.rain:
        return 'Rain';
      case SoundType.forest:
        return 'Forest';
      case SoundType.ocean:
        return 'Ocean Waves';
      case SoundType.whiteNoise:
        return 'White Noise';
      case SoundType.brownNoise:
        return 'Brown Noise';
    }
  }

  String get fileName {
    switch (this) {
      case SoundType.rain:
        return 'rain.mp3';
      case SoundType.forest:
        return 'forest.mp3';
      case SoundType.ocean:
        return 'ocean.mp3';
      case SoundType.whiteNoise:
        return 'white_noise.mp3';
      case SoundType.brownNoise:
        return 'brown_noise.mp3';
    }
  }
}

class AudioService {
  static AudioService? _instance;
  static AudioService get instance => _instance ??= AudioService._();
  
  AudioService._();

  final AudioPlayer _audioPlayer = AudioPlayer();
  SoundType? _currentSound;
  double _volume = 0.5;
  bool _isPlaying = false;

  bool get isPlaying => _isPlaying;
  SoundType? get currentSound => _currentSound;
  double get volume => _volume;

  Future<void> playSound(SoundType soundType) async {
    try {
      await _audioPlayer.stop();
      
      // For now, we'll use local assets
      // In a real app, you'd include actual sound files in assets/sounds/
      await _audioPlayer.setSource(AssetSource('sounds/${soundType.fileName}'));
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.setVolume(_volume);
      await _audioPlayer.resume();
      
      _currentSound = soundType;
      _isPlaying = true;
    } catch (e) {
      // For demo purposes, we'll silently fail
      // In production, you'd want proper error handling
      _isPlaying = false;
    }
  }

  Future<void> stopSound() async {
    try {
      await _audioPlayer.stop();
      _currentSound = null;
      _isPlaying = false;
    } catch (e) {
      // Handle error silently for demo
    }
  }

  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0);
    if (_isPlaying) {
      await _audioPlayer.setVolume(_volume);
    }
  }

  Future<void> pauseSound() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
      _isPlaying = false;
    }
  }

  Future<void> resumeSound() async {
    if (_currentSound != null && !_isPlaying) {
      await _audioPlayer.resume();
      _isPlaying = true;
    }
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}
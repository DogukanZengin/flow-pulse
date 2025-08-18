import 'package:audioplayers/audioplayers.dart';

enum SoundType {
  // Basic sounds for ocean theme
  ocean,
  gentleWaves,
  spaceDrone, // For deep ocean ambient
}

enum SoundCategory {
  nature,
  ambient,
}

extension SoundTypeExtension on SoundType {
  String get displayName {
    switch (this) {
      case SoundType.ocean:
        return 'Ocean Waves';
      case SoundType.gentleWaves:
        return 'Gentle Waves';
      case SoundType.spaceDrone:
        return 'Deep Ocean';
    }
  }

  String get fileName {
    // All sounds use ocean.mp3 for ocean theme
    return 'ocean.mp3';
  }

  bool get isPremium {
    return false; // All sounds are free for ocean theme
  }

  SoundCategory get category {
    switch (this) {
      case SoundType.ocean:
      case SoundType.gentleWaves:
        return SoundCategory.nature;
      case SoundType.spaceDrone:
        return SoundCategory.ambient;
    }
  }

  static List<SoundType> get freeSounds => SoundType.values;

  static List<SoundType> get premiumSounds => <SoundType>[];
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
      
      // Use ocean.mp3 for all sounds in ocean theme
      await _audioPlayer.setSource(AssetSource('sounds/${soundType.fileName}'));
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.setVolume(_volume);
      await _audioPlayer.resume();
      
      _currentSound = soundType;
      _isPlaying = true;
    } catch (e) {
      _isPlaying = false;
    }
  }


  Future<void> stopSound() async {
    try {
      await _audioPlayer.stop();
      _currentSound = null;
      _isPlaying = false;
    } catch (e) {
      // Handle error silently
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
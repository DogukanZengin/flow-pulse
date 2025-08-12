import 'package:flutter/material.dart';
import 'dart:ui';
import '../services/audio_service.dart';

class AudioControls extends StatefulWidget {
  const AudioControls({super.key});

  @override
  State<AudioControls> createState() => _AudioControlsState();
}

class _AudioControlsState extends State<AudioControls> {
  final AudioService _audioService = AudioService.instance;
  bool _isPlaying = false;
  SoundType? _selectedSound;

  @override
  void initState() {
    super.initState();
    _isPlaying = _audioService.isPlaying;
    _selectedSound = _audioService.currentSound;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Icons.music_note,
                size: 20,
                color: Colors.white.withOpacity(0.9),
              ),
              const SizedBox(width: 8),
              Text(
                'Ambient Sounds',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: _isPlaying ? _stopSound : null,
                icon: Icon(
                  _isPlaying ? Icons.stop : Icons.music_off,
                  size: 20,
                ),
                iconSize: 20,
                constraints: const BoxConstraints(
                  minWidth: 32,
                  minHeight: 32,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: SoundType.values.map((sound) {
              final isSelected = _selectedSound == sound && _isPlaying;
              return GestureDetector(
                onTap: () => _toggleSound(sound),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? Colors.white.withOpacity(0.3)
                        : Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected 
                          ? Colors.white.withOpacity(0.6)
                          : Colors.white.withOpacity(0.2),
                    ),
                  ),
                  child: Text(
                    sound.displayName,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white.withOpacity(isSelected ? 1.0 : 0.8),
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          if (_isPlaying) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.volume_down,
                  size: 16,
                  color: Colors.white.withOpacity(0.9),
                ),
                Expanded(
                  child: Slider(
                    value: _audioService.volume,
                    onChanged: (value) {
                      setState(() {
                        _audioService.setVolume(value);
                      });
                    },
                    min: 0.0,
                    max: 1.0,
                  ),
                ),
                Icon(
                  Icons.volume_up,
                  size: 16,
                  color: Colors.white.withOpacity(0.9),
                ),
              ],
            ),
          ],
        ],
            ),
          ),
        ),
      ),
    );
  }

  void _toggleSound(SoundType sound) async {
    if (_selectedSound == sound && _isPlaying) {
      // Stop current sound
      await _audioService.stopSound();
      setState(() {
        _isPlaying = false;
        _selectedSound = null;
      });
    } else {
      // Play new sound
      await _audioService.playSound(sound);
      setState(() {
        _isPlaying = true;
        _selectedSound = sound;
      });
    }
  }

  void _stopSound() async {
    await _audioService.stopSound();
    setState(() {
      _isPlaying = false;
      _selectedSound = null;
    });
  }
}
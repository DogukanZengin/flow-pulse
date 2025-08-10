import 'package:flutter/material.dart';
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Icons.music_note,
                size: 20,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Text(
                'Ambient Sounds',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
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
                        ? theme.colorScheme.primary.withValues(alpha: 0.2)
                        : theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected 
                          ? theme.colorScheme.primary 
                          : theme.colorScheme.outline.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    sound.displayName,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isSelected 
                          ? theme.colorScheme.primary 
                          : theme.colorScheme.onSurfaceVariant,
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
                  color: theme.colorScheme.onSurfaceVariant,
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
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ],
        ],
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
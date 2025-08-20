import 'package:flutter/material.dart';
import '../services/fast_forward_service.dart';

/// Widget for controlling fast forward mode during development/testing
/// Provides easy access to speed presets and controls for testing XP progression
class FastForwardControlWidget extends StatefulWidget {
  const FastForwardControlWidget({super.key});

  @override
  State<FastForwardControlWidget> createState() => _FastForwardControlWidgetState();
}

class _FastForwardControlWidgetState extends State<FastForwardControlWidget> {
  final FastForwardService _fastForward = FastForwardService.instance;

  @override
  void initState() {
    super.initState();
    _fastForward.addListener(_onFastForwardChanged);
  }

  @override
  void dispose() {
    _fastForward.removeListener(_onFastForwardChanged);
    super.dispose();
  }

  void _onFastForwardChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                const Icon(
                  Icons.fast_forward,
                  color: Colors.orange,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Fast Forward Mode',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Switch(
                  value: _fastForward.isEnabled,
                  onChanged: (enabled) {
                    if (enabled) {
                      _fastForward.enable();
                    } else {
                      _fastForward.disable();
                    }
                  },
                  activeColor: Colors.orange,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Status indicator
            if (_fastForward.isEnabled) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.withValues(alpha: 0.5)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.bolt, color: Colors.orange, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'Active: ${_fastForward.currentPresetName}',
                      style: const TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Warning message
            if (_fastForward.getWarningMessage().isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning, color: Colors.amber, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _fastForward.getWarningMessage(),
                        style: const TextStyle(
                          color: Colors.amber,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Speed presets
            const Text(
              'Speed Presets:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: FastForwardService.speedPresets.entries.map((entry) {
                final isSelected = _fastForward.speedMultiplier == entry.value;
                final isNormalSpeed = entry.value == 1.0;
                
                return GestureDetector(
                  onTap: () => _fastForward.applyPreset(entry.key),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (isNormalSpeed ? Colors.green : Colors.orange)
                          : Colors.grey.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? (isNormalSpeed ? Colors.green : Colors.orange)
                            : Colors.grey.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      entry.key,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : Theme.of(context).textTheme.bodyMedium?.color,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        fontSize: 12,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 16),

            // Custom multiplier input
            Row(
              children: [
                const Text('Custom Speed: '),
                Expanded(
                  child: Slider(
                    value: _fastForward.speedMultiplier.clamp(1.0, 100.0),
                    min: 1.0,
                    max: 100.0,
                    divisions: 99,
                    label: '${_fastForward.speedMultiplier.toStringAsFixed(1)}x',
                    onChanged: (value) {
                      _fastForward.setSpeedMultiplier(value);
                    },
                    activeColor: Colors.orange,
                  ),
                ),
                Text('${_fastForward.speedMultiplier.toStringAsFixed(1)}x'),
              ],
            ),

            const SizedBox(height: 16),

            // Usage instructions
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Usage Instructions:',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '• Enable fast forward before starting a timer session\n'
                    '• Timer will run at accelerated speed for XP testing\n'
                    '• XP calculations remain accurate for intended session duration\n'
                    '• Use "Lightning" or "Time Warp" for instant session completion\n'
                    '• Remember to disable for normal productivity sessions',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.blue,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Quick action buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _fastForward.applyPreset('Very Fast (10x)'),
                    icon: const Icon(Icons.speed, size: 16),
                    label: const Text('Quick Test', style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _fastForward.reset(),
                    icon: const Icon(Icons.restore, size: 16),
                    label: const Text('Reset', style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
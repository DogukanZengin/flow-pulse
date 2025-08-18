import 'package:flutter/material.dart';
import 'dart:math';

class EquipmentIndicatorWidget extends StatefulWidget {
  final int userLevel;
  final List<String> unlockedEquipment;
  final bool showCertifications;

  const EquipmentIndicatorWidget({
    super.key,
    required this.userLevel,
    required this.unlockedEquipment,
    this.showCertifications = true,
  });

  @override
  State<EquipmentIndicatorWidget> createState() => _EquipmentIndicatorWidgetState();
}

class _EquipmentIndicatorWidgetState extends State<EquipmentIndicatorWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _certificationController;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
    
    _certificationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _certificationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.cyan.shade100.withValues(alpha: 0.8),
            Colors.blue.shade200.withValues(alpha: 0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.2),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          _buildEquipmentGrid(),
          if (widget.showCertifications) ...[
            const SizedBox(height: 16),
            _buildCertificationBadges(),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(
          Icons.build_circle,
          color: Colors.blue.shade700,
          size: 28,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Research Equipment',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade800,
                ),
              ),
              Text(
                'Level ${widget.userLevel} • ${widget.unlockedEquipment.length} items',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.blue.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEquipmentGrid() {
    final equipmentData = _getEquipmentData();
    
    return SizedBox(
      height: 200, // Constrain height to prevent overflow
      child: GridView.builder(
        shrinkWrap: true,
        physics: const AlwaysScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 1,
        ),
      itemCount: equipmentData.length,
      itemBuilder: (context, index) {
        final equipment = equipmentData[index];
        final isUnlocked = widget.userLevel >= equipment['requiredLevel'];
        
        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            final pulseValue = sin(_animationController.value * 2 * pi) * 0.1 + 1.0;
            
            return Transform.scale(
              scale: isUnlocked ? pulseValue : 1.0,
              child: Container(
                decoration: BoxDecoration(
                  color: isUnlocked 
                      ? equipment['color'].withValues(alpha: 0.8)
                      : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isUnlocked 
                        ? equipment['color']
                        : Colors.grey.shade400,
                    width: 2,
                  ),
                  boxShadow: isUnlocked
                      ? [
                          BoxShadow(
                            color: equipment['color'].withValues(alpha: 0.3),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      equipment['icon'],
                      size: 24,
                      color: isUnlocked 
                          ? Colors.white
                          : Colors.grey.shade600,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      equipment['name'],
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: isUnlocked 
                            ? Colors.white
                            : Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      ),
    );
  }

  Widget _buildCertificationBadges() {
    final certifications = _getCertificationData();
    final earnedCertifications = certifications
        .where((cert) => widget.userLevel >= cert['requiredLevel'])
        .toList();

    if (earnedCertifications.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.emoji_events_outlined, color: Colors.grey.shade500),
            const SizedBox(width: 8),
            Text(
              'No certifications earned yet',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Certifications',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade800,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: earnedCertifications.map((cert) {
            return AnimatedBuilder(
              animation: _certificationController,
              builder: (context, child) {
                final shimmerValue = _certificationController.value;
                
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        cert['color'],
                        cert['color'].withValues(alpha: 0.8),
                        cert['color'],
                      ],
                      stops: [0.0, shimmerValue, 1.0],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: cert['color'].withValues(alpha: 0.4),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        cert['icon'],
                        size: 16,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        cert['name'],
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  List<Map<String, dynamic>> _getEquipmentData() {
    return [
      // Basic Equipment (Levels 1-10)
      {
        'name': 'Mask\n& Snorkel',
        'icon': Icons.masks,
        'requiredLevel': 1,
        'color': Colors.cyan,
      },
      {
        'name': 'Diving\nFins',
        'icon': Icons.water_damage,
        'requiredLevel': 2,
        'color': Colors.blue,
      },
      {
        'name': 'Waterproof\nNotebook',
        'icon': Icons.book,
        'requiredLevel': 3,
        'color': Colors.green,
      },
      {
        'name': 'Basic\nCamera',
        'icon': Icons.camera_alt,
        'requiredLevel': 5,
        'color': Colors.orange,
      },

      // Intermediate Equipment (Levels 11-25)
      {
        'name': 'Scuba\nGear',
        'icon': Icons.air,
        'requiredLevel': 11,
        'color': Colors.purple,
      },
      {
        'name': 'Underwater\nLights',
        'icon': Icons.flashlight_on,
        'requiredLevel': 13,
        'color': Colors.yellow,
      },
      {
        'name': 'Digital\nCamera',
        'icon': Icons.camera_enhance,
        'requiredLevel': 15,
        'color': Colors.indigo,
      },
      {
        'name': 'Sample\nKit',
        'icon': Icons.science,
        'requiredLevel': 18,
        'color': Colors.teal,
      },

      // Advanced Equipment (Levels 26-50)
      {
        'name': 'Tech\nDiving Gear',
        'icon': Icons.precision_manufacturing,
        'requiredLevel': 26,
        'color': Colors.red,
      },
      {
        'name': 'Sonar\nSystem',
        'icon': Icons.radar,
        'requiredLevel': 30,
        'color': Colors.lime,
      },
      {
        'name': 'ROV\nCompanion',
        'icon': Icons.smart_toy,
        'requiredLevel': 35,
        'color': Colors.deepPurple,
      },
      {
        'name': 'Specimen\nLab',
        'icon': Icons.biotech,
        'requiredLevel': 40,
        'color': Colors.brown,
      },

      // Expert Equipment (Levels 51-75)
      {
        'name': 'Research\nSubmersible',
        'icon': Icons.directions_boat,
        'requiredLevel': 51,
        'color': Colors.deepOrange,
      },
      {
        'name': 'Genetic\nSequencer',
        'icon': Icons.psychology,
        'requiredLevel': 60,
        'color': Colors.pink,
      },
      {
        'name': 'Satellite\nComm',
        'icon': Icons.satellite_alt,
        'requiredLevel': 65,
        'color': Colors.lightBlue,
      },
      {
        'name': 'Breeding\nFacility',
        'icon': Icons.pets,
        'requiredLevel': 70,
        'color': Colors.lightGreen,
      },

      // Master Equipment (Levels 76-100)
      {
        'name': 'AI\nAssistant',
        'icon': Icons.psychology_alt,
        'requiredLevel': 76,
        'color': Colors.amber,
      },
      {
        'name': 'Holographic\nDisplay',
        'icon': Icons.view_in_ar,
        'requiredLevel': 85,
        'color': Colors.deepPurpleAccent,
      },
      {
        'name': 'Time-lapse\nCamera',
        'icon': Icons.timelapse,
        'requiredLevel': 90,
        'color': Colors.redAccent,
      },
      {
        'name': 'Quantum\nScanner',
        'icon': Icons.sensors,
        'requiredLevel': 95,
        'color': Colors.purpleAccent,
      },
    ];
  }

  List<Map<String, dynamic>> _getCertificationData() {
    return [
      {
        'name': 'Snorkel Certified',
        'icon': Icons.water,
        'requiredLevel': 10,
        'color': Colors.cyan,
      },
      {
        'name': 'Open Water Diver',
        'icon': Icons.scuba_diving,
        'requiredLevel': 25,
        'color': Colors.blue,
      },
      {
        'name': 'Advanced Open Water',
        'icon': Icons.water_drop,
        'requiredLevel': 50,
        'color': Colors.indigo,
      },
      {
        'name': 'Deep Water Research',
        'icon': Icons.waves,
        'requiredLevel': 75,
        'color': Colors.deepPurple,
      },
      {
        'name': 'Marine Biologist',
        'icon': Icons.biotech,
        'requiredLevel': 90,
        'color': Colors.green,
      },
      {
        'name': 'Ocean Explorer',
        'icon': Icons.explore,
        'requiredLevel': 100,
        'color': Colors.amber,
      },
    ];
  }
}
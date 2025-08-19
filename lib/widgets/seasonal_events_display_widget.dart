import 'package:flutter/material.dart';
import '../services/seasonal_events_service.dart';
import '../models/creature.dart'; // For BiomeType

/// Seasonal Events Display Widget - Phase 5 Implementation
/// Shows current seasonal events and their bonuses
class SeasonalEventsDisplayWidget extends StatefulWidget {
  final bool compactView;
  
  const SeasonalEventsDisplayWidget({
    super.key,
    this.compactView = false,
  });
  
  @override
  State<SeasonalEventsDisplayWidget> createState() => _SeasonalEventsDisplayWidgetState();
}

class _SeasonalEventsDisplayWidgetState extends State<SeasonalEventsDisplayWidget> {
  late List<SeasonalEvent> activeEvents;
  
  @override
  void initState() {
    super.initState();
    _refreshEvents();
  }
  
  void _refreshEvents() {
    setState(() {
      activeEvents = SeasonalEventsService.instance.getCurrentEvents();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    if (activeEvents.isEmpty) {
      return _buildNoEventsCard();
    }
    
    if (widget.compactView) {
      return _buildCompactView();
    }
    
    return _buildFullView();
  }
  
  Widget _buildNoEventsCard() {
    return Card(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.blue.shade800,
              Colors.blue.shade600,
              Colors.cyan.shade400,
            ],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.teal.shade400, Colors.cyan.shade300],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.calendar_today, size: 14, color: Colors.white),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'SEASONAL EVENTS',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, size: 16, color: Colors.white),
                  onPressed: _refreshEvents,
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Ocean waters are calm...\nNo special events at this time.',
              style: TextStyle(
                fontSize: 11,
                color: Colors.white70,
                height: 1.3,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCompactView() {
    final primaryEvent = activeEvents.first;
    
    return Card(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _getEventGradientColors(primaryEvent),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _getEventIcon(primaryEvent.iconName, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    primaryEvent.name,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                if (activeEvents.length > 1)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '+${activeEvents.length - 1}',
                      style: const TextStyle(fontSize: 10, color: Colors.white),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '${primaryEvent.discoveryMultiplier}x discovery bonus',
              style: const TextStyle(
                fontSize: 10,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFullView() {
    return Card(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.blue.shade800,
              Colors.blue.shade600,
              Colors.cyan.shade400,
            ],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.teal.shade400, Colors.cyan.shade300],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.event, size: 16, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'SEASONAL EVENTS',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Text(
                    '${activeEvents.length} Active',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.cyan.shade200,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.refresh, size: 18, color: Colors.white),
                    onPressed: _refreshEvents,
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
            
            // Events List
            ...activeEvents.map((event) => _buildEventCard(event)),
            
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
  
  Widget _buildEventCard(SeasonalEvent event) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _getEventGradientColors(event),
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event Header
            Row(
              children: [
                _getEventIcon(event.iconName),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.name,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        _getEventTypeDisplay(event.type),
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildRarityBadge(event.rarity),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Event Description
            Text(
              event.description,
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withValues(alpha: 0.9),
                height: 1.3,
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Bonuses Row
            Row(
              children: [
                Expanded(
                  child: _buildBonusChip(
                    '${event.discoveryMultiplier}x Discovery',
                    Icons.search,
                  ),
                ),
                if (event.specialEncounterBonus > 0)
                  const SizedBox(width: 8),
                if (event.specialEncounterBonus > 0)
                  Expanded(
                    child: _buildBonusChip(
                      '+${(event.specialEncounterBonus * 100).toInt()}% Special',
                      Icons.stars,
                    ),
                  ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Biomes and Time Remaining
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 4,
                    children: event.bonusBiomes.map((biome) => 
                      _buildBiomeChip(biome)).toList(),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _formatTimeRemaining(event.timeRemaining),
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.white60,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildRarityBadge(EventRarity rarity) {
    final color = _getRarityColor(rarity);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        rarity.name.toUpperCase(),
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
  
  Widget _buildBonusChip(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildBiomeChip(BiomeType biome) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        _getBiomeShortName(biome),
        style: const TextStyle(
          fontSize: 9,
          color: Colors.white70,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
  
  Widget _getEventIcon(String iconName, {double size = 16}) {
    IconData icon;
    
    switch (iconName) {
      case 'whale':
        icon = Icons.waves;
      case 'coral_spawning':
        icon = Icons.scatter_plot;
      case 'plankton':
        icon = Icons.bubble_chart;
      case 'shark':
        icon = Icons.timeline;
      case 'manta_ray':
        icon = Icons.flight;
      case 'abundance':
        icon = Icons.eco;
      case 'deep_sea':
        icon = Icons.water_drop;
      case 'bioluminescence':
        icon = Icons.lightbulb;
      case 'migration':
        icon = Icons.trending_up;
      case 'mystery':
        icon = Icons.help_outline;
      case 'conservation':
        icon = Icons.favorite;
      case 'celebration':
        icon = Icons.celebration;
      case 'special_expedition':
        icon = Icons.explore;
      case 'high_tide':
        icon = Icons.keyboard_arrow_up;
      case 'low_tide':
        icon = Icons.keyboard_arrow_down;
      default:
        icon = Icons.event;
    }
    
    return Icon(icon, size: size, color: Colors.white);
  }
  
  List<Color> _getEventGradientColors(SeasonalEvent event) {
    switch (event.rarity) {
      case EventRarity.common:
        return [Colors.green.shade700, Colors.green.shade500];
      case EventRarity.uncommon:
        return [Colors.blue.shade700, Colors.blue.shade500];
      case EventRarity.rare:
        return [Colors.purple.shade700, Colors.purple.shade500];
      case EventRarity.epic:
        return [Colors.orange.shade700, Colors.orange.shade500];
      case EventRarity.legendary:
        return [Colors.red.shade700, Colors.red.shade500];
    }
  }
  
  Color _getRarityColor(EventRarity rarity) {
    switch (rarity) {
      case EventRarity.common:
        return Colors.green.shade400;
      case EventRarity.uncommon:
        return Colors.blue.shade400;
      case EventRarity.rare:
        return Colors.purple.shade400;
      case EventRarity.epic:
        return Colors.orange.shade400;
      case EventRarity.legendary:
        return Colors.red.shade400;
    }
  }
  
  String _getEventTypeDisplay(SeasonalEventType type) {
    switch (type) {
      case SeasonalEventType.migration:
        return 'Migration Event';
      case SeasonalEventType.breeding:
        return 'Breeding Season';
      case SeasonalEventType.bloom:
        return 'Plankton Bloom';
      case SeasonalEventType.predatorActivity:
        return 'Predator Activity';
      case SeasonalEventType.gathering:
        return 'Species Gathering';
      case SeasonalEventType.abundance:
        return 'Marine Abundance';
      case SeasonalEventType.exploration:
        return 'Research Expedition';
      case SeasonalEventType.bioluminescence:
        return 'Bioluminescent Display';
      case SeasonalEventType.mystery:
        return 'Mysterious Event';
      case SeasonalEventType.conservation:
        return 'Conservation Focus';
      case SeasonalEventType.celebration:
        return 'Seasonal Celebration';
      case SeasonalEventType.specialEncounter:
        return 'Special Encounter';
      case SeasonalEventType.tidal:
        return 'Tidal Event';
    }
  }
  
  String _getBiomeShortName(BiomeType biome) {
    switch (biome) {
      case BiomeType.shallowWaters:
        return 'Shallow';
      case BiomeType.coralGarden:
        return 'Coral';
      case BiomeType.deepOcean:
        return 'Deep';
      case BiomeType.abyssalZone:
        return 'Abyss';
    }
  }
  
  String _formatTimeRemaining(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}d left';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h left';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m left';
    } else {
      return 'Ending soon';
    }
  }
}
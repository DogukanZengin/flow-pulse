import 'package:flutter/material.dart';
import '../services/equipment_progression_service.dart';

/// Enhanced Equipment Display Widget for Phase 4
/// Shows comprehensive equipment progression with categories and bonuses
class EnhancedEquipmentDisplayWidget extends StatelessWidget {
  final List<ResearchEquipment> equipment;
  final EquipmentBonuses bonuses;
  final Function(ResearchEquipment)? onEquipmentTap;
  final bool showCompact;
  
  const EnhancedEquipmentDisplayWidget({
    super.key,
    required this.equipment,
    required this.bonuses,
    this.onEquipmentTap,
    this.showCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (showCompact) {
      return _buildCompactView();
    }
    
    return Column(
      children: [
        _buildEquipmentSummary(),
        const SizedBox(height: 16),
        _buildCategoryTabs(),
      ],
    );
  }
  
  Widget _buildCompactView() {
    final unlockedEquipment = equipment.where((e) => e.isUnlocked).toList();
    
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: unlockedEquipment.take(8).length, // Show max 8 in compact
        itemBuilder: (context, index) {
          final eq = unlockedEquipment[index];
          return _buildCompactEquipmentCard(eq);
        },
      ),
    );
  }
  
  Widget _buildEquipmentSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1E3A5F), // Deep Ocean Blue
            Color(0xFF2E5A7A), // Ocean Research Blue
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.cyan.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.construction, color: Colors.amber, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Research Equipment',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              Text(
                '${bonuses.equippedCount}/${bonuses.availableCount}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: bonuses.equippedPercentage,
            backgroundColor: Colors.grey.withValues(alpha: 0.3),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.cyan),
            borderRadius: BorderRadius.circular(3),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildBonusChip(
                  '+${(bonuses.discoveryRateBonus * 100).toInt()}%',
                  'Discovery Rate',
                  Icons.search,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildBonusChip(
                  '+${(bonuses.sessionXPBonus * 100).toInt()}%',
                  'Session XP',
                  Icons.trending_up,
                  Colors.purple,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildBonusChip(
                  '${(bonuses.completionPercentage * 100).toInt()}%',
                  'Unlocked',
                  Icons.lock_open,
                  Colors.amber,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildBonusChip(String value, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              color: color.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCategoryTabs() {
    // Group equipment by category
    final groupedEquipment = <EquipmentCategory, List<ResearchEquipment>>{};
    for (final eq in equipment) {
      groupedEquipment.putIfAbsent(eq.category, () => []).add(eq);
    }
    
    // Only show categories that have equipment
    final categories = groupedEquipment.keys.toList();
    
    return DefaultTabController(
      length: categories.length,
      child: Column(
        children: [
          TabBar(
            isScrollable: true,
            indicatorColor: Colors.cyan,
            labelColor: Colors.cyan,
            unselectedLabelColor: Colors.grey,
            tabs: categories.map((category) => Tab(
              text: category.displayName,
              icon: Icon(_getCategoryIcon(category), size: 16),
            )).toList(),
          ),
          SizedBox(
            height: 400, // Fixed height for tab content
            child: TabBarView(
              children: categories.map((category) => 
                _buildCategoryContent(groupedEquipment[category]!)
              ).toList(),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCategoryContent(List<ResearchEquipment> categoryEquipment) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        shrinkWrap: true,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.8,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: categoryEquipment.length,
        itemBuilder: (context, index) {
          final eq = categoryEquipment[index];
          return _buildEquipmentCard(eq);
        },
      ),
    );
  }
  
  Widget _buildEquipmentCard(ResearchEquipment equipment) {
    return GestureDetector(
      onTap: () => onEquipmentTap?.call(equipment),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: equipment.isUnlocked 
                ? [
                    equipment.rarityColor.withValues(alpha: 0.3),
                    equipment.rarityColor.withValues(alpha: 0.1),
                  ]
                : [
                    Colors.grey.withValues(alpha: 0.2),
                    Colors.grey.withValues(alpha: 0.05),
                  ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: equipment.isUnlocked 
                ? equipment.rarityColor.withValues(alpha: 0.5)
                : Colors.grey.withValues(alpha: 0.3),
            width: equipment.isEquipped ? 3 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: equipment.isUnlocked 
                        ? equipment.rarityColor.withValues(alpha: 0.2)
                        : Colors.grey.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    equipment.icon,
                    style: TextStyle(
                      fontSize: 20,
                      color: equipment.isUnlocked ? null : Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        equipment.name,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: equipment.isUnlocked ? Colors.white : Colors.grey,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (equipment.isEquipped)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: const Text(
                            'EQUIPPED',
                            style: TextStyle(
                              fontSize: 8,
                              color: Colors.green,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              equipment.description,
              style: TextStyle(
                fontSize: 10,
                color: equipment.isUnlocked 
                    ? Colors.white.withValues(alpha: 0.8)
                    : Colors.grey,
                height: 1.2,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            if (equipment.isUnlocked) ...[
              Row(
                children: [
                  if (equipment.discoveryBonus > 0)
                    _buildStatChip(
                      '+${(equipment.discoveryBonus * 100).toInt()}%',
                      'Discovery',
                      Colors.green,
                    ),
                  if (equipment.sessionBonus > 0) ...[
                    if (equipment.discoveryBonus > 0) const SizedBox(width: 4),
                    _buildStatChip(
                      '+${(equipment.sessionBonus * 100).toInt()}%',
                      'XP',
                      Colors.purple,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: equipment.rarityColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  equipment.rarity.displayName,
                  style: TextStyle(
                    fontSize: 8,
                    color: equipment.rarityColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.lock, size: 12, color: Colors.orange),
                        const SizedBox(width: 4),
                        Text(
                          'Level ${equipment.unlockLevel}',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.orange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    if (equipment.requiredDiscoveries > 0) ...[
                      const SizedBox(height: 2),
                      Text(
                        '${equipment.requiredDiscoveries} discoveries',
                        style: TextStyle(
                          fontSize: 9,
                          color: Colors.orange.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatChip(String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        '$value $label',
        style: TextStyle(
          fontSize: 8,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
  
  Widget _buildCompactEquipmentCard(ResearchEquipment equipment) {
    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: equipment.isUnlocked 
              ? [
                  equipment.rarityColor.withValues(alpha: 0.3),
                  equipment.rarityColor.withValues(alpha: 0.1),
                ]
              : [
                  Colors.grey.withValues(alpha: 0.3),
                  Colors.grey.withValues(alpha: 0.1),
                ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: equipment.isUnlocked 
              ? equipment.rarityColor
              : Colors.grey.withValues(alpha: 0.5),
          width: equipment.isEquipped ? 3 : 2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: equipment.isUnlocked 
                  ? equipment.rarityColor.withValues(alpha: 0.2)
                  : Colors.grey.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              equipment.icon,
              style: TextStyle(
                fontSize: 20,
                color: equipment.isUnlocked ? null : Colors.grey,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            equipment.name,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: equipment.isUnlocked ? Colors.white : Colors.grey,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          if (equipment.isEquipped) ...[
            const SizedBox(height: 2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
              child: const Text(
                'ON',
                style: TextStyle(
                  fontSize: 7,
                  color: Colors.green,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ] else if (!equipment.isUnlocked) ...[
            const SizedBox(height: 2),
            Text(
              'Lv${equipment.unlockLevel}',
              style: TextStyle(
                fontSize: 8,
                color: Colors.orange.withValues(alpha: 0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  IconData _getCategoryIcon(EquipmentCategory category) {
    switch (category) {
      case EquipmentCategory.breathing:
        return Icons.air;
      case EquipmentCategory.mobility:
        return Icons.directions_run;
      case EquipmentCategory.documentation:
        return Icons.camera_alt;
      case EquipmentCategory.visibility:
        return Icons.visibility;
      case EquipmentCategory.safety:
        return Icons.security;
      case EquipmentCategory.sampling:
        return Icons.science;
      case EquipmentCategory.detection:
        return Icons.radar;
      case EquipmentCategory.analysis:
        return Icons.biotech;
      case EquipmentCategory.platform:
        return Icons.directions_boat;
      case EquipmentCategory.communication:
        return Icons.wifi;
      case EquipmentCategory.conservation:
        return Icons.eco;
      case EquipmentCategory.visualization:
        return Icons.view_in_ar;
    }
  }
}

/// Equipment Details Dialog
class EquipmentDetailsDialog extends StatelessWidget {
  final ResearchEquipment equipment;
  
  const EquipmentDetailsDialog({
    super.key,
    required this.equipment,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: equipment.isUnlocked 
                ? [
                    equipment.rarityColor.withValues(alpha: 0.3),
                    equipment.rarityColor.withValues(alpha: 0.1),
                  ]
                : [
                    Colors.grey.withValues(alpha: 0.3),
                    Colors.grey.withValues(alpha: 0.1),
                  ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: equipment.isUnlocked 
                ? equipment.rarityColor.withValues(alpha: 0.5)
                : Colors.grey.withValues(alpha: 0.5),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: equipment.isUnlocked 
                        ? equipment.rarityColor.withValues(alpha: 0.2)
                        : Colors.grey.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    equipment.icon,
                    style: const TextStyle(fontSize: 32),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        equipment.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        equipment.category.displayName,
                        style: TextStyle(
                          fontSize: 14,
                          color: equipment.categoryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: equipment.rarityColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          equipment.rarity.displayName,
                          style: TextStyle(
                            fontSize: 10,
                            color: equipment.rarityColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              equipment.description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.9),
                height: 1.4,
              ),
            ),
            if (equipment.isUnlocked) ...[
              const SizedBox(height: 16),
              Text(
                'Benefits:',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              ...equipment.benefits.map((benefit) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '• ',
                      style: TextStyle(
                        color: equipment.rarityColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        benefit,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                  ],
                ),
              )),
            ] else ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.lock, color: Colors.orange, size: 16),
                        const SizedBox(width: 8),
                        const Text(
                          'Unlock Requirements:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      equipment.unlockCondition,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
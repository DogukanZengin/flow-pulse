import 'package:flutter/material.dart';
import '../services/equipment_progression_service.dart';
import '../utils/responsive_helper.dart';

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
        _buildEquipmentSummary(context),
        SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 'card')),
        _buildCategoryTabs(context),
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
  
  Widget _buildEquipmentSummary(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(ResponsiveHelper.getResponsiveSpacing(context, 'card')),
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
                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'body'),
                  color: Colors.white.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 'navigation')),
          LinearProgressIndicator(
            value: bonuses.equippedPercentage,
            backgroundColor: Colors.grey.withValues(alpha: 0.3),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.cyan),
            borderRadius: BorderRadius.circular(3),
          ),
          SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 'navigation')),
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
              SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, 'navigation')),
              Expanded(
                child: _buildBonusChip(
                  '+${(bonuses.sessionXPBonus * 100).toInt()}%',
                  'Session XP',
                  Icons.trending_up,
                  Colors.purple,
                ),
              ),
              SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, 'navigation')),
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
  
  Widget _buildCategoryTabs(BuildContext context) {
    // Group equipment by category
    final groupedEquipment = <EquipmentCategory, List<ResearchEquipment>>{};
    for (final eq in equipment) {
      groupedEquipment.putIfAbsent(eq.category, () => []).add(eq);
    }
    
    // Only show categories that have equipment
    final categories = groupedEquipment.keys.toList();
    
    return _MobileEquipmentCategoryView(
      groupedEquipment: groupedEquipment,
      categories: categories,
      onEquipmentTap: onEquipmentTap,
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

/// Mobile-friendly Equipment Category View
class _MobileEquipmentCategoryView extends StatefulWidget {
  final Map<EquipmentCategory, List<ResearchEquipment>> groupedEquipment;
  final List<EquipmentCategory> categories;
  final Function(ResearchEquipment)? onEquipmentTap;

  const _MobileEquipmentCategoryView({
    required this.groupedEquipment,
    required this.categories,
    this.onEquipmentTap,
  });

  @override
  State<_MobileEquipmentCategoryView> createState() => _MobileEquipmentCategoryViewState();
}

class _MobileEquipmentCategoryViewState extends State<_MobileEquipmentCategoryView> {
  String? expandedCategory;
  
  @override
  void initState() {
    super.initState();
    // Expand the first category by default if it has equipment
    if (widget.categories.isNotEmpty) {
      expandedCategory = widget.categories.first.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: widget.categories.map((category) {
        final categoryEquipment = widget.groupedEquipment[category]!;
        final isExpanded = expandedCategory == category.toString();
        final unlockedCount = categoryEquipment.where((e) => e.isUnlocked).length;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _getCategoryColor(category).withValues(alpha: 0.1),
                _getCategoryColor(category).withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _getCategoryColor(category).withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              // Category Header (Always Visible)
              InkWell(
                onTap: () {
                  setState(() {
                    expandedCategory = isExpanded ? null : category.toString();
                  });
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _getCategoryColor(category).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _getCategoryIcon(category),
                          color: _getCategoryColor(category),
                          size: 20,
                        ),
                      ),
                      SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, 'navigation')),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              category.displayName,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              '$unlockedCount/${categoryEquipment.length} unlocked',
                              style: TextStyle(
                                fontSize: 12,
                                color: _getCategoryColor(category),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Progress indicator
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: Stack(
                          children: [
                            Center(
                              child: SizedBox(
                                width: 32,
                                height: 32,
                                child: CircularProgressIndicator(
                                  value: unlockedCount / categoryEquipment.length,
                                  strokeWidth: 3,
                                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                                  valueColor: AlwaysStoppedAnimation(_getCategoryColor(category)),
                                ),
                              ),
                            ),
                            Center(
                              child: Text(
                                '$unlockedCount',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: _getCategoryColor(category),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        isExpanded ? Icons.expand_less : Icons.expand_more,
                        color: Colors.white60,
                        size: 24,
                      ),
                    ],
                  ),
                ),
              ),
              
              // Equipment Grid (Expandable)
              if (isExpanded) ...[
                const Divider(
                  color: Colors.white12,
                  height: 1,
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: _buildMobileEquipmentGrid(categoryEquipment),
                ),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }
  
  Widget _buildMobileEquipmentGrid(List<ResearchEquipment> categoryEquipment) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: MediaQuery.of(context).size.width < 400 ? 2 : 3,
        childAspectRatio: 0.75,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: categoryEquipment.length,
      itemBuilder: (context, index) {
        final equipment = categoryEquipment[index];
        return _buildMobileEquipmentCard(equipment);
      },
    );
  }
  
  Widget _buildMobileEquipmentCard(ResearchEquipment equipment) {
    return GestureDetector(
      onTap: equipment.isUnlocked ? () => widget.onEquipmentTap?.call(equipment) : null,
      child: Container(
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
                    Colors.grey.shade700.withValues(alpha: 0.4),
                    Colors.grey.shade800.withValues(alpha: 0.6),
                  ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: equipment.isUnlocked 
                ? equipment.rarityColor.withValues(alpha: 0.5)
                : Colors.grey.shade500.withValues(alpha: 0.6),
            width: equipment.isEquipped ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (equipment.isUnlocked) ...[
              // Revealed Equipment
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: equipment.rarityColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  equipment.icon,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
              
              const SizedBox(height: 8),
              
              Text(
                equipment.name,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 4),
              
              Text(
                'Level ${equipment.unlockLevel}',
                style: TextStyle(
                  fontSize: 9,
                  color: equipment.rarityColor,
                ),
              ),
              
              if (equipment.isEquipped)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'EQUIPPED',
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ),
            ] else ...[
              // Mystery Equipment
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade600.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.help_outline,
                  size: 24,
                  color: Colors.grey.shade300,
                ),
              ),
              
              const SizedBox(height: 8),
              
              const SizedBox(height: 4),
              
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.orange.withValues(alpha: 0.5),
                    width: 1,
                  ),
                ),
                child: Text(
                  'Unlock at Lv${equipment.unlockLevel}',
                  style: TextStyle(
                    fontSize: 8,
                    color: Colors.orange.shade300,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Color _getCategoryColor(EquipmentCategory category) {
    switch (category) {
      case EquipmentCategory.breathing:
        return Colors.cyan;
      case EquipmentCategory.mobility:
        return Colors.green;
      case EquipmentCategory.documentation:
        return Colors.orange;
      case EquipmentCategory.visibility:
        return Colors.yellow;
      case EquipmentCategory.safety:
        return Colors.red;
      case EquipmentCategory.sampling:
        return Colors.purple;
      case EquipmentCategory.detection:
        return Colors.pink;
      case EquipmentCategory.analysis:
        return Colors.indigo;
      case EquipmentCategory.platform:
        return Colors.brown;
      case EquipmentCategory.communication:
        return Colors.teal;
      case EquipmentCategory.conservation:
        return Colors.lightGreen;
      case EquipmentCategory.visualization:
        return Colors.deepOrange;
    }
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
        return Icons.flashlight_on;
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
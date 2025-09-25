import 'package:flutter/material.dart';
import '../models/expedition_result.dart';
import '../models/achievement_hierarchy.dart' as hierarchy;
import '../utils/surfacing_celebration_colors.dart';
import '../../../utils/responsive_helper.dart';
import '../components/progress_indicator_widget.dart';
import '../components/comparison_metrics.dart';
import '../utils/progress_calculations.dart';

/// Unified dashboard page that replaces the sequential page flow
/// with a single responsive interface showing all achievements.
///
/// Implements the "Surfacing into Success" design concept with
/// bright, refreshing celebration colors that prepare users for break sessions.
class UnifiedDashboardPage extends StatefulWidget {
  final ExpeditionResult expeditionResult;
  final AnimationController animationController;
  final hierarchy.AchievementClassification? achievementHierarchy;

  const UnifiedDashboardPage({
    super.key,
    required this.expeditionResult,
    required this.animationController,
    this.achievementHierarchy,
  });

  @override
  State<UnifiedDashboardPage> createState() => _UnifiedDashboardPageState();
}

class _UnifiedDashboardPageState extends State<UnifiedDashboardPage>
    with TickerProviderStateMixin {

  late Animation<double> _fadeAnimation;
  AnimationController? _staggerController;
  late List<Animation<double>> _cardAnimations;

  // Track expanded state of each section
  final Map<DashboardSection, bool> _expandedSections = {
    DashboardSection.session: false,
    DashboardSection.career: false,
    DashboardSection.species: false,
    DashboardSection.equipment: false,
  };

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_staggerController == null) {
      _initializeAnimations();
      _startSurfacingAnimation();
    }
  }

  void _initializeAnimations() {
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: widget.animationController,
      curve: Curves.easeInOut,
    ));

    // Staggered animation controller for card reveals
    _staggerController = AnimationController(
      duration: ResponsiveHelper.responsiveValue(
        context: context,
        mobile: const Duration(milliseconds: 800),
        tablet: const Duration(milliseconds: 1000),
        desktop: const Duration(milliseconds: 1200),
      ),
      vsync: this,
    );

    // Create staggered animations for each card
    _cardAnimations = List.generate(4, (index) {
      final start = index * 0.2;
      final end = start + 0.8;

      return Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _staggerController!,
        curve: Interval(start, end.clamp(0.0, 1.0), curve: Curves.easeOutBack),
      ));
    });
  }

  void _startSurfacingAnimation() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _staggerController?.forward();
      }
    });
  }

  @override
  void dispose() {
    _staggerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: SurfacingCelebrationColors.getResponsiveSurfacingGradient(context),
      ),
      child: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnimation.value,
            child: _buildDashboardContent(),
          );
        },
      ),
    );
  }

  Widget _buildDashboardContent() {
    return ResponsiveHelper.responsiveBuilder(
      context: context,
      mobile: _buildMobileLayout(),
      tablet: _buildTabletLayout(),
      desktop: _buildDesktopLayout(),
      wideDesktop: _buildWideDesktopLayout(),
    );
  }

  /// Mobile layout: Single column with expandable cards
  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(
        ResponsiveHelper.getResponsiveSpacing(context, 'page_padding'),
      ),
      child: Column(
        children: [
          _buildSurfacingHeader(),
          SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 'section_spacing')),
          ...DashboardSection.values.asMap().entries.map((entry) {
            final index = entry.key;
            final section = entry.value;
            return AnimatedBuilder(
              animation: _cardAnimations[index],
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, 50 * (1 - _cardAnimations[index].value)),
                  child: Opacity(
                    opacity: _cardAnimations[index].value.clamp(0.0, 1.0),
                    child: Padding(
                      padding: EdgeInsets.only(
                        bottom: ResponsiveHelper.getResponsiveSpacing(context, 'card_spacing'),
                      ),
                      child: _buildAchievementCard(section, isExpanded: false),
                    ),
                  ),
                );
              },
            );
          }),
          // Comparison metrics for mobile
          Padding(
            padding: EdgeInsets.only(
              bottom: ResponsiveHelper.getResponsiveSpacing(context, 'card_spacing'),
            ),
            child: ComparisonMetrics(
              expeditionResult: widget.expeditionResult,
              showDetailedMetrics: false,
            ),
          ),
          _buildBreakTransitionPreview(),
        ],
      ),
    );
  }

  /// Tablet layout: 2x2 grid
  Widget _buildTabletLayout() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(
        ResponsiveHelper.getResponsiveSpacing(context, 'page_padding'),
      ),
      child: Column(
        children: [
          _buildSurfacingHeader(),
          SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 'section_spacing')),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: ResponsiveHelper.getResponsiveSpacing(context, 'card_spacing'),
              mainAxisSpacing: ResponsiveHelper.getResponsiveSpacing(context, 'card_spacing'),
              childAspectRatio: ResponsiveHelper.getGridAspectRatio(context),
            ),
            itemCount: DashboardSection.values.length,
            itemBuilder: (context, index) {
              return AnimatedBuilder(
                animation: _cardAnimations[index],
                builder: (context, child) {
                  return Transform.scale(
                    scale: _cardAnimations[index].value.clamp(0.0, 1.2),
                    child: Opacity(
                      opacity: _cardAnimations[index].value.clamp(0.0, 1.0),
                      child: _buildAchievementCard(DashboardSection.values[index]),
                    ),
                  );
                },
              );
            },
          ),
          SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 'section_spacing')),
          // Comparison metrics for tablet
          ComparisonMetrics(
            expeditionResult: widget.expeditionResult,
            showDetailedMetrics: false,
          ),
          SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 'section_spacing')),
          _buildBreakTransitionPreview(),
        ],
      ),
    );
  }

  /// Desktop layout: 3-column layout
  Widget _buildDesktopLayout() {
    return Padding(
      padding: EdgeInsets.all(
        ResponsiveHelper.getResponsiveSpacing(context, 'page_padding'),
      ),
      child: Column(
        children: [
          _buildSurfacingHeader(),
          SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 'section_spacing')),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Main achievement area (2/3 width)
                Expanded(
                  flex: 2,
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: ResponsiveHelper.getResponsiveSpacing(context, 'card_spacing'),
                      mainAxisSpacing: ResponsiveHelper.getResponsiveSpacing(context, 'card_spacing'),
                      childAspectRatio: ResponsiveHelper.getGridAspectRatio(context),
                    ),
                    itemCount: DashboardSection.values.length,
                    itemBuilder: (context, index) {
                      return AnimatedBuilder(
                        animation: _cardAnimations[index],
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(
                              100 * (1 - _cardAnimations[index].value) * (index.isEven ? -1 : 1),
                              0,
                            ),
                            child: Opacity(
                              opacity: _cardAnimations[index].value.clamp(0.0, 1.0),
                              child: _buildAchievementCard(DashboardSection.values[index]),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, 'section_spacing')),
                // Sidebar (1/3 width)
                Expanded(
                  flex: 1,
                  child: _buildDesktopSidebar(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Wide desktop layout: 4-column layout with rich sidebar
  Widget _buildWideDesktopLayout() {
    return Padding(
      padding: EdgeInsets.all(
        ResponsiveHelper.getResponsiveSpacing(context, 'page_padding'),
      ),
      child: Column(
        children: [
          _buildSurfacingHeader(),
          SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 'section_spacing')),
          Expanded(
            child: Row(
              children: [
                // Main achievement grid (3/4 width)
                Expanded(
                  flex: 3,
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: ResponsiveHelper.getResponsiveSpacing(context, 'card_spacing'),
                      mainAxisSpacing: ResponsiveHelper.getResponsiveSpacing(context, 'card_spacing'),
                      childAspectRatio: ResponsiveHelper.getGridAspectRatio(context),
                    ),
                    itemCount: DashboardSection.values.length,
                    itemBuilder: (context, index) {
                      return AnimatedBuilder(
                        animation: _cardAnimations[index],
                        builder: (context, child) {
                          // Radial reveal animation from center
                          final centerX = index % 2 == 0 ? -1.0 : 1.0;
                          final centerY = index < 2 ? -1.0 : 1.0;

                          return Transform.translate(
                            offset: Offset(
                              50 * centerX * (1 - _cardAnimations[index].value),
                              50 * centerY * (1 - _cardAnimations[index].value),
                            ),
                            child: Opacity(
                              opacity: _cardAnimations[index].value.clamp(0.0, 1.0),
                              child: _buildAchievementCard(DashboardSection.values[index]),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, 'section_spacing')),
                // Rich sidebar (1/4 width)
                Expanded(
                  flex: 1,
                  child: _buildWideDesktopSidebar(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSurfacingHeader() {
    return Container(
      padding: EdgeInsets.all(
        ResponsiveHelper.getResponsiveSpacing(context, 'header_padding'),
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF001B3D),
            const Color(0xFF0077BE),
            const Color(0xFF87CEEB),
          ],
        ),
        borderRadius: BorderRadius.circular(
          ResponsiveHelper.responsiveValue(
            context: context,
            mobile: 16.0,
            tablet: 20.0,
            desktop: 24.0,
          ),
        ),
        border: Border.all(
          color: SurfacingCelebrationColors.getCelebrationAccentColor(null),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.keyboard_arrow_up,
                color: SurfacingCelebrationColors.getCelebrationTextColor(context),
                size: ResponsiveHelper.getIconSize(context, 'large'),
              ),
              SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, 'icon_spacing')),
              Text(
                'SURFACING COMPLETE',
                style: TextStyle(
                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'header'),
                  fontWeight: FontWeight.bold,
                  color: SurfacingCelebrationColors.getCelebrationTextColor(context),
                  shadows: SurfacingCelebrationColors.getCelebrationTextShadows(context),
                  letterSpacing: 1.2,
                ),
              ),
              SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, 'icon_spacing')),
              Icon(
                Icons.keyboard_arrow_up,
                color: SurfacingCelebrationColors.getCelebrationTextColor(context),
                size: ResponsiveHelper.getIconSize(context, 'large'),
              ),
            ],
          ),
          SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 'text_spacing')),
          Text(
            'Research expedition achievements unlocked',
            style: TextStyle(
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'subtitle'),
              color: SurfacingCelebrationColors.getCelebrationSecondaryTextColor(context),
              shadows: SurfacingCelebrationColors.getCelebrationTextShadows(context),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementCard(DashboardSection section, {bool isExpanded = false}) {
    return Container(
      decoration: SurfacingCelebrationColors.getCelebrationCardDecoration(
        context,
        _getAchievementTypeForSection(section),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _toggleSection(section),
          borderRadius: BorderRadius.circular(
            ResponsiveHelper.responsiveValue(
              context: context,
              mobile: 12.0,
              tablet: 16.0,
              desktop: 20.0,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(
              ResponsiveHelper.getResponsiveSpacing(context, 'card_padding'),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCardHeader(section),
                SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 'content_spacing')),
                if (isExpanded || _expandedSections[section] == true)
                  _buildCardContent(section)
                else
                  _buildCardSummary(section),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardHeader(DashboardSection section) {
    final icon = _getIconForSection(section);
    final title = _getTitleForSection(section);
    final achievementType = _getAchievementTypeForSection(section);

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: SurfacingCelebrationColors.getCelebrationAccentColor(achievementType)
                .withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: SurfacingCelebrationColors.getCelebrationAccentColor(achievementType),
            size: ResponsiveHelper.getIconSize(context, 'medium'),
          ),
        ),
        SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, 'icon_spacing')),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'card_title'),
              fontWeight: FontWeight.bold,
              color: SurfacingCelebrationColors.getCelebrationTextColor(context),
              shadows: SurfacingCelebrationColors.getCelebrationTextShadows(context),
            ),
          ),
        ),
        Icon(
          _expandedSections[section] == true
              ? Icons.expand_less
              : Icons.expand_more,
          color: SurfacingCelebrationColors.getCelebrationSecondaryTextColor(context),
        ),
      ],
    );
  }

  Widget _buildCardSummary(DashboardSection section) {
    final summary = _getSummaryForSection(section);
    return Text(
      summary,
      style: TextStyle(
        fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'card_summary'),
        color: SurfacingCelebrationColors.getCelebrationSecondaryTextColor(context),
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildCardContent(DashboardSection section) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Add progress indicators based on section type
          if (section == DashboardSection.session) ..._buildSessionContent(),
          if (section == DashboardSection.career) ..._buildCareerContent(),
          if (section == DashboardSection.species) ..._buildSpeciesContent(),
          if (section == DashboardSection.equipment) ..._buildEquipmentContent(),
        ],
      ),
    );
  }

  List<Widget> _buildSessionContent() {
    return [
      // Session details placeholder
      Text(
        'Session Duration: ${widget.expeditionResult.sessionDurationMinutes} minutes',
        style: TextStyle(
          fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'body'),
          color: SurfacingCelebrationColors.getCelebrationTextColor(context),
        ),
      ),
      SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 'content_spacing')),
      Text(
        'RP Gained: ${widget.expeditionResult.rpGained} (${widget.expeditionResult.rpBreakdown})',
        style: TextStyle(
          fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'body'),
          color: SurfacingCelebrationColors.getCelebrationTextColor(context),
        ),
      ),
      SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 'section_spacing')),
      // Progress to next level
      ProgressIndicatorWidget(
        currentProgress: widget.expeditionResult.cumulativeRP.toDouble(),
        totalRequired: (widget.expeditionResult.cumulativeRP + widget.expeditionResult.rpToNextLevel).toDouble(),
        progressType: 'level',
        accentColor: SurfacingCelebrationColors.surfacingGradient[2],
        nextMilestone: 'Level ${widget.expeditionResult.newLevel + 1}',
        rpToNext: widget.expeditionResult.rpToNextLevel,
        showMilestonePreview: true,
      ),
      SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 'content_spacing')),
      // Depth zone progress
      ProgressIndicatorWidget(
        currentProgress: widget.expeditionResult.cumulativeRP.toDouble(),
        totalRequired: (widget.expeditionResult.cumulativeRP + widget.expeditionResult.rpToNextDepthZone).toDouble(),
        progressType: 'depth zone',
        accentColor: SurfacingCelebrationColors.surfacingGradient[1],
        nextMilestone: widget.expeditionResult.nextDepthZone,
        rpToNext: widget.expeditionResult.rpToNextDepthZone,
        showMilestonePreview: widget.expeditionResult.nextDepthZone != null,
      ),
    ];
  }

  List<Widget> _buildCareerContent() {
    return [
      // Career details
      Text(
        'Current Title: ${widget.expeditionResult.newCareerTitle ?? "Student Researcher"}',
        style: TextStyle(
          fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'subtitle'),
          fontWeight: FontWeight.bold,
          color: SurfacingCelebrationColors.getCelebrationTextColor(context),
        ),
      ),
      if (widget.expeditionResult.careerTitleChanged) ...[
        SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 'small_spacing')),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: SurfacingCelebrationColors.getCelebrationAccentColor(AchievementType.careerAdvancement)
                .withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Promoted from ${widget.expeditionResult.oldCareerTitle}!',
            style: TextStyle(
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'body'),
              color: SurfacingCelebrationColors.getCelebrationAccentColor(AchievementType.careerAdvancement),
            ),
          ),
        ),
      ],
      SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 'section_spacing')),
      // Career progression
      ProgressIndicatorWidget(
        currentProgress: widget.expeditionResult.cumulativeRP.toDouble(),
        totalRequired: (widget.expeditionResult.cumulativeRP + widget.expeditionResult.rpToNextCareer).toDouble(),
        progressType: 'promotion',
        accentColor: SurfacingCelebrationColors.getCelebrationAccentColor(AchievementType.careerAdvancement),
        nextMilestone: widget.expeditionResult.nextCareerTitle,
        rpToNext: widget.expeditionResult.rpToNextCareer,
        showMilestonePreview: widget.expeditionResult.nextCareerTitle != null,
      ),
    ];
  }

  List<Widget> _buildSpeciesContent() {
    final hasDiscovery = widget.expeditionResult.discoveredCreature != null;
    return [
      if (hasDiscovery) ...[
        Text(
          'New Discovery!',
          style: TextStyle(
            fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'subtitle'),
            fontWeight: FontWeight.bold,
            color: SurfacingCelebrationColors.getCelebrationAccentColor(AchievementType.speciesDiscovery),
          ),
        ),
        SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 'small_spacing')),
        // Placeholder for creature details
        Text(
          'Discovered a new species in the ${widget.expeditionResult.currentDepthZone}',
          style: TextStyle(
            fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'body'),
            color: SurfacingCelebrationColors.getCelebrationTextColor(context),
          ),
        ),
      ] else ...[
        Text(
          'No new species discovered this session',
          style: TextStyle(
            fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'body'),
            color: SurfacingCelebrationColors.getCelebrationSecondaryTextColor(context),
          ),
        ),
      ],
      SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 'section_spacing')),
      // Collection progress
      ProgressIndicatorWidget(
        currentProgress: widget.expeditionResult.allDiscoveredCreatures.length.toDouble(),
        totalRequired: (widget.expeditionResult.allDiscoveredCreatures.length +
                       widget.expeditionResult.speciesLeftToDiscover).toDouble(),
        progressType: 'collection',
        accentColor: SurfacingCelebrationColors.getCelebrationAccentColor(AchievementType.speciesDiscovery),
        nextMilestone: '${widget.expeditionResult.speciesLeftToDiscover} species remaining',
        showMilestonePreview: true,
      ),
    ];
  }

  List<Widget> _buildEquipmentContent() {
    return [
      if (widget.expeditionResult.unlockedEquipment.isNotEmpty) ...[
        Text(
          'Equipment Unlocked:',
          style: TextStyle(
            fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'subtitle'),
            fontWeight: FontWeight.bold,
            color: SurfacingCelebrationColors.getCelebrationTextColor(context),
          ),
        ),
        SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 'small_spacing')),
        ...widget.expeditionResult.unlockedEquipment.map((equipment) =>
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Icon(
                  Icons.science,
                  size: 16,
                  color: SurfacingCelebrationColors.surfacingGradient[2],
                ),
                const SizedBox(width: 8),
                Text(
                  equipment.name,
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'body'),
                    color: SurfacingCelebrationColors.getCelebrationTextColor(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ] else ...[
        Text(
          'No new equipment unlocked',
          style: TextStyle(
            fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'body'),
            color: SurfacingCelebrationColors.getCelebrationSecondaryTextColor(context),
          ),
        ),
      ],
      if (widget.expeditionResult.nextEquipmentHint != null) ...[
        SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 'section_spacing')),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: SurfacingCelebrationColors.surfacingGradient[2].withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.tips_and_updates,
                size: 20,
                color: SurfacingCelebrationColors.surfacingGradient[2],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Next: ${widget.expeditionResult.nextEquipmentHint}',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'caption'),
                    color: SurfacingCelebrationColors.getCelebrationSecondaryTextColor(context),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ];
  }


  Widget _buildDesktopSidebar() {
    return Container(
      padding: EdgeInsets.all(
        ResponsiveHelper.getResponsiveSpacing(context, 'sidebar_padding'),
      ),
      decoration: SurfacingCelebrationColors.getCelebrationCardDecoration(context, null),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Session Summary',
            style: TextStyle(
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'sidebar_title'),
              fontWeight: FontWeight.bold,
              color: SurfacingCelebrationColors.getCelebrationTextColor(context),
            ),
          ),
          SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 'content_spacing')),
          // Comparison metrics
          ComparisonMetrics(
            expeditionResult: widget.expeditionResult,
            showDetailedMetrics: false,
          ),
          SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 'section_spacing')),
          _buildBreakTransitionPreview(),
        ],
      ),
    );
  }

  Widget _buildWideDesktopSidebar() {
    return Container(
      padding: EdgeInsets.all(
        ResponsiveHelper.getResponsiveSpacing(context, 'sidebar_padding'),
      ),
      decoration: SurfacingCelebrationColors.getCelebrationCardDecoration(context, null),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Achievement Overview',
            style: TextStyle(
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'sidebar_title'),
              fontWeight: FontWeight.bold,
              color: SurfacingCelebrationColors.getCelebrationTextColor(context),
            ),
          ),
          SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 'content_spacing')),
          // Detailed comparison metrics for wide desktop
          ComparisonMetrics(
            expeditionResult: widget.expeditionResult,
            showDetailedMetrics: true,
          ),
          SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 'section_spacing')),
          _buildBreakTransitionPreview(),
        ],
      ),
    );
  }

  Widget _buildBreakTransitionPreview() {
    return Container(
      padding: EdgeInsets.all(
        ResponsiveHelper.getResponsiveSpacing(context, 'preview_padding'),
      ),
      decoration: BoxDecoration(
        gradient: SurfacingCelebrationColors.getBreakTransitionGradient(),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.spa,
            color: Colors.white,
            size: ResponsiveHelper.getIconSize(context, 'medium'),
          ),
          SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 'text_spacing')),
          Text(
            'Ready for break session',
            style: TextStyle(
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'preview_text'),
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _toggleSection(DashboardSection section) {
    setState(() {
      _expandedSections[section] = !(_expandedSections[section] ?? false);
    });
  }

  IconData _getIconForSection(DashboardSection section) {
    switch (section) {
      case DashboardSection.session:
        return Icons.assessment;
      case DashboardSection.career:
        return Icons.trending_up;
      case DashboardSection.species:
        return Icons.pets;
      case DashboardSection.equipment:
        return Icons.build;
    }
  }

  String _getTitleForSection(DashboardSection section) {
    switch (section) {
      case DashboardSection.session:
        return 'Session Results';
      case DashboardSection.career:
        return 'Career Progress';
      case DashboardSection.species:
        return 'Species Discoveries';
      case DashboardSection.equipment:
        return 'Equipment Unlocks';
    }
  }

  String _getSummaryForSection(DashboardSection section) {
    switch (section) {
      case DashboardSection.session:
        return '${widget.expeditionResult.dataPointsCollected} data points collected';
      case DashboardSection.career:
        return 'Career advancement earned';
      case DashboardSection.species:
        return 'New species discovered';
      case DashboardSection.equipment:
        return 'Equipment unlocked';
    }
  }

  AchievementType? _getAchievementTypeForSection(DashboardSection section) {
    switch (section) {
      case DashboardSection.session:
        return AchievementType.sessionQuality;
      case DashboardSection.career:
        return AchievementType.careerAdvancement;
      case DashboardSection.species:
        return AchievementType.speciesDiscovery;
      case DashboardSection.equipment:
        return AchievementType.research;
    }
  }
}

enum DashboardSection {
  session,
  career,
  species,
  equipment,
}
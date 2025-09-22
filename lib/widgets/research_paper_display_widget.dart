import 'package:flutter/material.dart';
import '../services/research_paper_service.dart';
import '../models/creature.dart';
import '../utils/responsive_helper.dart';

/// Research Paper Display Widget - Phase 4 Scientific Documentation UI
/// Displays available research papers with publication interface
class ResearchPaperDisplayWidget extends StatelessWidget {
  final List<ResearchPaper> papers;
  final List<String> publishedPapers;
  final bool showOnlyAvailable;
  final Function(ResearchPaper)? onPublishPaper;

  const ResearchPaperDisplayWidget({
    super.key,
    required this.papers,
    required this.publishedPapers,
    this.showOnlyAvailable = true,
    this.onPublishPaper,
  });

  @override
  Widget build(BuildContext context) {
    if (papers.isEmpty) {
      return Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.article_outlined,
                size: 48,
                color: Colors.white54,
              ),
              const SizedBox(height: 16),
              const Text(
                'No Research Papers Available',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                showOnlyAvailable
                    ? 'Discover more species to unlock research opportunities'
                    : 'You have published all available papers!',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: papers.length,
      itemBuilder: (context, index) {
        final paper = papers[index];
        final isPublished = publishedPapers.contains(paper.id);
        
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                paper.categoryColor.withValues(alpha: 0.3),
                paper.categoryColor.withValues(alpha: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: paper.categoryColor.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: onPublishPaper != null && !isPublished
                  ? () => _showPublishDialog(context, paper)
                  : null,
              child: Padding(
                padding: EdgeInsets.all(ResponsiveHelper.getResponsiveSpacing(context, 'card')),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Icon(
                          paper.categoryIcon,
                          color: paper.categoryColor,
                          size: ResponsiveHelper.getIconSize(context, 'medium'),
                        ),
                        SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, 'navigation')),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                paper.title,
                                style: TextStyle(
                                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'title'),
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              if (paper.biome != null)
                                Text(
                                  paper.biome!.displayName,
                                  style: TextStyle(
                                    fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'caption'),
                                    color: paper.categoryColor,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (isPublished)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.green.withValues(alpha: 0.5),
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  size: 14,
                                  color: Colors.green,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Published',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Description
                    Text(
                      paper.description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Requirements
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Requirements:',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.stars,
                                size: 16,
                                color: Colors.amber.withValues(alpha: 0.8),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Level ${paper.requiredLevel}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white70,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Icon(
                                Icons.pets,
                                size: 16,
                                color: Colors.cyan.withValues(alpha: 0.8),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${paper.requiredDiscoveries} discoveries',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                          if (paper.requiredSpecies.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Specific species required',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.orange.withValues(alpha: 0.8),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Rewards
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.science,
                              size: 16,
                              color: Colors.purple,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Research Value: ${paper.researchValue}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.purple,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              size: 16,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '+${paper.rpReward} RP',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.amber,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    
                    if (!isPublished && onPublishPaper != null) ...[
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => _showPublishDialog(context, paper),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: paper.categoryColor,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.publish, size: 18),
                              SizedBox(width: 8),
                              Text(
                                'Publish Paper',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showPublishDialog(BuildContext context, ResearchPaper paper) {
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: const Color(0xFF1E3A5F),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                paper.categoryColor.withValues(alpha: 0.3),
                paper.categoryColor.withValues(alpha: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: paper.categoryColor.withValues(alpha: 0.5),
              width: 2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.article,
                color: paper.categoryColor,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'Publish Research Paper',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                paper.title,
                style: TextStyle(
                  fontSize: 16,
                  color: paper.categoryColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Are you ready to publish this research paper? Once published, it will contribute to your research career and cannot be unpublished.',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Publication Rewards:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              '+${paper.rpReward} RP',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.amber,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(Icons.science, color: Colors.purple, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              '+${paper.researchValue} Research',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.purple,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      onPublishPaper!(paper);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: paper.categoryColor,
                    ),
                    child: const Text('Publish'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';

class FeedFilterBottomSheet extends StatefulWidget {
  final String? selectedSector;
  final String? selectedStage;
  final String selectedSort;
  final Function(String?, String?, String) onApply;

  const FeedFilterBottomSheet({
    Key? key,
    this.selectedSector,
    this.selectedStage,
    required this.selectedSort,
    required this.onApply,
  }) : super(key: key);

  @override
  State<FeedFilterBottomSheet> createState() => _FeedFilterBottomSheetState();
}

class _FeedFilterBottomSheetState extends State<FeedFilterBottomSheet> {
  late String? _sector;
  late String? _stage;
  late String _sort;

  static const List<String> sectors = [
    'FinTech',
    'HealthTech',
    'AgriTech',
    'EdTech',
    'E-commerce',
    'SaaS',
    'AI/ML',
    'CleanTech',
    'BioTech',
    'Other',
  ];

  static const List<String> stages = [
    'Idea',
    'MVP',
    'Early Revenue',
    'Growth',
    'Scaling',
  ];

  static const Map<String, String> sortOptions = {
    'recent': 'Most Recent',
    'trending': 'Trending',
    'relevance': 'Most Relevant',
    'ai_score': 'AI Match Score',
  };

  @override
  void initState() {
    super.initState();
    _sector = widget.selectedSector;
    _stage = widget.selectedStage;
    _sort = widget.selectedSort;
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      minChildSize: 0.4,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Filters & Sort',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Sort Section
                const Text(
                  'Sort By',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: sortOptions.entries.map((entry) {
                    final isSelected = _sort == entry.key;
                    return FilterChip(
                      label: Text(entry.value),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() => _sort = entry.key);
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // Sector Filter
                const Text(
                  'Sector',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilterChip(
                      label: const Text('All'),
                      selected: _sector == null,
                      onSelected: (selected) {
                        setState(() => _sector = null);
                      },
                    ),
                    ...sectors.map((sector) {
                      final isSelected = _sector == sector;
                      return FilterChip(
                        label: Text(sector),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() => _sector = selected ? sector : null);
                        },
                      );
                    }).toList(),
                  ],
                ),
                const SizedBox(height: 20),

                // Stage Filter
                const Text(
                  'Stage',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilterChip(
                      label: const Text('All'),
                      selected: _stage == null,
                      onSelected: (selected) {
                        setState(() => _stage = null);
                      },
                    ),
                    ...stages.map((stage) {
                      final isSelected = _stage == stage;
                      return FilterChip(
                        label: Text(stage),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() => _stage = selected ? stage : null);
                        },
                      );
                    }).toList(),
                  ],
                ),
                const SizedBox(height: 32),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _sector = null;
                            _stage = null;
                            _sort = 'recent';
                          });
                        },
                        child: const Text('Reset'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          widget.onApply(_sector, _stage, _sort);
                          Navigator.pop(context);
                        },
                        child: const Text('Apply'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

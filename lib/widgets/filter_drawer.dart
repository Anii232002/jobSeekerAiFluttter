import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/job_provider.dart';
import '../theme/app_theme.dart';

class FilterDrawer extends StatefulWidget {
  const FilterDrawer({super.key});

  @override
  State<FilterDrawer> createState() => _FilterDrawerState();
}

class _FilterDrawerState extends State<FilterDrawer> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  List<String> _filteredLocations = [];

  @override
  void initState() {
    super.initState();
    final jobProvider = Provider.of<JobProvider>(context, listen: false);
    _searchController.text = jobProvider.searchQuery;
    _filteredLocations = jobProvider.availableLocations;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _filterLocations(String query) {
    final jobProvider = Provider.of<JobProvider>(context, listen: false);
    setState(() {
      if (query.isEmpty) {
        _filteredLocations = jobProvider.availableLocations;
      } else {
        _filteredLocations = jobProvider.availableLocations
            .where(
              (location) =>
                  location.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Icon(
                    Icons.filter_list,
                    color: AppTheme.primaryYellow,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Filters',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Consumer<JobProvider>(
                    builder: (context, jobProvider, child) {
                      return TextButton(
                        onPressed: () {
                          jobProvider.clearFilters();
                          _searchController.clear();
                          _locationController.clear();
                        },
                        child: const Text(
                          'Clear All',
                          style: TextStyle(color: AppTheme.primaryYellow),
                        ),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Scrollable content area
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Search query
                      Text(
                        'Search Jobs',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          hintText: 'e.g., Flutter Developer, UI Designer...',
                          prefixIcon: Icon(
                            Icons.search,
                            color: AppTheme.textTertiary,
                          ),
                        ),
                        onChanged: (value) {
                          Provider.of<JobProvider>(
                            context,
                            listen: false,
                          ).updateSearchQuery(value);
                        },
                      ),

                      const SizedBox(height: 24),

                      // Location filter
                      Text(
                        'Location',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 12),

                      // Selected locations chips
                      Consumer<JobProvider>(
                        builder: (context, jobProvider, child) {
                          if (jobProvider.selectedLocations.isNotEmpty) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 4,
                                  children: jobProvider.selectedLocations
                                      .map(
                                        (location) =>
                                            _buildSelectedLocationChip(
                                              location,
                                              jobProvider,
                                            ),
                                      )
                                      .toList(),
                                ),
                                const SizedBox(height: 8),
                              ],
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),

                      // Location search field
                      TextField(
                        controller: _locationController,
                        decoration: const InputDecoration(
                          hintText: 'Search locations...',
                          prefixIcon: Icon(
                            Icons.location_on,
                            color: AppTheme.textTertiary,
                          ),
                        ),
                        onChanged: _filterLocations,
                      ),
                      const SizedBox(height: 8),

                      // Location suggestions
                      SizedBox(
                        height: 120,
                        child: SingleChildScrollView(
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: _filteredLocations
                                .map(
                                  (location) =>
                                      _buildLocationSuggestionChip(location),
                                )
                                .toList(),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Category filter
                      Text(
                        'Experience Level',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 12),
                      Consumer<JobProvider>(
                        builder: (context, jobProvider, child) {
                          return Wrap(
                            spacing: 8,
                            children: [
                              _buildCategoryChip(
                                'early',
                                'Entry Level',
                                jobProvider,
                              ),
                              _buildCategoryChip(
                                'mid',
                                'Mid Level',
                                jobProvider,
                              ),
                              _buildCategoryChip(
                                'senior',
                                'Senior Level',
                                jobProvider,
                              ),
                            ],
                          );
                        },
                      ),

                      const SizedBox(height: 24),

                      // Source filter
                      Text(
                        'Job Source',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 12),
                      Consumer<JobProvider>(
                        builder: (context, jobProvider, child) {
                          return Wrap(
                            spacing: 8,
                            children: jobProvider.availableSources
                                .map(
                                  (source) =>
                                      _buildSourceChip(source, jobProvider),
                                )
                                .toList(),
                          );
                        },
                      ),

                      const SizedBox(height: 24),

                      // Skills filter
                      Text(
                        'Skills',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 12),

                      Consumer<JobProvider>(
                        builder: (context, jobProvider, child) {
                          return Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: jobProvider.availableSkills
                                .map(
                                  (skill) =>
                                      _buildSkillChip(skill, jobProvider),
                                )
                                .toList(),
                          );
                        },
                      ),

                      const SizedBox(height: 100), // Extra space at bottom
                    ],
                  ),
                ),
              ),

              // Search button (fixed at bottom)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Provider.of<JobProvider>(
                      context,
                      listen: false,
                    ).searchJobs();
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text('Search Jobs'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(
    String value,
    String label,
    JobProvider jobProvider,
  ) {
    final isSelected = jobProvider.selectedCategory == value;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        jobProvider.updateCategoryFilter(selected ? value : null);
      },
      backgroundColor: AppTheme.surfaceColor,
      selectedColor: AppTheme.primaryYellow,
      labelStyle: TextStyle(
        color: isSelected ? AppTheme.darkBackground : AppTheme.textSecondary,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }

  Widget _buildSourceChip(String source, JobProvider jobProvider) {
    final isSelected = jobProvider.selectedSources.contains(source);

    return FilterChip(
      label: Text(_getSourceDisplayName(source)),
      selected: isSelected,
      onSelected: (selected) {
        jobProvider.toggleSourceFilter(source);
      },
      backgroundColor: AppTheme.surfaceColor,
      selectedColor: AppTheme.primaryYellow,
      labelStyle: TextStyle(
        color: isSelected ? AppTheme.darkBackground : AppTheme.textSecondary,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }

  String _getSourceDisplayName(String source) {
    switch (source.toLowerCase()) {
      case 'greenhouse':
        return 'Greenhouse';
      case 'lever':
        return 'Lever';
      case 'jooble':
        return 'Jooble';
      case 'remotive':
        return 'Remotive';
      case 'workday':
        return 'Workday';
      default:
        return source
            .split(' ')
            .map(
              (word) => word.isNotEmpty
                  ? word[0].toUpperCase() + word.substring(1).toLowerCase()
                  : '',
            )
            .join(' ');
    }
  }

  Widget _buildSkillChip(String skill, JobProvider jobProvider) {
    final isSelected = jobProvider.selectedSkills.contains(skill);

    return FilterChip(
      label: Text(skill),
      selected: isSelected,
      onSelected: (selected) {
        jobProvider.toggleSkillFilter(skill);
      },
      backgroundColor: AppTheme.surfaceColor,
      selectedColor: AppTheme.primaryYellow,
      labelStyle: TextStyle(
        color: isSelected ? AppTheme.darkBackground : AppTheme.textSecondary,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        fontSize: 12,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }

  Widget _buildSelectedLocationChip(String location, JobProvider jobProvider) {
    return Chip(
      label: Text(location),
      deleteIcon: const Icon(Icons.close, size: 16),
      onDeleted: () {
        jobProvider.toggleLocationFilter(location);
      },
      backgroundColor: AppTheme.primaryYellow,
      labelStyle: const TextStyle(
        color: AppTheme.darkBackground,
        fontWeight: FontWeight.w500,
        fontSize: 12,
      ),
      deleteIconColor: AppTheme.darkBackground,
    );
  }

  Widget _buildLocationSuggestionChip(String location) {
    return Consumer<JobProvider>(
      builder: (context, jobProvider, child) {
        final isSelected = jobProvider.selectedLocations.contains(location);

        if (isSelected) {
          return const SizedBox.shrink(); // Don't show already selected locations
        }

        return ActionChip(
          label: Text(location),
          onPressed: () {
            jobProvider.toggleLocationFilter(location);
            _locationController.clear();
            _filteredLocations = jobProvider.availableLocations;
          },
          backgroundColor: AppTheme.surfaceColor,
          labelStyle: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 12,
          ),
        );
      },
    );
  }
}

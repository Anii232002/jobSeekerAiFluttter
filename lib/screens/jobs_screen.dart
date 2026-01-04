import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/job_model.dart';
import '../providers/job_provider.dart';
import '../widgets/job_card.dart';
import '../widgets/filter_drawer.dart';
import '../theme/app_theme.dart';
import 'job_detail_screen.dart';
import 'saved_jobs_screen.dart';

class JobsScreen extends StatefulWidget {
  const JobsScreen({super.key});

  @override
  State<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    // Load jobs when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<JobProvider>(context, listen: false).loadJobs();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Jobs'),
        leading: IconButton(
          icon: const Icon(Icons.filter_list),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SavedJobsScreen(),
                ),
              );
            },
            tooltip: 'Saved Jobs',
          ),
        ],
      ),
      drawer: const FilterDrawer(),
      body: Consumer<JobProvider>(
        builder: (context, jobProvider, child) {
          // Show error toast for any error
          if (jobProvider.error != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.white),
                      const SizedBox(width: 12),
                      Expanded(child: Text('Error: ${jobProvider.error}')),
                    ],
                  ),
                  backgroundColor: AppTheme.accentRed,
                  duration: const Duration(seconds: 5),
                  action: SnackBarAction(
                    label: 'Retry',
                    textColor: Colors.white,
                    onPressed: () {
                      jobProvider.loadJobs(refresh: true);
                    },
                  ),
                ),
              );
            });
          }

          // Show server busy toast
          if (jobProvider.serverBusyError != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.cloud_off, color: Colors.white),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(jobProvider.serverBusyError!.message),
                      ),
                    ],
                  ),
                  backgroundColor: AppTheme.primaryYellow.withOpacity(0.9),
                  duration: const Duration(seconds: 4),
                ),
              );
            });
          }

          if (jobProvider.isLoading && jobProvider.jobs.isEmpty) {
            return _buildInteractiveLoadingScreen();
          }

          return Stack(
            children: [
              _buildJobsList(jobProvider),
              if (jobProvider.isLoading && jobProvider.jobs.isNotEmpty)
                _buildLoadingOverlay(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildJobsList(JobProvider jobProvider) {
    if (jobProvider.error != null && jobProvider.jobs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppTheme.textTertiary),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Please try again later',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppTheme.textTertiary),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => jobProvider.loadJobs(refresh: true),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (jobProvider.jobs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.work_off, size: 64, color: AppTheme.textTertiary),
            const SizedBox(height: 16),
            Text(
              'No jobs found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your filters or search criteria',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppTheme.textTertiary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                jobProvider.clearFilters();
                jobProvider.loadJobs(refresh: true);
              },
              child: const Text('Clear Filters'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppTheme.primaryYellow,
      onRefresh: () => jobProvider.loadJobs(refresh: true),
      child: Column(
        children: [
          // Pagination controls and active filters
          _buildTopControls(jobProvider),

          // Job list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount:
                  jobProvider.jobs.length + (jobProvider.isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == jobProvider.jobs.length) {
                  // Loading indicator at the bottom
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.primaryYellow,
                      ),
                    ),
                  );
                }

                final job = jobProvider.jobs[index];
                return JobCard(
                  job: job,
                  onTap: () => _navigateToJobDetail(job),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopControls(JobProvider jobProvider) {
    return Column(
      children: [
        // Pagination and filters row
        if (jobProvider.totalPages > 1 || _hasActiveFilters(jobProvider))
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                // Pagination controls (always on top when visible)
                if (jobProvider.totalPages > 1)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Page ${jobProvider.currentPage} of ${jobProvider.totalPages} (${jobProvider.total} jobs)',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed:
                                jobProvider.hasPrevious &&
                                    !jobProvider.isLoading
                                ? () => jobProvider.goToPreviousPage()
                                : null,
                            icon: const Icon(Icons.chevron_left),
                            color: AppTheme.primaryYellow,
                            disabledColor: AppTheme.textTertiary,
                          ),
                          IconButton(
                            onPressed:
                                jobProvider.hasNext && !jobProvider.isLoading
                                ? () => jobProvider.goToNextPage()
                                : null,
                            icon: const Icon(Icons.chevron_right),
                            color: AppTheme.primaryYellow,
                            disabledColor: AppTheme.textTertiary,
                          ),
                        ],
                      ),
                    ],
                  ),

                // Small spacing between pagination and filters
                if (jobProvider.totalPages > 1 &&
                    _hasActiveFilters(jobProvider))
                  const SizedBox(height: 4),

                // Active filters indicator (below pagination)
                if (_hasActiveFilters(jobProvider))
                  _buildActiveFiltersBar(jobProvider),
              ],
            ),
          ),
      ],
    );
  }

  bool _hasActiveFilters(JobProvider jobProvider) {
    return jobProvider.searchQuery.isNotEmpty ||
        jobProvider.selectedLocations.isNotEmpty ||
        jobProvider.selectedSkills.isNotEmpty ||
        jobProvider.selectedCategory != null ||
        jobProvider.selectedSources.isNotEmpty ||
        jobProvider.selectedResumeId != null;
  }

  Widget _buildActiveFiltersBar(JobProvider jobProvider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.filter_list, size: 14, color: AppTheme.textSecondary),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              _getActiveFiltersText(jobProvider),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
                fontSize: 11,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              if (jobProvider.selectedResumeId != null) {
                jobProvider.clearResumeFilter();
              } else {
                jobProvider.clearFilters();
                jobProvider.loadJobs(refresh: true);
              }
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'Clear',
              style: TextStyle(color: AppTheme.primaryYellow, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  String _getActiveFiltersText(JobProvider jobProvider) {
    final filters = <String>[];

    if (jobProvider.searchQuery.isNotEmpty) {
      filters.add('"${jobProvider.searchQuery}"');
    }

    if (jobProvider.selectedLocations.isNotEmpty) {
      filters.add('Locations: ${jobProvider.selectedLocations.length}');
    }

    if (jobProvider.selectedCategory != null) {
      filters.add('Level: ${jobProvider.selectedCategory}');
    }

    if (jobProvider.selectedSources.isNotEmpty) {
      filters.add('Sources: ${jobProvider.selectedSources.length}');
    }

    if (jobProvider.selectedSkills.isNotEmpty) {
      filters.add('Skills: ${jobProvider.selectedSkills.length}');
    }

    if (jobProvider.selectedResumeId != null) {
      filters.add('Resume Match Active');
    }

    return 'Active filters: ${filters.join(', ')}';
  }

  void _navigateToJobDetail(Job job) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => JobDetailScreen(job: job)),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.3),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 50,
                height: 50,
                child: CircularProgressIndicator(
                  color: AppTheme.primaryYellow,
                  strokeWidth: 3,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Loading new jobs...',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Please wait a moment',
                style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInteractiveLoadingScreen() {
    return Container(
      decoration: const BoxDecoration(color: Colors.black),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated loading indicator
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(50),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white,
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Center(
                child: SizedBox(
                  width: 50,
                  height: 50,
                  child: CircularProgressIndicator(
                    color: Colors.black,
                    strokeWidth: 4,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Loading text with animation
            const Text(
              'Finding Your Dream Job',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Searching through thousands of opportunities...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.9),
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 40),

            // Fun loading messages
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Text(
                '💼 Analyzing job market trends...',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

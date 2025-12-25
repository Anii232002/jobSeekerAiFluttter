import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/job_model.dart';
import '../providers/job_provider.dart';
import '../widgets/job_card.dart';
import '../theme/app_theme.dart';
import 'job_detail_screen.dart';

class SavedJobsScreen extends StatefulWidget {
  const SavedJobsScreen({super.key});

  @override
  State<SavedJobsScreen> createState() => _SavedJobsScreenState();
}

class _SavedJobsScreenState extends State<SavedJobsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Applied Jobs'),
        actions: [
          IconButton(
            onPressed: () => _showCronJobConfirmDialog(context),
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh jobs from server',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryYellow,
          labelColor: AppTheme.primaryYellow,
          unselectedLabelColor: AppTheme.textTertiary,
          tabs: [
            Tab(
              child: Consumer<JobProvider>(
                builder: (context, jobProvider, child) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Saved'),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${jobProvider.savedJobs.length}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            Tab(
              child: Consumer<JobProvider>(
                builder: (context, jobProvider, child) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Applied'),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${jobProvider.appliedJobs.length}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildSavedJobsTab(), _buildAppliedJobsTab()],
      ),
    );
  }

  Widget _buildSavedJobsTab() {
    return Consumer<JobProvider>(
      builder: (context, jobProvider, child) {
        if (jobProvider.savedJobs.isEmpty) {
          return _buildEmptyState(
            icon: Icons.bookmark_border,
            title: 'No Saved Jobs',
            message:
                'Jobs you save will appear here.\nStart exploring and save jobs you\'re interested in!',
            actionText: 'Explore Jobs',
            onActionPressed: () => Navigator.of(context).pop(),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: jobProvider.savedJobs.length,
          itemBuilder: (context, index) {
            final job = jobProvider.savedJobs[index];
            final isApplied = jobProvider.isJobApplied(job);

            return JobCard(
              job: job,
              onTap: () => _navigateToJobDetail(job),
              showApplyButton: false,
              statusTag: isApplied ? 'Applied' : 'Saved',
            );
          },
        );
      },
    );
  }

  Widget _buildAppliedJobsTab() {
    return Consumer<JobProvider>(
      builder: (context, jobProvider, child) {
        if (jobProvider.appliedJobs.isEmpty) {
          return _buildEmptyState(
            icon: Icons.work_outline,
            title: 'No Applied Jobs',
            message:
                'Jobs you apply for will appear here.\nStart applying and track your progress!',
            actionText: 'Find Jobs',
            onActionPressed: () => Navigator.of(context).pop(),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: jobProvider.appliedJobs.length,
          itemBuilder: (context, index) {
            final job = jobProvider.appliedJobs[index];

            return JobCard(
              job: job,
              onTap: () => _navigateToJobDetail(job),
              showApplyButton: false,
              statusTag: _getApplicationStatus(index),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String message,
    required String actionText,
    required VoidCallback onActionPressed,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: AppTheme.textTertiary),
            const SizedBox(height: 24),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textTertiary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: onActionPressed,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                child: Text(actionText),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getApplicationStatus(int index) {
    // For demo purposes, show different statuses based on index
    if (index == 0) return 'Accepted';
    if (index == 1) return 'Rejected';
    return 'Applied';
  }

  void _navigateToJobDetail(Job job) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => JobDetailScreen(job: job)),
    );
  }

  void _showCronJobConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppTheme.cardBackground,
          title: const Text('Refresh Jobs'),
          content: const Text(
            'This will run a cron job on the server to fetch the latest jobs. This may take a few moments. Are you sure you want to continue?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _runCronJob();
              },
              child: const Text('Refresh'),
            ),
          ],
        );
      },
    );
  }

  void _runCronJob() async {
    final jobProvider = Provider.of<JobProvider>(context, listen: false);

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(color: AppTheme.primaryYellow),
        );
      },
    );

    // Trigger the cron job (fire and forget from UI perspective)
    // We don't await the result because we want to return control to user
    jobProvider.runCronJob().then((success) {
      debugPrint("Background cron job finished. Success: $success");
    });

    // Wait 1 second to simulate "request sent"
    await Future.delayed(const Duration(seconds: 1));

    // Close loading dialog
    if (mounted) Navigator.of(context).pop();

    // Show message immediately
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Jobs are being updated in the background. Check back soon!',
          ),
          backgroundColor: AppTheme.accentGreen,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }
}

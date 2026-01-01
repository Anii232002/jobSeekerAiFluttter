import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/application_model.dart';
import '../providers/job_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/application_card.dart';
import '../widgets/add_application_dialog.dart';
import 'application_detail_screen.dart';

class ApplicationsScreen extends StatefulWidget {
  const ApplicationsScreen({super.key});

  @override
  State<ApplicationsScreen> createState() => _ApplicationsScreenState();
}

class _ApplicationsScreenState extends State<ApplicationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _statuses = [
    'All',
    Application.statusApplied,
    Application.statusInterviewScheduled,
    Application.statusInterviewCompleted,
    Application.statusOffer,
    Application.statusRejected,
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _statuses.length, vsync: this);
    
    // Load applications when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<JobProvider>(context, listen: false).loadApplications();
    });
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
        title: const Text('My Applications'),
        actions: [
          IconButton(
            onPressed: () {
              Provider.of<JobProvider>(context, listen: false).loadApplications(refresh: true);
            },
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh applications',
          ),
          IconButton(
            onPressed: () {
              _showAddApplicationDialog(context);
            },
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Add application manually',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryYellow,
          labelColor: AppTheme.primaryYellow,
          unselectedLabelColor: AppTheme.textTertiary,
          isScrollable: true,
          tabs: _statuses.asMap().entries.map((entry) {
            final status = entry.value;
            return Tab(
              child: Consumer<JobProvider>(
                builder: (context, jobProvider, child) {
                  final count = status == 'All'
                      ? jobProvider.applications.length
                      : jobProvider.applications
                          .where((app) => app.status == status)
                          .length;

                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [

                      Text(status == 'All' ? 'All' : _formatStatusText(status)),
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
                          '$count',
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
            );
          }).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _statuses
            .map((status) => _buildApplicationsTab(status))
            .toList(),
      ),
    );
  }

  Widget _buildApplicationsTab(String statusFilter) {
    return Consumer<JobProvider>(
      builder: (context, jobProvider, child) {
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

        // Filter applications by status
        final filteredApplications = statusFilter == 'All'
            ? jobProvider.applications
            : jobProvider.applications
                .where((app) => app.status == statusFilter)
                .toList();

        if (jobProvider.isLoading && jobProvider.applications.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppTheme.primaryYellow,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Loading applications...',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          );
        }

        if (filteredApplications.isEmpty) {
          return _buildEmptyState(
            icon: Icons.inbox_outlined,
            title: statusFilter == 'All'
                ? 'No Applications'
                : 'No ${_formatStatusText(statusFilter)} Applications',
            message:
                'You haven\'t applied to any jobs yet.\nStart browsing and applying to positions!',
            actionText: 'Browse Jobs',
            onActionPressed: () => Navigator.of(context).pop(),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: filteredApplications.length,
          itemBuilder: (context, index) {
            final application = filteredApplications[index];

            return ApplicationCard(
              application: application,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ApplicationDetailScreen(
                      application: application,
                    ),
                  ),
                );
              },
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
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textTertiary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: onActionPressed,
              child: Text(actionText),
            ),
          ],
        ),
      ),
    );
  }

  String _getStatusEmoji(String status) {
    switch (status) {
      case Application.statusApplied:
        return '🟢';
      case Application.statusInterviewScheduled:
        return '🟡';
      case Application.statusInterviewCompleted:
        return '🔵';
      case Application.statusOffer:
        return '🟠';
      case Application.statusRejected:
        return '🔴';
      default:
        return '⚪';
    }
  }

  String _formatStatusText(String status) {
    switch (status) {
      case Application.statusApplied:
        return 'Applied';
      case Application.statusInterviewScheduled:
        return 'Interview';
      case Application.statusInterviewCompleted:
        return 'Completed';
      case Application.statusOffer:
        return 'Offer';
      case Application.statusRejected:
        return 'Rejected';
      default:
        return status;
    }
  }

  void _showAddApplicationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AddApplicationDialog(
        onSubmit: (data) async {
          try {
            // Create application via API
            await Provider.of<JobProvider>(context, listen: false)
                .createApplication(
              jobId: data['job_id'],
              jobTitle: data['job_title'],
              companyName: data['company_name'],
              jobUrl: data['job_url'],
              status: data['status'],
              salaryOffered: data['salary_offered'],
              notes: data['notes'],
            );

            if (!context.mounted) return;

            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white),
                    const SizedBox(width: 12),
                    Text(
                      'Application added: ${data['job_title']} @ ${data['company_name']}',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                backgroundColor: AppTheme.accentGreen,
                duration: const Duration(seconds: 3),
              ),
            );
          } catch (e) {
            if (!context.mounted) return;

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: $e'),
                backgroundColor: AppTheme.accentRed,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        },
      ),
    );
  }
}

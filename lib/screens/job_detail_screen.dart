import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/job_model.dart';
import '../providers/job_provider.dart';
import '../theme/app_theme.dart';

class JobDetailScreen extends StatelessWidget {
  final Job job;

  const JobDetailScreen({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Detail'),
        actions: [
          Consumer<JobProvider>(
            builder: (context, jobProvider, child) {
              final isSaved = jobProvider.isJobSaved(job);
              return IconButton(
                onPressed: () {
                  jobProvider.toggleSaveJob(job);
                },
                icon: Icon(
                  isSaved ? Icons.bookmark : Icons.bookmark_border,
                  color: isSaved
                      ? AppTheme.primaryYellow
                      : AppTheme.textSecondary,
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header section
                  _buildHeader(context),

                  const SizedBox(height: 24),

                  // Job metadata
                  _buildJobMetadata(context),

                  const SizedBox(height: 24),

                  // Job description
                  _buildJobDescription(context),

                  const SizedBox(height: 24),

                  // Skills
                  if (job.skillsList.isNotEmpty) ...[
                    _buildSkillsSection(context),
                    const SizedBox(height: 100), // Space for fixed button
                  ],
                ],
              ),
            ),
          ),

          // Fixed apply button
          _buildApplyButton(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Center(
      child: Column(
        children: [
          // Company logo
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: job.imageUrl != null
                  ? Colors.transparent
                  : _getCompanyColor(),
            ),
            child: job.imageUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: CachedNetworkImage(
                      imageUrl: job.imageUrl!,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => _buildCompanyInitial(),
                      errorWidget: (context, url, error) =>
                          _buildCompanyInitial(),
                    ),
                  )
                : _buildCompanyInitial(),
          ),

          const SizedBox(height: 16),

          // Company name
          Text(
            job.companyName,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: AppTheme.textSecondary),
          ),

          const SizedBox(height: 8),

          // Job title
          Text(
            job.title,
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          // Job type tags
          Wrap(
            spacing: 8,
            children: [
              if (job.category != null) _buildJobTypeChip(job.displayCategory),
              _buildJobTypeChip('Remote'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildJobMetadata(BuildContext context) {
    return Row(
      children: [
        // Position
        Expanded(
          child: _buildMetadataCard(
            context,
            'Position',
            job.displayCategory.isNotEmpty
                ? job.displayCategory
                : 'Senior Level',
            Icons.work,
          ),
        ),

        const SizedBox(width: 12),

        // Salary
        Expanded(
          child: _buildMetadataCard(
            context,
            'Salary',
            job.salary ?? 'Not Specified',
            Icons.attach_money,
          ),
        ),

        const SizedBox(width: 12),

        // Location
        Expanded(
          child: _buildMetadataCard(
            context,
            'Location',
            job.location ?? 'Not Specified',
            Icons.location_on,
          ),
        ),
      ],
    );
  }

  Widget _buildMetadataCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.surfaceColor, width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppTheme.textTertiary, size: 20),
          const SizedBox(height: 8),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppTheme.textTertiary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildJobDescription(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header with tabs
        Center(child: _buildSectionTab('Description', true)),

        const SizedBox(height: 16),

        // Description content
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.cardBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'About The opportunity',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Text(
                job.desc,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(height: 1.6),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTab(String title, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? AppTheme.primaryYellow : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        title,
        style: TextStyle(
          color: isActive ? AppTheme.darkBackground : AppTheme.textSecondary,
          fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildSkillsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Required Skills',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: job.skillsList
              .map((skill) => _buildSkillChip(skill))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildJobTypeChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppTheme.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildSkillChip(String skill) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryYellow.withOpacity(0.3)),
      ),
      child: Text(
        skill,
        style: const TextStyle(
          color: AppTheme.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildApplyButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppTheme.darkBackground,
        border: Border(top: BorderSide(color: AppTheme.surfaceColor, width: 1)),
      ),
      child: SafeArea(
        child: Consumer<JobProvider>(
          builder: (context, jobProvider, child) {
            final isApplied = jobProvider.isJobApplied(job);

            if (isApplied) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: AppTheme.accentGreen,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white),
                    const SizedBox(width: 8),
                    const Text(
                      'Applied',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              );
            }

            return SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _handleApplyNow(context, jobProvider),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Apply Now',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Color _getCompanyColor() {
    // Generate a color based on company name
    final colors = [
      const Color(0xFF1DB954), // Spotify green
      const Color(0xFFE50914), // Netflix red
      const Color(0xFF1B2838), // Steam dark blue
      const Color(0xFF4285F4), // Google blue
      const Color(0xFF00A1F1), // Microsoft blue
      const Color(0xFFFF6B35), // Orange
      const Color(0xFF9C27B0), // Purple
      const Color(0xFF795548), // Brown
    ];

    final hash = job.companyName.hashCode;
    return colors[hash.abs() % colors.length];
  }

  Widget _buildCompanyInitial() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: _getCompanyColor(),
      ),
      child: Center(
        child: Text(
          job.companyName.isNotEmpty ? job.companyName[0].toUpperCase() : '?',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 32,
          ),
        ),
      ),
    );
  }

  Future<void> _handleApplyNow(
    BuildContext context,
    JobProvider jobProvider,
  ) async {
    try {
      // Try to launch the URL directly
      print("==>" + job.applyLink);
      final uri = Uri.parse(job.applyLink);
      await launchUrl(uri, mode: LaunchMode.externalApplication);

      // Show "Did you apply?" dialog after a short delay
      Future.delayed(const Duration(seconds: 2), () {
        if (context.mounted) {
          _showDidYouApplyDialog(context, jobProvider);
        }
      });
    } catch (e) {
      // Show error if can't launch URL
      print("Error launching URL: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Could not open the application link: ${e.toString()}',
            ),
            backgroundColor: AppTheme.accentRed,
            duration: const Duration(seconds: 3),
          ),
        );

        // Still show the apply dialog for fallback
        _showDidYouApplyDialog(context, jobProvider);
      }
    }
  }

  void _showDidYouApplyDialog(BuildContext context, JobProvider jobProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppTheme.cardBackground,
          title: const Text('Did you apply?'),
          content: const Text(
            'Let us know if you successfully applied for this job.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('No'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                jobProvider.markJobAsApplied(job);

                // Show success message
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Job marked as applied!'),
                    backgroundColor: AppTheme.accentGreen,
                  ),
                );
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }
}

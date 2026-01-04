import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/job_model.dart';
import '../providers/job_provider.dart';
import '../theme/app_theme.dart';

class JobCard extends StatelessWidget {
  final Job job;
  final VoidCallback? onTap;
  final bool showApplyButton;
  final String? statusTag; // For showing "Saved" or "Applied" tags

  const JobCard({
    super.key,
    required this.job,
    this.onTap,
    this.showApplyButton = true,
    this.statusTag,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row with logo, job info, and bookmark
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Company logo
                  _buildCompanyLogo(),
                  const SizedBox(width: 12),

                  // Job title and company name
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job.title,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          job.companyName,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppTheme.textTertiary),
                        ),
                      ],
                    ),
                  ),

                  // Bookmark icon
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
                              : AppTheme.textTertiary,
                        ),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Job type tags
              if (job.category != null || job.matchScore != null) ...[
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (job.matchScore != null)
                      _buildMatchScoreChip(job.matchScore!),
                    if (job.category != null)
                      _buildJobTypeChip(job.displayCategory),

                    if (job.location?.toLowerCase().contains('anywhere') ==
                        true)
                      _buildJobTypeChip('Anywhere'),
                  ],
                ),
                const SizedBox(height: 16),
              ],

              // Bottom row with salary, location, and apply button
              Row(
                children: [
                  // Left side: Salary and location
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (job.salary != null) ...[
                          Text(
                            job.salary!,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 4),
                        ],
                        if (job.location != null) ...[
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 16,
                                color: AppTheme.textTertiary,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  job.location!,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: AppTheme.textTertiary),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Right side: Apply button or status tag
                  if (statusTag != null)
                    _buildStatusTag(statusTag!)
                  else if (showApplyButton)
                    Consumer<JobProvider>(
                      builder: (context, jobProvider, child) {
                        final isApplied = jobProvider.isJobApplied(job);

                        if (isApplied) {
                          return _buildStatusTag(
                            'Applied',
                            color: AppTheme.accentGreen,
                          );
                        }

                        return ElevatedButton(
                          onPressed: () => _showApplyDialog(context),
                          child: const Text('Apply'),
                        );
                      },
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompanyLogo() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: AppTheme.surfaceColor,
      ),
      child: job.imageUrl != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: job.imageUrl!,
                fit: BoxFit.cover,
                placeholder: (context, url) => _buildCompanyInitial(),
                errorWidget: (context, url, error) => _buildCompanyInitial(),
              ),
            )
          : _buildCompanyInitial(),
    );
  }

  Widget _buildCompanyInitial() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: _getCompanyColor(),
      ),
      child: Center(
        child: Text(
          job.companyName.isNotEmpty ? job.companyName[0].toUpperCase() : '?',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
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

  Widget _buildMatchScoreChip(double score) {
    Color color;
    Color textColor = Colors.white;

    if (score >= 0.8) {
      color = AppTheme.accentGreen;
    } else if (score >= 0.5) {
      color = AppTheme.primaryYellow;
      textColor = Colors.black;
    } else {
      color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_awesome, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            '${(score * 100).toStringAsFixed(0)}% Match',
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
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

  Widget _buildStatusTag(String status, {Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color ?? AppTheme.primaryYellow,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color == null ? AppTheme.darkBackground : Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  void _showApplyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppTheme.cardBackground,
          title: const Text('Apply for Job'),
          content: Text(
            'You will be redirected to apply for "${job.title}" at ${job.companyName}.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // TODO: Open external link
                // Then show "Did you apply?" dialog
                _showDidYouApplyDialog(context);
              },
              child: const Text('Apply Now'),
            ),
          ],
        );
      },
    );
  }

  void _showDidYouApplyDialog(BuildContext context) {
    Future.delayed(const Duration(seconds: 1), () {
      if (context.mounted) {
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
                    Provider.of<JobProvider>(
                      context,
                      listen: false,
                    ).markJobAsApplied(job);

                    // Show success message
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
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
    });
  }
}

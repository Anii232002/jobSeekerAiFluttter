import 'package:flutter/material.dart';
import '../models/application_model.dart';
import '../theme/app_theme.dart';

class ApplicationCard extends StatelessWidget {
  final Application application;
  final VoidCallback? onTap;
  final VoidCallback? onStatusUpdate;

  const ApplicationCard({
    super.key,
    required this.application,
    this.onTap,
    this.onStatusUpdate,
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
              // Top row with company info and status emoji
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          application.jobTitle,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          application.companyName,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Status emoji
                  Text(
                    application.statusEmoji,
                    style: const TextStyle(fontSize: 32),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Status and date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Status',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textTertiary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(application.status).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            application.statusDisplay,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: _getStatusColor(application.status),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Applied',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textTertiary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        application.relativeDate,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Notes section if present
              if (application.notes != null && application.notes!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Notes',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textTertiary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        application.notes!,
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],

              // Salary section if present
              if (application.salaryOffered != null &&
                  application.salaryOffered!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.accentGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.attach_money,
                        size: 16,
                        color: AppTheme.accentGreen,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        application.salaryOffered!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.accentGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case Application.statusApplied:
        return const Color(0xFF4CAF50); // Green
      case Application.statusInterviewScheduled:
        return const Color(0xFFFFC107); // Amber
      case Application.statusInterviewCompleted:
        return const Color(0xFF2196F3); // Blue
      case Application.statusOffer:
        return const Color(0xFFFF9800); // Orange
      case Application.statusRejected:
        return const Color(0xFFF44336); // Red
      default:
        return AppTheme.textTertiary;
    }
  }
}

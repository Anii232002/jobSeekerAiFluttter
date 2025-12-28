import 'package:flutter/material.dart';
import '../models/application_model.dart';
import '../theme/app_theme.dart';

class AddApplicationDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onSubmit;

  const AddApplicationDialog({
    super.key,
    required this.onSubmit,
  });

  @override
  State<AddApplicationDialog> createState() => _AddApplicationDialogState();
}

class _AddApplicationDialogState extends State<AddApplicationDialog> {
  late TextEditingController _jobTitleController;
  late TextEditingController _companyNameController;
  late TextEditingController _salaryController;
  late TextEditingController _notesController;
  String _selectedStatus = Application.statusApplied;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _jobTitleController = TextEditingController();
    _companyNameController = TextEditingController();
    _salaryController = TextEditingController();
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _jobTitleController.dispose();
    _companyNameController.dispose();
    _salaryController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  bool _validateInputs() {
    // All fields are optional for external applications
    return true;
  }

  void _handleSubmit() {
    if (!_validateInputs()) return;

    setState(() => _isLoading = true);

    try {
      widget.onSubmit({
        'job_title': _jobTitleController.text.isEmpty
            ? 'Unknown Position'
            : _jobTitleController.text,
        'company_name': _companyNameController.text.isEmpty
            ? 'Unknown Company'
            : _companyNameController.text,
        'status': _selectedStatus,
        'salary_offered': _salaryController.text.isEmpty
            ? null
            : _salaryController.text,
        'notes': _notesController.text.isEmpty ? null : _notesController.text,
      });

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppTheme.accentRed,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppTheme.cardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  const Icon(Icons.add_circle_outline,
                      color: AppTheme.primaryYellow, size: 28),
                  const SizedBox(width: 12),
                  Text(
                    'Add Application',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),
              Text(
                'Manually track a job application',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textTertiary,
                ),
              ),

              const SizedBox(height: 24),

              // Optional: Job Title
              Text(
                'Job Title',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _jobTitleController,
                decoration: InputDecoration(
                  hintText:
                      'e.g., Senior Backend Engineer (defaults to "Unknown Position")',
                  filled: true,
                  fillColor: AppTheme.surfaceColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Optional: Company Name
              Text(
                'Company Name',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _companyNameController,
                decoration: InputDecoration(
                  hintText:
                      'e.g., Google (defaults to "Unknown Company")',
                  filled: true,
                  fillColor: AppTheme.surfaceColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Optional: Status
              Text(
                'Status',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButton<String>(
                  value: _selectedStatus,
                  isExpanded: true,
                  underline: Container(),
                  dropdownColor: AppTheme.cardBackground,
                  items: [
                    Application.statusApplied,
                    Application.statusInterviewScheduled,
                    Application.statusInterviewCompleted,
                    Application.statusOffer,
                    Application.statusRejected,
                  ]
                      .map((status) => DropdownMenuItem(
                            value: status,
                            child: Row(
                              children: [
                                Text(
                                  _getStatusEmoji(status),
                                  style: const TextStyle(fontSize: 18),
                                ),
                                const SizedBox(width: 8),
                                Text(_getStatusDisplay(status)),
                              ],
                            ),
                          ))
                      .toList(),
                  onChanged: (status) {
                    if (status != null) {
                      setState(() => _selectedStatus = status);
                    }
                  },
                ),
              ),

              const SizedBox(height: 16),

              // Optional: Salary
              Text(
                'Salary Offered',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _salaryController,
                decoration: InputDecoration(
                  hintText: 'e.g., \$100k - \$150k (optional)',
                  filled: true,
                  fillColor: AppTheme.surfaceColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Optional: Notes
              Text(
                'Notes',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _notesController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Add any notes (optional)',
                  filled: true,
                  fillColor: AppTheme.surfaceColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleSubmit,
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppTheme.darkBackground,
                                ),
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('Add Application'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.accentGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: AppTheme.accentGreen,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '* Job ID is required. Other fields will default if left empty.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.accentGreen,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getStatusDisplay(String status) {
    switch (status) {
      case Application.statusApplied:
        return 'Applied';
      case Application.statusInterviewScheduled:
        return 'Interview Scheduled';
      case Application.statusInterviewCompleted:
        return 'Interview Completed';
      case Application.statusOffer:
        return 'Offer Received';
      case Application.statusRejected:
        return 'Rejected';
      default:
        return status;
    }
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
}

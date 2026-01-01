import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/application_model.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class ApplicationDetailScreen extends StatefulWidget {
  final Application application;

  const ApplicationDetailScreen({
    super.key,
    required this.application,
  });

  @override
  State<ApplicationDetailScreen> createState() =>
      _ApplicationDetailScreenState();
}

class _ApplicationDetailScreenState extends State<ApplicationDetailScreen> {
  late Application _application;
  late TextEditingController _notesController;
  late TextEditingController _salaryController;
  String? _selectedStatus;
  bool _isLoading = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _application = widget.application;
    _notesController = TextEditingController(text: _application.notes ?? '');
    _salaryController =
        TextEditingController(text: _application.salaryOffered ?? '');
    _selectedStatus = _application.status;
  }

  @override
  void dispose() {
    _notesController.dispose();
    _salaryController.dispose();
    super.dispose();
  }

  Future<void> _updateApplication() async {
    setState(() => _isLoading = true);

    try {
      await ApiService.updateApplication(
        applicationId: _application.id,
        userId: _application.userId.toString(),
        status: _selectedStatus,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
        salaryOffered: _salaryController.text.isEmpty
            ? null
            : _salaryController.text,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Application updated successfully'),
          backgroundColor: AppTheme.accentGreen,
          duration: Duration(seconds: 2),
        ),
      );

      setState(() {
        _isEditing = false;
        _application = Application(
          id: _application.id,
          userId: _application.userId,
          jobId: _application.jobId,
          jobTitle: _application.jobTitle,
          companyName: _application.companyName,
          status: _selectedStatus!,
          dateApplied: _application.dateApplied,
          dateUpdated: DateTime.now(),
          notes: _notesController.text.isEmpty ? null : _notesController.text,
          salaryOffered: _salaryController.text.isEmpty
              ? null
              : _salaryController.text,
          followUpDate: _application.followUpDate,
          applyLink: _application.applyLink?.isEmpty ?? true ? '' : _application.applyLink,
          jobDescription: _application.jobDescription,
        );
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating application: $e'),
          backgroundColor: AppTheme.accentRed,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Application Details'),
        actions: [
          if (!_isEditing)
            IconButton(
              onPressed: () {
                setState(() => _isEditing = true);
              },
              icon: const Icon(Icons.edit),
            )
          else
            IconButton(
              onPressed: () {
                setState(() => _isEditing = false);
                // Reset values
                _notesController.text = _application.notes ?? '';
                _salaryController.text = _application.salaryOffered ?? '';
                _selectedStatus = _application.status;
              },
              icon: const Icon(Icons.close),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Job Header Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _application.jobTitle,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _application.companyName,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                      color: AppTheme.primaryYellow,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          _application.statusEmoji,
                          style: const TextStyle(fontSize: 48),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Status Section
            Text(
              'Status',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (_isEditing)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.primaryYellow,
                    width: 2,
                  ),
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
                            child: Text(
                              _getStatusDisplay(status),
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ))
                      .toList(),
                  onChanged: (status) {
                    setState(() => _selectedStatus = status);
                  },
                ),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(_application.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Text(
                      _application.statusEmoji,
                      style: const TextStyle(fontSize: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _application.statusDisplay,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: _getStatusColor(_application.status),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 24),

            // Timeline Section
            Text(
              'Timeline',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildTimelineItem(
                    'Applied',
                    DateFormat('MMM dd, yyyy').format(_application.dateApplied),
                    Icons.check_circle,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        const SizedBox(width: 20),
                        Container(
                          width: 2,
                          height: 20,
                          color: AppTheme.textTertiary,
                        ),
                      ],
                    ),
                  ),
                  _buildTimelineItem(
                    'Last Updated',
                    DateFormat('MMM dd, yyyy').format(_application.dateUpdated),
                    Icons.update,
                  ),
                  if (_application.followUpDate != null) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          const SizedBox(width: 20),
                          Container(
                            width: 2,
                            height: 20,
                            color: AppTheme.textTertiary,
                          ),
                        ],
                      ),
                    ),
                    _buildTimelineItem(
                      'Follow-up',
                      DateFormat('MMM dd, yyyy')
                          .format(_application.followUpDate!),
                      Icons.alarm,
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Notes Section
            Text(
              'Notes',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (_isEditing)
              TextField(
                controller: _notesController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Add notes about this application...',
                  filled: true,
                  fillColor: AppTheme.surfaceColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.primaryYellow),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppTheme.primaryYellow,
                      width: 2,
                    ),
                  ),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _application.notes?.isEmpty ?? true
                      ? 'No notes added'
                      : _application.notes!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: (_application.notes?.isEmpty ?? true)
                        ? AppTheme.textTertiary
                        : AppTheme.textSecondary,
                  ),
                ),
              ),

            const SizedBox(height: 24),

            // Salary Section
            Text(
              'Salary Offered',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (_isEditing)
              TextField(
                controller: _salaryController,
                decoration: InputDecoration(
                  hintText: 'e.g., \$100k - \$150k',
                  filled: true,
                  fillColor: AppTheme.surfaceColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.primaryYellow),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppTheme.primaryYellow,
                      width: 2,
                    ),
                  ),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.accentGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.attach_money,
                      color: AppTheme.accentGreen,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _application.salaryOffered?.isEmpty ?? true
                            ? 'No salary information'
                            : _application.salaryOffered!,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: _application.salaryOffered?.isEmpty ?? true
                              ? AppTheme.textTertiary
                              : AppTheme.accentGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 32),

            // Action Buttons
            if (_isEditing)
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _updateApplication,
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
                          : const Text('Save Changes'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() => _isEditing = false);
                        _notesController.text = _application.notes ?? '';
                        _salaryController.text =
                            _application.salaryOffered ?? '';
                        _selectedStatus = _application.status;
                      },
                      child: const Text('Cancel'),
                    ),
                  ),
                ],
              )
            else
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _launchUrl(_application.applyLink?.isEmpty ?? true
                      ? 'https://www.example.com'
                      : _application.applyLink!),
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('View Application'),
                ),
              ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primaryYellow, size: 20),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textTertiary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
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

  Color _getStatusColor(String status) {
    switch (status) {
      case Application.statusApplied:
        return const Color(0xFF4CAF50);
      case Application.statusInterviewScheduled:
        return const Color(0xFFFFC107);
      case Application.statusInterviewCompleted:
        return const Color(0xFF2196F3);
      case Application.statusOffer:
        return const Color(0xFFFF9800);
      case Application.statusRejected:
        return const Color(0xFFF44336);
      default:
        return AppTheme.textTertiary;
    }
  }

  void _launchUrl(String url) {
    // In a real app, you'd use url_launcher package
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening: $url'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

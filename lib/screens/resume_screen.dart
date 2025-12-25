import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../providers/job_provider.dart';

import '../theme/app_theme.dart';
import 'package:intl/intl.dart';

class ResumeScreen extends StatefulWidget {
  const ResumeScreen({super.key});

  @override
  State<ResumeScreen> createState() => _ResumeScreenState();
}

class _ResumeScreenState extends State<ResumeScreen> {
  bool _isUploading = false;

  Future<void> _pickAndUploadResume() async {
    setState(() {
      _isUploading = true;
    });

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
      );

      if (result != null) {
        final platformFile = result.files.single;
        final provider = Provider.of<JobProvider>(context, listen: false);

        // Upload resume via provider
        await provider.uploadResume(platformFile);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Resume uploaded successfully')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error uploading resume: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final resumes = Provider.of<JobProvider>(context).resumes;

    return Scaffold(
      backgroundColor: AppTheme.darkTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('My Resumes'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: resumes.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.description_outlined,
                    size: 64,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No resumes uploaded yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey[400]),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _isUploading ? null : _pickAndUploadResume,
                    icon: _isUploading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.upload_file),
                    label: const Text('Upload Resume'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryYellow,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: resumes.length,
              itemBuilder: (context, index) {
                final resume = resumes[index];
                return Dismissible(
                  key: Key(resume.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (direction) {
                    Provider.of<JobProvider>(
                      context,
                      listen: false,
                    ).deleteResume(resume.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Resume deleted')),
                    );
                  },
                  child: Card(
                    color: AppTheme.cardBackground,
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryYellow.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.description,
                          color: AppTheme.primaryYellow,
                        ),
                      ),
                      title: Text(
                        resume.fileName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      subtitle: Text(
                        'Uploaded on ${DateFormat.yMMMd().format(resume.uploadDate)}',
                        style: TextStyle(color: Colors.grey[400]),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: 'Find Matches',
                            icon: const Icon(
                              Icons.saved_search,
                              color: AppTheme.primaryYellow,
                            ),
                            onPressed: () {
                              Provider.of<JobProvider>(
                                context,
                                listen: false,
                              ).searchJobsWithResume(resume.id);
                              // Go back to Jobs Screen (which is assumed to be the home/previous route)
                              Navigator.of(context).pop();
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.grey),
                            onPressed: () {
                              Provider.of<JobProvider>(
                                context,
                                listen: false,
                              ).deleteResume(resume.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Resume deleted')),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: resumes.isNotEmpty
          ? FloatingActionButton(
              onPressed: _isUploading ? null : _pickAndUploadResume,
              backgroundColor: AppTheme.primaryYellow,
              child: const Icon(Icons.add, color: Colors.black),
            )
          : null,
    );
  }
}

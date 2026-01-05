import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/job_model.dart';
import '../models/user_model.dart';
import '../models/resume_model.dart';
import '../models/application_model.dart';
import '../models/insight_model.dart';
import '../services/api_service.dart';
import '../services/secure_storage_service.dart';
import '../utils/exceptions.dart';

class JobProvider with ChangeNotifier {
  List<Job> _jobs = [];
  List<Job> _savedJobs = [];
  List<Job> _appliedJobs = [];

  // User and Resume State
  User? _currentUser;
  List<Resume> _resumes = [];

  // Application and Insight State
  List<Application> _applications = [];
  InsightSummary? _insightSummary;

  bool _isLoading = false;
  String? _error;
  ServerBusyException? _serverBusyError;

  // Pagination properties
  int _currentPage = 1;
  int _totalPages = 1;
  bool _hasNext = false;
  bool _hasPrevious = false;
  int _total = 0;

  // Filter properties
  String _searchQuery = '';
  final List<String> _selectedLocations = [];
  final List<String> _selectedSkills = [];
  String? _selectedCategory;
  final List<String> _selectedSources = [];
  String? _selectedResumeId;

  // SharedPreferences instance
  SharedPreferences? _prefs;

  // Constructor - initialize persistent storage
  JobProvider() {
    _initializeStorage();
  }

  // Getters
  List<Job> get jobs => _jobs;
  List<Job> get savedJobs => _savedJobs;
  List<Job> get appliedJobs => _appliedJobs;
  User? get currentUser => _currentUser;
  List<Resume> get resumes => _resumes;
  List<Application> get applications => _applications;
  InsightSummary? get insightSummary => _insightSummary;
  bool get isLoading => _isLoading;
  String? get error => _error;
  ServerBusyException? get serverBusyError => _serverBusyError;
  String get searchQuery => _searchQuery;
  List<String> get selectedLocations => _selectedLocations;
  List<String> get selectedSkills => _selectedSkills;
  String? get selectedCategory => _selectedCategory;
  List<String> get selectedSources => _selectedSources;
  String? get selectedResumeId => _selectedResumeId;

  // Pagination getters
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  bool get hasNext => _hasNext;
  bool get hasPrevious => _hasPrevious;
  int get total => _total;

  // Initialize storage and load saved data
  Future<void> _initializeStorage() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      await _loadSavedJobs();
      await _loadAppliedJobs();
    } catch (e) {
      debugPrint('Error initializing storage: $e');
    }
  }

  // Load saved jobs from API
  Future<void> _loadSavedJobs() async {
    if (_currentUser == null) return;
    try {
      _savedJobs = await ApiService.getSavedJobs(userId: _currentUser!.id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading saved jobs: $e');
    }
  }

  // Load applied jobs from SharedPreferences (Keeping local for now since no API mentioned for fetching applied list specifically beyond stats)
  // Actually, we should probably fetch from API if available, but let's stick to existing pattern or if API exists?
  // listApplications exists in ApiService. Let's use that.
  Future<void> _loadAppliedJobs() async {
    // Replaced by loadApplications
  }

  // Save saved jobs - Now handles API calls
  Future<void> toggleSaveJob(Job job) async {
    if (_currentUser == null) return;

    final isSaved = isJobSaved(job);

    // Optimistic update
    if (isSaved) {
      _savedJobs.removeWhere((savedJob) => savedJob.id == job.id);
    } else {
      _savedJobs.add(job);
    }
    notifyListeners();

    try {
      if (isSaved) {
        await ApiService.unsaveJob(jobId: job.id, userId: _currentUser!.id);
      } else {
        await ApiService.saveJob(jobId: job.id, userId: _currentUser!.id);
      }
    } catch (e) {
      // Revert on error
      if (isSaved) {
        _savedJobs.add(job);
      } else {
        _savedJobs.removeWhere((savedJob) => savedJob.id == job.id);
      }
      notifyListeners();
      debugPrint('Error toggling saved job: $e');
      rethrow;
    }
  }

  // Notifications
  List<Map<String, dynamic>> _notifications = [];
  List<Map<String, dynamic>> get notifications => _notifications;

  Future<void> loadNotifications() async {
    if (_currentUser == null) return;
    try {
      _notifications = await ApiService.getNotifications(_currentUser!.id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading notifications: $e');
    }
  }

  // Resume Advice
  Future<Map<String, dynamic>> getResumeAdvice(
    int jobId,
    String resumeId,
  ) async {
    try {
      final result = await ApiService.getAdvice(
        jobId: jobId,
        resumeId: int.parse(resumeId),
      );
      return {
        'advice': result['advice'] as String,
        'ats_score': result['ats_score'] as String?,
      };
    } catch (e) {
      rethrow;
    }
  }

  // Delete Resume
  Future<void> deleteResume(String resumeId) async {
    try {
      await ApiService.deleteResume(int.parse(resumeId));
      _resumes.removeWhere((r) => r.id == resumeId);
      notifyListeners();
    } catch (e) {
      debugPrint("Failed to delete resume: $e");
      rethrow;
    }
  }

  // Common skills for chips
  List<String> get availableSkills => [
    "python",
    "java",
    "c++",
    "c#",
    "javascript",
    "typescript",
    "react",
    "angular",
    "vue",
    "go",
    "node",
    "express",
    "spring",
    "django",
    "flask",
    "sql",
    "postgresql",
    "mysql",
    "mongodb",
    "redis",
    "docker",
    "kubernetes",
    "aws",
    "azure",
    "gcp",
    "terraform",
    "spark",
    "hadoop",
    "pandas",
    "numpy",
    "scikit-learn",
    "tensorflow",
    "pytorch",
    "mlops",
    "git",
    "graphql",
  ];

  // Load jobs from API or mock data
  Future<void> loadJobs({bool refresh = false, int? page}) async {
    if (_isLoading && !refresh) return;

    // Ensure storage is initialized
    if (_prefs == null) {
      await _initializeStorage();
    }

    // If page is provided, use it, otherwise use current page or default to 1
    final targetPage = page ?? _currentPage;

    _isLoading = true;
    _error = null;
    _serverBusyError = null;
    notifyListeners();

    try {
      final response = await ApiService.getJobs(
        query: _searchQuery.isNotEmpty ? _searchQuery : null,
        location: _selectedLocations.isNotEmpty
            ? _selectedLocations.join(',')
            : null,
        skills: _selectedSkills.isNotEmpty ? _selectedSkills.join(',') : null,
        category: _selectedCategory,
        source: _selectedSources.isNotEmpty ? _selectedSources.join(',') : null,
        resumeId: _selectedResumeId,
        page: targetPage,
        limit: 50,
      );

      _jobs = response.jobs;
      _currentPage = response.page;
      _totalPages = response.totalPages;
      _hasNext = response.hasNext;
      _hasPrevious = response.hasPrevious;
      _total = response.total;
    } on ServerBusyException catch (e) {
      _serverBusyError = e;
      debugPrint('Server busy: $e');
    } catch (e) {
      debugPrint('Error loading jobs: $e');
      if (e.toString().contains('Network error')) {
        _error = 'Please check your internet connection and try again.';
      } else if (e.toString().contains('Failed to load jobs')) {
        _error = 'Unable to fetch jobs from server. Please try again later.';
      } else {
        _error = 'An unexpected error occurred. Please try again.';
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update search filters
  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void toggleLocationFilter(String location) {
    if (_selectedLocations.contains(location)) {
      _selectedLocations.remove(location);
    } else {
      _selectedLocations.add(location);
    }
    notifyListeners();
  }

  void toggleSkillFilter(String skill) {
    if (_selectedSkills.contains(skill)) {
      _selectedSkills.remove(skill);
    } else {
      _selectedSkills.add(skill);
    }
    notifyListeners();
  }

  void updateCategoryFilter(String? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void toggleSourceFilter(String source) {
    if (_selectedSources.contains(source)) {
      _selectedSources.remove(source);
    } else {
      _selectedSources.add(source);
    }
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedLocations.clear();
    _selectedSkills.clear();
    _selectedCategory = null;
    _selectedSources.clear();
    _selectedResumeId = null;
    _currentPage = 1; // Reset to first page when clearing filters
    notifyListeners();
  }

  // Resume Similarity Search
  Future<void> searchJobsWithResume(String resumeId) async {
    _selectedResumeId = resumeId;
    _currentPage = 1;
    await loadJobs(refresh: true, page: 1);
  }

  void clearResumeFilter() async {
    _selectedResumeId = null;
    _currentPage = 1;
    await loadJobs(refresh: true, page: 1);
  }

  // Search with current filters
  Future<void> searchJobs() async {
    _currentPage = 1; // Reset to first page when searching
    await loadJobs(refresh: true, page: 1);
  }

  // Pagination methods
  Future<void> goToNextPage() async {
    if (_hasNext) {
      await loadJobs(page: _currentPage + 1);
    }
  }

  Future<void> goToPreviousPage() async {
    if (_hasPrevious) {
      await loadJobs(page: _currentPage - 1);
    }
  }

  // Available location options for suggestions
  List<String> get availableLocations => [
    'india',
    'mumbai',
    'navi mumbai',
    'bangalore',
    'bengaluru',
    'pune',
    'noida',
    'kochi',
    'hyderabad',
    'chennai',
    'delhi',
    'kolkata',
    'remote',
    'usa',
  ];

  // Available source options
  List<String> get availableSources => [
    'greenhouse',
    'lever',
    'jooble',
    'remotive',
    'workday',
    'serpapi:google_jobs:india',
  ];

  bool isJobSaved(Job job) {
    return _savedJobs.any((savedJob) => savedJob.id == job.id);
  }

  // Applied jobs management
  void markJobAsApplied(Job job) {
    if (!isJobApplied(job)) {
      _appliedJobs.add(job);
      // We don't necessarily save it (unlike before), but we can if desired.
      // _saveAppliedJobs(); // Keeping it simpler since API tracks application

      // Also track in API if user is logged in
      if (_currentUser != null) {
        _trackApplicationInAPI(job);
      }

      notifyListeners();
    }
  }

  /// Track application in API (fire and forget)
  void _trackApplicationInAPI(Job job) {
    if (_currentUser == null) return;

    // Fire and forget - don't block UI
    ApiService.createApplication(
      userId: _currentUser!.id,
      jobId: job.id,
      status: 'applied',
    ).catchError((e) {
      debugPrint('Error tracking application in API: $e');
      return <String, dynamic>{};
    });
  }

  bool isJobApplied(Job job) {
    return _appliedJobs.any((appliedJob) => appliedJob.id == job.id);
  }

  // Get job by ID
  Job? getJobById(int id) {
    try {
      return _jobs.firstWhere((job) => job.id == id);
    } catch (e) {
      return null;
    }
  }

  // Run cron job to refresh jobs on server
  Future<bool> runCronJob() async {
    try {
      final result = await ApiService.runCronJob();
      if (result['status'] == 'success') {
        debugPrint('Cron job completed successfully: ${result['message']}');
        return true;
      } else {
        debugPrint('Cron job failed: ${result['message']}');
        return false;
      }
    } catch (e) {
      debugPrint('Error running cron job: $e');
      return false;
    }
  }

  // User Management
  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 1. Try to login
      try {
        _currentUser = await ApiService.login(username, password);
      } catch (e) {
        if (e.toString().contains('User not found') ||
            e.toString().contains('404')) {
          // 2. User not found, so register them (Auto-registration)
          _currentUser = await ApiService.register(
            username,
            password,
            '$username@example.com',
          );
        } else {
          // Other error (wrong password, server error, etc.)
          rethrow;
        }
      }

      await loadUserResumes();
      await _loadSavedJobs(); // Load saved jobs on login

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Set current user directly (used in onboarding)
  void setCurrentUser(User user) {
    _currentUser = user;
    notifyListeners();
  }

  Future<void> loadUserResumes() async {
    if (_currentUser == null) return;
    try {
      _resumes = await ApiService.getResumes(_currentUser!.id);
      notifyListeners();
    } catch (e) {
      debugPrint("Failed to load resumes: $e");
    }
  }

  void logout() {
    _currentUser = null;
    SecureStorageService.clearAuthData();
    notifyListeners();
  }

  /// Restore user from secure storage (called on app startup)
  Future<void> restoreUserFromStorage() async {
    try {
      final userId = await SecureStorageService.getUserId();
      if (userId != null && userId.isNotEmpty) {
        // Create a basic user object with the stored ID
        // In a real app, you might fetch full user details from the server
        _currentUser = User(
          id: userId,
          username: await SecureStorageService.getEmail() ?? 'User',
          email: await SecureStorageService.getEmail() ?? '',
        );
        await loadUserResumes();
        await _loadSavedJobs();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error restoring user from storage: $e');
    }
  }

  // Resume Management
  Future<void> uploadResume(dynamic platformFile) async {
    if (_currentUser == null) return;

    try {
      final Resume newResume = await ApiService.uploadResume(
        userId: _currentUser!.id,
        filePath: platformFile.path,
        fileBytes: platformFile.bytes,
        fileName: platformFile.name,
      );

      _resumes.add(newResume);
      notifyListeners();
    } catch (e) {
      debugPrint("Upload failed: $e");
      rethrow;
    }
  }

  // ==================== APPLICATION METHODS ====================

  /// Load applications from the API
  Future<void> loadApplications({bool refresh = false}) async {
    if (_isLoading && !refresh) return;

    _isLoading = true;
    _error = null;
    _serverBusyError = null;
    notifyListeners();

    try {
      if (_currentUser == null) {
        throw Exception('User not logged in');
      }

      final response = await ApiService.listApplications(
        userId: _currentUser!.id,
      );

      _applications = response.applications;
      _isLoading = false;
      notifyListeners();
    } on ServerBusyException catch (e) {
      _serverBusyError = e;
      _isLoading = false;
      debugPrint('Server busy: $e');
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      debugPrint('Error loading applications: $e');
      notifyListeners();
    }
  }

  /// Create a new application (supports both internal and external applications)
  Future<void> createApplication({
    int? jobId,
    String status = 'applied',
    String? jobTitle,
    String? companyName,
    String? jobUrl,
    String? salaryOffered,
    String? notes,
  }) async {
    if (_currentUser == null) {
      throw Exception('User not logged in');
    }

    try {
      await ApiService.createApplication(
        userId: _currentUser!.id,
        jobId: jobId,
        status: status,
        jobTitle: jobTitle,
        companyName: companyName,
        jobUrl: jobUrl,
        salaryOffered: salaryOffered,
        notes: notes,
      );

      // Reload applications after creating
      await loadApplications(refresh: true);
    } catch (e) {
      _error = e.toString();
      debugPrint('Error creating application: $e');
      notifyListeners();
      rethrow;
    }
  }

  /// Update an application
  Future<void> updateApplication({
    required int applicationId,
    String? status,
    String? notes,
    String? salaryOffered,
    DateTime? followUpDate,
  }) async {
    if (_currentUser == null) {
      throw Exception('User not logged in');
    }

    try {
      await ApiService.updateApplication(
        applicationId: applicationId,
        userId: _currentUser!.id,
        status: status,
        notes: notes,
        salaryOffered: salaryOffered,
        followUpDate: followUpDate,
      );

      // Update local state
      final index = _applications.indexWhere((app) => app.id == applicationId);
      if (index != -1) {
        final updatedApp = _applications[index];
        _applications[index] = Application(
          id: updatedApp.id,
          userId: updatedApp.userId,
          jobId: updatedApp.jobId,
          jobTitle: updatedApp.jobTitle,
          companyName: updatedApp.companyName,
          status: status ?? updatedApp.status,
          dateApplied: updatedApp.dateApplied,
          dateUpdated: DateTime.now(),
          notes: notes ?? updatedApp.notes,
          salaryOffered: salaryOffered ?? updatedApp.salaryOffered,
          followUpDate: followUpDate ?? updatedApp.followUpDate,
          applyLink: updatedApp.applyLink,
          jobDescription: updatedApp.jobDescription,
        );
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('Error updating application: $e');
      notifyListeners();
      rethrow;
    }
  }

  /// Delete an application
  Future<void> deleteApplication(int applicationId) async {
    if (_currentUser == null) {
      throw Exception('User not logged in');
    }

    try {
      await ApiService.deleteApplication(
        applicationId: applicationId,
        userId: _currentUser!.id,
      );

      _applications.removeWhere((app) => app.id == applicationId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      debugPrint('Error deleting application: $e');
      notifyListeners();
      rethrow;
    }
  }

  // ==================== INSIGHT METHODS ====================

  /// Load insight summary from the API
  Future<void> loadInsightSummary() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (_currentUser == null) {
        throw Exception('User not logged in');
      }

      _insightSummary = await ApiService.getInsightSummary(
        userId: _currentUser!.id,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      debugPrint('Error loading insights: $e');
      notifyListeners();
    }
  }

  /// Get application stats
  Future<ApplicationStats> getApplicationStats() async {
    if (_currentUser == null) {
      throw Exception('User not logged in');
    }

    return await ApiService.getApplicationStats(userId: _currentUser!.id);
  }
}

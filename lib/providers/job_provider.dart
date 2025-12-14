import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/job_model.dart';
import '../services/api_service.dart';

class JobProvider with ChangeNotifier {
  List<Job> _jobs = [];
  List<Job> _savedJobs = [];
  List<Job> _appliedJobs = [];
  bool _isLoading = false;
  String? _error;

  // Pagination properties
  int _currentPage = 1;
  int _totalPages = 1;
  bool _hasNext = false;
  bool _hasPrevious = false;
  int _total = 0;

  // Filter properties
  String _searchQuery = '';
  List<String> _selectedLocations = [];
  List<String> _selectedSkills = [];
  String? _selectedCategory;
  List<String> _selectedSources = [];

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
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  List<String> get selectedLocations => _selectedLocations;
  List<String> get selectedSkills => _selectedSkills;
  String? get selectedCategory => _selectedCategory;
  List<String> get selectedSources => _selectedSources;

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

  // Load saved jobs from SharedPreferences
  Future<void> _loadSavedJobs() async {
    try {
      final List<String>? savedJobsJson = _prefs?.getStringList('saved_jobs');
      if (savedJobsJson != null) {
        _savedJobs = savedJobsJson
            .map((jobJson) => Job.fromJson(json.decode(jobJson)))
            .toList();
      }
    } catch (e) {
      debugPrint('Error loading saved jobs: $e');
    }
  }

  // Load applied jobs from SharedPreferences
  Future<void> _loadAppliedJobs() async {
    try {
      final List<String>? appliedJobsJson = _prefs?.getStringList(
        'applied_jobs',
      );
      if (appliedJobsJson != null) {
        _appliedJobs = appliedJobsJson
            .map((jobJson) => Job.fromJson(json.decode(jobJson)))
            .toList();
      }
    } catch (e) {
      debugPrint('Error loading applied jobs: $e');
    }
  }

  // Save saved jobs to SharedPreferences
  Future<void> _saveSavedJobs() async {
    try {
      final List<String> savedJobsJson = _savedJobs
          .map((job) => json.encode(job.toJson()))
          .toList();
      await _prefs?.setStringList('saved_jobs', savedJobsJson);
    } catch (e) {
      debugPrint('Error saving saved jobs: $e');
    }
  }

  // Save applied jobs to SharedPreferences
  Future<void> _saveAppliedJobs() async {
    try {
      final List<String> appliedJobsJson = _appliedJobs
          .map((job) => json.encode(job.toJson()))
          .toList();
      await _prefs?.setStringList('applied_jobs', appliedJobsJson);
    } catch (e) {
      debugPrint('Error saving applied jobs: $e');
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
    notifyListeners();

    try {
      // Try to load from API first, fallback to mock data
      try {
        final response = await ApiService.getJobs(
          query: _searchQuery.isNotEmpty ? _searchQuery : null,
          location: _selectedLocations.isNotEmpty
              ? _selectedLocations.join(',')
              : null,
          skills: _selectedSkills.isNotEmpty ? _selectedSkills.join(',') : null,
          category: _selectedCategory,
          source: _selectedSources.isNotEmpty
              ? _selectedSources.join(',')
              : null,
          page: targetPage,
          limit: 50,
        );

        _jobs = response.jobs;
        _currentPage = response.page;
        _totalPages = response.totalPages;
        _hasNext = response.hasNext;
        _hasPrevious = response.hasPrevious;
        _total = response.total;
      } catch (apiError) {
        // Fallback to mock data if API fails
        debugPrint('API failed, using mock data: $apiError');
        _jobs = ApiService.getMockJobs();

        // Apply filters to mock data
        _jobs = _applyFiltersToMockData(_jobs);

        // Set mock pagination values
        _currentPage = 1;
        _totalPages = 1;
        _hasNext = false;
        _hasPrevious = false;
        _total = _jobs.length;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Apply filters to mock data
  List<Job> _applyFiltersToMockData(List<Job> jobs) {
    return jobs.where((job) {
      // Search query filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!job.title.toLowerCase().contains(query) &&
            !job.desc.toLowerCase().contains(query) &&
            !job.companyName.toLowerCase().contains(query)) {
          return false;
        }
      }

      // Location filter
      if (_selectedLocations.isNotEmpty) {
        if (job.location == null) {
          return false;
        }
        final jobLocation = job.location!.toLowerCase();
        if (!_selectedLocations.any(
          (loc) => jobLocation.contains(loc.toLowerCase()),
        )) {
          return false;
        }
      }

      // Skills filter
      if (_selectedSkills.isNotEmpty) {
        final jobSkills = job.skillsList.map((s) => s.toLowerCase()).toList();
        if (!_selectedSkills.any(
          (skill) => jobSkills.any(
            (jobSkill) => jobSkill.contains(skill.toLowerCase()),
          ),
        )) {
          return false;
        }
      }

      // Category filter
      if (_selectedCategory != null && _selectedCategory!.isNotEmpty) {
        if (job.category?.toLowerCase() != _selectedCategory!.toLowerCase()) {
          return false;
        }
      }

      // Source filter
      if (_selectedSources.isNotEmpty) {
        if (!_selectedSources.any(
          (source) => job.source.toLowerCase() == source.toLowerCase(),
        )) {
          return false;
        }
      }

      return true;
    }).toList();
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
    _currentPage = 1; // Reset to first page when clearing filters
    notifyListeners();
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
  ];

  // Saved jobs management
  void toggleSaveJob(Job job) {
    if (isJobSaved(job)) {
      _savedJobs.removeWhere((savedJob) => savedJob.id == job.id);
    } else {
      _savedJobs.add(job);
    }
    _saveSavedJobs(); // Save to persistent storage
    notifyListeners();
  }

  bool isJobSaved(Job job) {
    return _savedJobs.any((savedJob) => savedJob.id == job.id);
  }

  // Applied jobs management
  void markJobAsApplied(Job job) {
    if (!isJobApplied(job)) {
      _appliedJobs.add(job);
      // Also save the job if not already saved
      if (!isJobSaved(job)) {
        _savedJobs.add(job);
        _saveSavedJobs(); // Save to persistent storage
      }
      _saveAppliedJobs(); // Save to persistent storage
      notifyListeners();
    }
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
}

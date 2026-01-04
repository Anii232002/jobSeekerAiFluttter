import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../models/job_model.dart';
import '../models/user_model.dart';
import '../models/resume_model.dart';
import '../models/application_model.dart';
import '../models/insight_model.dart';
import '../utils/exceptions.dart';

class ApiService {
  // TODO: Replace with actual backend URL
  static const String baseUrl = 'http://13.60.231.101:8000';
  static const Duration _timeout = Duration(seconds: 15);

  /// Helper method to perform HTTP GET requests with timeout
  static Future<http.Response> _getWithRetry(Uri url) async {
    try {
      return await http.get(url).timeout(_timeout);
    } on TimeoutException {
      throw Exception('RETRY_TIMEOUT');
    }
  }

  /// Helper method to perform HTTP POST requests with timeout
  static Future<http.Response> _postWithRetry(
    Uri url, {
    Map<String, String>? headers,
    dynamic body,
  }) async {
    try {
      return await http
          .post(url, headers: headers, body: body)
          .timeout(_timeout);
    } on TimeoutException {
      throw Exception('RETRY_TIMEOUT');
    }
  }

  /// Helper method to perform HTTP PATCH requests with timeout
  static Future<http.Response> _patchWithRetry(
    Uri url, {
    Map<String, String>? headers,
    dynamic body,
  }) async {
    try {
      return await http
          .patch(url, headers: headers, body: body)
          .timeout(_timeout);
    } on TimeoutException {
      throw Exception('RETRY_TIMEOUT');
    }
  }

  static Future<PaginatedJobResponse> getJobs({
    String? query,
    String? location,
    String? skills,
    String? category,
    String? source,
    String? resumeId,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final Map<String, String> queryParams = {};

      if (query != null && query.isNotEmpty) queryParams['q'] = query;
      if (location != null && location.isNotEmpty) {
        queryParams['location'] = location;
      }
      if (skills != null && skills.isNotEmpty) queryParams['skills'] = skills;
      if (category != null && category.isNotEmpty) {
        queryParams['category'] = category;
      }
      if (source != null && source.isNotEmpty) queryParams['source'] = source;
      if (resumeId != null && resumeId.isNotEmpty) {
        queryParams['resume_id'] = resumeId;
      }
      queryParams['page'] = page.toString();
      queryParams['limit'] = limit.toString();
      print("==> ${queryParams.toString()}");

      final uri = Uri.parse(
        '$baseUrl/jobs/',
      ).replace(queryParameters: queryParams);

      final response = await _getWithRetry(uri);
      print("==> Full URL: ${uri.toString()}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        return PaginatedJobResponse.fromJson(jsonResponse);
      } else {
        throw Exception('Failed to load jobs: ${response.statusCode}');
      }
    } on Exception catch (e) {
      if (e.toString().contains('RETRY_TIMEOUT')) {
        throw ServerBusyException();
      }
      throw Exception('Network error: $e');
    }
  }

  static Future<Job> getJob(int jobId) async {
    try {
      final response = await _getWithRetry(Uri.parse('$baseUrl/jobs/$jobId'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        return Job.fromJson(json);
      } else {
        throw Exception('Failed to load job: ${response.statusCode}');
      }
    } on Exception catch (e) {
      if (e.toString().contains('RETRY_TIMEOUT')) {
        throw ServerBusyException();
      }
      throw Exception('Network error: $e');
    }
  }

  static Future<bool> checkHealth() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/'));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<Map<String, dynamic>> runCronJob() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/jobs/cron'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> result = json.decode(response.body);
        return result;
      } else {
        throw Exception('Failed to run cron job: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<User> login(String username, String password) async {
    try {
      final response = await _postWithRetry(
        Uri.parse('$baseUrl/users/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      if (response.statusCode == 200) {
        return User.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 404 || response.statusCode == 401) {
        throw Exception(
          'User not found',
        ); // Specific message for provider to catch
      } else {
        throw Exception('Login failed: ${response.body}');
      }
    } on Exception catch (e) {
      if (e.toString().contains('RETRY_TIMEOUT')) {
        throw ServerBusyException();
      }
      throw Exception('$e');
    }
  }

  static Future<User> register(
    String username,
    String password,
    String email,
  ) async {
    try {
      final response = await _postWithRetry(
        Uri.parse('$baseUrl/users/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
          'email': email,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return User.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Registration failed: ${response.body}');
      }
    } on Exception catch (e) {
      if (e.toString().contains('RETRY_TIMEOUT')) {
        throw ServerBusyException();
      }
      throw Exception('Network error: $e');
    }
  }

  static Future<Resume> uploadResume({
    required String userId,
    String? filePath,
    List<int>? fileBytes,
    required String fileName,
  }) async {
    try {
      final uri = Uri.parse(
        '$baseUrl/resumes/upload',
      ); // request.fields handle user_id
      final request = http.MultipartRequest('POST', uri);

      // Add user_id to fields
      request.fields['user_id'] = userId;

      if (fileBytes != null) {
        // Web / Bytes provided
        request.files.add(
          http.MultipartFile.fromBytes('file', fileBytes, filename: fileName),
        );
      } else if (filePath != null) {
        // Mobile/Desktop
        request.files.add(
          await http.MultipartFile.fromPath(
            'file',
            filePath,
            filename: fileName,
          ),
        );
      } else {
        throw Exception('No file data provided');
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        return Resume.fromJson(jsonResponse);
      } else {
        throw Exception('Failed to upload resume: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<List<Resume>> getResumes(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/resumes/?user_id=$userId'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => Resume.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load resumes');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Mock data for testing when backend is not available
  static List<Job> getMockJobs() {
    return [
      Job(
        id: 1,
        title: "Product Designer",
        desc:
            "We are looking for a talented Product Designer to join our team. You will be responsible for creating user-centered designs that solve complex problems and delight our users.",
        createdAt: "2025-09-23T10:30:00",
        applyLink: "https://spotify.com/careers/product-designer",
        source: "spotify",
        externalId: "spotify-pd-001",
        imageUrl: null,
        salary: "\$2 - \$5k/Month",
        location: "USA, Canada",
        keywords: "design, ui, ux, figma",
        skills: "figma, sketch, prototyping",
        category: "senior",
        companyNameField: "Spotify",
      ),
      Job(
        id: 2,
        title: "Copy Writer",
        desc:
            "Join our content team as a Copy Writer. You'll create compelling copy that engages our audience and drives conversions across various platforms.",
        createdAt: "2025-09-23T09:15:00",
        applyLink: "https://netflix.com/careers/copy-writer",
        source: "netflix",
        externalId: "netflix-cw-002",
        imageUrl: null,
        salary: "\$3 - \$6k/Month",
        location: "UK, London",
        keywords: "writing, content, marketing",
        skills: "copywriting, content strategy, seo",
        category: "mid",
        companyNameField: "Netflix",
      ),
      Job(
        id: 3,
        title: "Game Developer",
        desc:
            "Exciting opportunity to work on cutting-edge games. You'll be developing game mechanics, implementing features, and optimizing performance.",
        createdAt: "2025-09-23T08:45:00",
        applyLink: "https://steam.com/careers/game-developer",
        source: "steam",
        externalId: "steam-gd-003",
        imageUrl: null,
        salary: "\$4 - \$8k/Month",
        location: "Remote",
        keywords: "game development, unity, c#",
        skills: "unity, c#, game design",
        category: "senior",
        companyNameField: "Steam Games",
      ),
      Job(
        id: 4,
        title: "Frontend Developer",
        desc:
            "We're seeking a skilled Frontend Developer to build responsive and interactive web applications using modern frameworks.",
        createdAt: "2025-09-23T07:30:00",
        applyLink: "https://google.com/careers/frontend-developer",
        source: "google",
        externalId: "google-fd-004",
        imageUrl: null,
        salary: "\$5 - \$9k/Month",
        location: "San Francisco, CA",
        keywords: "frontend, react, javascript",
        skills: "react, javascript, typescript, css",
        category: "mid",
        companyNameField: "Google",
      ),
      Job(
        id: 5,
        title: "Data Scientist",
        desc:
            "Join our data team to extract insights from large datasets and build machine learning models that drive business decisions.",
        createdAt: "2025-09-23T06:00:00",
        applyLink: "https://microsoft.com/careers/data-scientist",
        source: "microsoft",
        externalId: "microsoft-ds-005",
        imageUrl: null,
        salary: "\$6 - \$12k/Month",
        location: "Seattle, WA",
        keywords: "data science, python, machine learning",
        skills: "python, sql, machine learning, statistics",
        category: "senior",
        companyNameField: "Microsoft",
      ),
    ];
  }

  // ==================== APPLICATION TRACKING ENDPOINTS ====================

  static Future<Map<String, dynamic>> createApplication({
    required String userId,
    int? jobId,
    String status = 'applied',
    String? jobTitle,
    String? companyName,
    String? jobUrl,
    String? salaryOffered,
    String? notes,
  }) async {
    try {
      // Build query parameters
      final Map<String, String> queryParams = {'user_id': userId};

      // For internal applications (job_id provided)
      if (jobId != null) {
        queryParams['job_id'] = jobId.toString();
      } else {
        // For external applications (job_id is null)
        // company_name and job_title are required as query params
        if (companyName != null && companyName.isNotEmpty) {
          queryParams['company_name'] = companyName;
        }
        if (jobTitle != null && jobTitle.isNotEmpty) {
          queryParams['job_title'] = jobTitle;
        }
      }

      // Build request body with optional fields
      final body = <String, dynamic>{'status': status};
      if (jobUrl != null) body['job_url'] = jobUrl;
      if (salaryOffered != null) body['salary_offered'] = salaryOffered;
      if (notes != null) body['notes'] = notes;

      final uri = Uri.parse(
        '$baseUrl/applications/',
      ).replace(queryParameters: queryParams);

      final response = await _postWithRetry(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to create application: ${response.statusCode}');
      }
    } on Exception catch (e) {
      if (e.toString().contains('RETRY_TIMEOUT')) {
        throw ServerBusyException();
      }
      throw Exception('Network error: $e');
    }
  }

  static Future<ApplicationResponse> listApplications({
    required String userId,
    String? status,
    String? sortBy,
  }) async {
    try {
      final Map<String, String> queryParams = {'user_id': userId};
      if (status != null && status.isNotEmpty) queryParams['status'] = status;
      if (sortBy != null && sortBy.isNotEmpty) queryParams['sort_by'] = sortBy;

      final uri = Uri.parse(
        '$baseUrl/applications/',
      ).replace(queryParameters: queryParams);

      final response = await _getWithRetry(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        return ApplicationResponse.fromJson(jsonResponse);
      } else {
        throw Exception('Failed to list applications: ${response.statusCode}');
      }
    } on Exception catch (e) {
      if (e.toString().contains('RETRY_TIMEOUT')) {
        throw ServerBusyException();
      }
      throw Exception('Network error: $e');
    }
  }

  static Future<Application> getApplication({
    required int applicationId,
    required String userId,
  }) async {
    try {
      final response = await _getWithRetry(
        Uri.parse('$baseUrl/applications/$applicationId?user_id=$userId'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        return Application.fromJson(json);
      } else {
        throw Exception('Failed to get application: ${response.statusCode}');
      }
    } on Exception catch (e) {
      if (e.toString().contains('RETRY_TIMEOUT')) {
        throw ServerBusyException();
      }
      throw Exception('Network error: $e');
    }
  }

  static Future<Map<String, dynamic>> updateApplication({
    required int applicationId,
    required String userId,
    String? status,
    String? notes,
    String? salaryOffered,
    DateTime? followUpDate,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (status != null) body['status'] = status;
      if (notes != null) body['notes'] = notes;
      if (salaryOffered != null) body['salary_offered'] = salaryOffered;
      if (followUpDate != null)
        body['follow_up_date'] = followUpDate.toIso8601String();

      final response = await _patchWithRetry(
        Uri.parse('$baseUrl/applications/$applicationId?user_id=$userId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to update application: ${response.statusCode}');
      }
    } on Exception catch (e) {
      if (e.toString().contains('RETRY_TIMEOUT')) {
        throw ServerBusyException();
      }
      throw Exception('Network error: $e');
    }
  }

  static Future<Map<String, dynamic>> deleteApplication({
    required int applicationId,
    required String userId,
  }) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/applications/$applicationId?user_id=$userId'),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to delete application: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<ApplicationStats> getApplicationStats({
    required String userId,
  }) async {
    try {
      final response = await _getWithRetry(
        Uri.parse('$baseUrl/applications/stats/summary?user_id=$userId'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        return ApplicationStats.fromJson(json);
      } else {
        throw Exception(
          'Failed to get application stats: ${response.statusCode}',
        );
      }
    } on Exception catch (e) {
      if (e.toString().contains('RETRY_TIMEOUT')) {
        throw ServerBusyException();
      }
      throw Exception('Network error: $e');
    }
  }

  // ==================== INSIGHT ENDPOINTS ====================

  static Future<InsightSummary> getInsightSummary({
    required String userId,
  }) async {
    try {
      final response = await _getWithRetry(
        Uri.parse('$baseUrl/insights/summary?user_id=$userId'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        return InsightSummary.fromJson(json);
      } else {
        throw Exception(
          'Failed to get insight summary: ${response.statusCode}',
        );
      }
    } on Exception catch (e) {
      if (e.toString().contains('RETRY_TIMEOUT')) {
        throw ServerBusyException();
      }
      throw Exception('Network error: $e');
    }
  }

  static Future<InsightStats> getInsightStats({required String userId}) async {
    try {
      final response = await _getWithRetry(
        Uri.parse('$baseUrl/insights/stats?user_id=$userId'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        return InsightStats.fromJson(json);
      } else {
        throw Exception('Failed to get insight stats: ${response.statusCode}');
      }
    } on Exception catch (e) {
      if (e.toString().contains('RETRY_TIMEOUT')) {
        throw ServerBusyException();
      }
      throw Exception('Network error: $e');
    }
  }

  static Future<List<Skill>> getTopSkills({
    required String userId,
    int limit = 10,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/insights/skills?user_id=$userId&limit=$limit'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        final List<dynamic> skillsList = json['skills'];
        return skillsList.map((s) => Skill.fromJson(s)).toList();
      } else {
        throw Exception('Failed to get top skills: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<List<Company>> getTopCompanies({
    required String userId,
    int limit = 10,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/insights/companies?user_id=$userId&limit=$limit'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        final List<dynamic> companiesList = json['companies'];
        return companiesList.map((c) => Company.fromJson(c)).toList();
      } else {
        throw Exception('Failed to get top companies: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<List<Location>> getTopLocations({
    required String userId,
    int limit = 10,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/insights/locations?user_id=$userId&limit=$limit'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        final List<dynamic> locationsList = json['locations'];
        return locationsList.map((l) => Location.fromJson(l)).toList();
      } else {
        throw Exception('Failed to get top locations: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // ==================== SAVED JOBS ENDPOINTS ====================

  static Future<Map<String, dynamic>> saveJob({
    required int jobId,
    required String userId,
  }) async {
    try {
      final response = await _postWithRetry(
        Uri.parse('$baseUrl/saved_jobs/$jobId?user_id=$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to save job: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<void> unsaveJob({
    required int jobId,
    required String userId,
  }) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/saved_jobs/$jobId?user_id=$userId'),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to unsave job: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<List<Job>> getSavedJobs({required String userId}) async {
    try {
      final response = await _getWithRetry(
        Uri.parse('$baseUrl/saved_jobs/?user_id=$userId'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        // Map the response to Job objects.
        // Note: The backend returns a structure with job_title, etc.
        // We might need to adjust this if we want full Job objects.
        // For now, assuming the backend returns simplified objects,
        // but if we want full job cards, we might need a dedicated model or mapper.
        // Let's assume the frontend Job model can handle it or we map manually.

        return jsonList.map((json) {
          // Mapping simplified saved job response to Job model for UI compatibility
          // This assumes the backend returns enough info or we fetch details later.
          // Based on the backend code, it returns:
          // {id, user_id, job_id, created_at, job_title, job_company}
          // We'll construct a minimal Job object.
          return Job(
            id: json['job_id'],
            title: json['job_title'],
            companyNameField: json['job_company'],
            desc: '', // Not returned by list endpoint
            applyLink: '', // Not returned
            source: 'saved',
            externalId: json['job_id'].toString(), // Use job_id as fallback
            createdAt: json['created_at'],
            location: '',
          );
        }).toList();
      } else {
        throw Exception('Failed to load saved jobs');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // ==================== ADVICE ENDPOINTS ====================

  static Future<Map<String, dynamic>> getAdvice({
    required int jobId,
    required int resumeId,
  }) async {
    try {
      final response = await _postWithRetry(
        Uri.parse('$baseUrl/advice/job/$jobId?resume_id=$resumeId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 400) {
        throw Exception("RESUME_TEXT_MISSING");
      } else {
        throw Exception('Failed to get advice: ${response.statusCode}');
      }
    } catch (e) {
      if (e.toString().contains("RESUME_TEXT_MISSING")) rethrow;
      throw Exception('Network error: $e');
    }
  }

  // ==================== RESUME ENDPOINTS ====================

  static Future<void> deleteResume(int resumeId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/resumes/$resumeId'),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete resume: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // ==================== NOTIFICATION ENDPOINTS ====================

  static Future<List<Map<String, dynamic>>> getNotifications(
    String userId,
  ) async {
    try {
      final response = await _getWithRetry(
        Uri.parse('$baseUrl/notifications/?user_id=$userId'),
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load notifications');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}

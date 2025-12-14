import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/job_model.dart';

class ApiService {
  // TODO: Replace with actual backend URL
  static const String baseUrl = 'http://16.170.239.29:8000';

  static Future<PaginatedJobResponse> getJobs({
    String? query,
    String? location,
    String? skills,
    String? category,
    String? source,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final Map<String, String> queryParams = {};

      if (query != null && query.isNotEmpty) queryParams['q'] = query;
      if (location != null && location.isNotEmpty)
        queryParams['location'] = location;
      if (skills != null && skills.isNotEmpty) queryParams['skills'] = skills;
      if (category != null && category.isNotEmpty)
        queryParams['category'] = category;
      if (source != null && source.isNotEmpty) queryParams['source'] = source;
      queryParams['page'] = page.toString();
      queryParams['limit'] = limit.toString();
      print("==> ${queryParams.toString()}");

      final uri = Uri.parse(
        '$baseUrl/jobs/',
      ).replace(queryParameters: queryParams);
      final response = await http.get(uri);
      print("==> Full URL: ${uri.toString()}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        return PaginatedJobResponse.fromJson(jsonResponse);
      } else {
        throw Exception('Failed to load jobs: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<Job> getJob(int jobId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/jobs/$jobId'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        return Job.fromJson(json);
      } else {
        throw Exception('Failed to load job: ${response.statusCode}');
      }
    } catch (e) {
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
}

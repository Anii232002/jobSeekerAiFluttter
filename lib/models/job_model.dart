class Job {
  final int id;
  final String title;
  final String desc;
  final String createdAt;
  final String applyLink;
  final String source;
  final String externalId;
  final String? imageUrl;
  final String? salary;
  final String? location;
  final String? keywords;
  final String? skills;
  final String? category;
  final String? companyNameField;
  final double? matchScore;

  Job({
    required this.id,
    required this.title,
    required this.desc,
    required this.createdAt,
    required this.applyLink,
    required this.source,
    required this.externalId,
    this.imageUrl,
    this.salary,
    this.location,
    this.keywords,
    this.skills,
    this.category,
    this.companyNameField,
    this.matchScore,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: json['id'],
      title: json['title'],
      desc: json['desc'],
      createdAt: json['created_at'],
      applyLink: json['apply_link'],
      source: json['source'],
      externalId: json['external_id'],
      imageUrl: json['image_url'],
      salary: json['salary'],
      location: json['location'],
      keywords: json['keywords'],
      skills: json['skills'],
      category: json['category'],
      companyNameField: json['company_name'],
      matchScore: json['match_score'] != null
          ? (json['match_score'] as num).toDouble()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'desc': desc,
      'created_at': createdAt,
      'apply_link': applyLink,
      'source': source,
      'external_id': externalId,
      'image_url': imageUrl,
      'salary': salary,
      'location': location,
      'keywords': keywords,
      'skills': skills,
      'category': category,
      'company_name': companyNameField,
      'match_score': matchScore,
    };
  }

  List<String> get skillsList {
    if (skills == null || skills!.isEmpty) return [];
    return skills!.split(',').map((skill) => skill.trim()).toList();
  }

  List<String> get keywordsList {
    if (keywords == null || keywords!.isEmpty) return [];
    return keywords!.split(',').map((keyword) => keyword.trim()).toList();
  }

  // Get company name from API field or fallback to source
  String get companyName {
    // Use the company_name field from API if available
    if (companyNameField != null && companyNameField!.isNotEmpty) {
      return companyNameField!;
    }

    // Fallback to formatting the source field
    return source
        .replaceAll('_', ' ')
        .split(' ')
        .map(
          (word) => word.isNotEmpty
              ? word[0].toUpperCase() + word.substring(1).toLowerCase()
              : '',
        )
        .join(' ');
  }

  // Get formatted category for display
  String get displayCategory {
    if (category == null) return '';
    switch (category!.toLowerCase()) {
      case 'early':
        return 'Entry Level';
      case 'mid':
        return 'Mid Level';
      case 'senior':
        return 'Senior Level';
      default:
        return category!;
    }
  }
}

// Paginated response model for API
class PaginatedJobResponse {
  final List<Job> jobs;
  final int total;
  final int page;
  final int limit;
  final int totalPages;
  final bool hasNext;
  final bool hasPrevious;

  PaginatedJobResponse({
    required this.jobs,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrevious,
  });

  factory PaginatedJobResponse.fromJson(Map<String, dynamic> json) {
    return PaginatedJobResponse(
      jobs: (json['jobs'] as List).map((job) => Job.fromJson(job)).toList(),
      total: json['total'],
      page: json['page'],
      limit: json['limit'],
      totalPages: json['total_pages'],
      hasNext: json['has_next'],
      hasPrevious: json['has_previous'],
    );
  }
}

class Application {
  final int id;
  final int userId;
  final int? jobId;
  final String jobTitle;
  final String companyName;
  final String status;
  final DateTime dateApplied;
  final DateTime dateUpdated;
  final String? notes;
  final String? salaryOffered;
  final DateTime? followUpDate;
  final String? applyLink;
  final String? jobDescription;

  Application({
    required this.id,
    required this.userId,
    this.jobId,
    required this.jobTitle,
    required this.companyName,
    required this.status,
    required this.dateApplied,
    required this.dateUpdated,
    this.notes,
    this.salaryOffered,
    this.followUpDate,
    this.applyLink,
    this.jobDescription,
  });

  // Status enum for better type safety
  static const String statusApplied = 'applied';
  static const String statusInterviewScheduled = 'interview_scheduled';
  static const String statusInterviewCompleted = 'interview_completed';
  static const String statusOffer = 'offer';
  static const String statusRejected = 'rejected';

  // Get display text for status
  String get statusDisplay {
    switch (status) {
      case statusApplied:
        return 'Applied';
      case statusInterviewScheduled:
        return 'Interview Scheduled';
      case statusInterviewCompleted:
        return 'Interview Completed';
      case statusOffer:
        return 'Offer Received';
      case statusRejected:
        return 'Rejected';
      default:
        return status;
    }
  }

  // Get emoji for status
  String get statusEmoji {
    switch (status) {
      case statusApplied:
        return '🟢';
      case statusInterviewScheduled:
        return '🟡';
      case statusInterviewCompleted:
        return '🔵';
      case statusOffer:
        return '🟠';
      case statusRejected:
        return '🔴';
      default:
        return '⚪';
    }
  }

  // Format date as relative time
  String get relativeDate {
    final now = DateTime.now();
    final difference = now.difference(dateApplied);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks week${weeks > 1 ? 's' : ''} ago';
    } else {
      final months = (difference.inDays / 30).floor();
      return '$months month${months > 1 ? 's' : ''} ago';
    }
  }

  factory Application.fromJson(Map<String, dynamic> json) {
    return Application(
      id: json['id'],
      userId: json['user_id'],
      jobId: json['job_id'],
      jobTitle: json['job_title'],
      companyName: json['company_name'],
      status: json['status'],
      dateApplied: DateTime.parse(json['date_applied']),
      dateUpdated: DateTime.parse(json['date_updated']),
      notes: json['notes'],
      salaryOffered: json['salary_offered'],
      followUpDate: json['follow_up_date'] != null
          ? DateTime.parse(json['follow_up_date'])
          : null,
      applyLink: json['apply_link'],
      jobDescription: json['job_description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'job_id': jobId,
      'job_title': jobTitle,
      'company_name': companyName,
      'status': status,
      'date_applied': dateApplied.toIso8601String(),
      'date_updated': dateUpdated.toIso8601String(),
      'notes': notes,
      'salary_offered': salaryOffered,
      'follow_up_date': followUpDate?.toIso8601String(),
      'apply_link': applyLink,
      'job_description': jobDescription,
    };
  }
}

class ApplicationResponse {
  final List<Application> applications;
  final int total;
  final Map<String, int> statusBreakdown;

  ApplicationResponse({
    required this.applications,
    required this.total,
    required this.statusBreakdown,
  });

  factory ApplicationResponse.fromJson(Map<String, dynamic> json) {
    return ApplicationResponse(
      applications: (json['applications'] as List)
          .map((app) => Application.fromJson(app))
          .toList(),
      total: json['total'],
      statusBreakdown: Map<String, int>.from(json['status_breakdown'] ?? {}),
    );
  }
}

class ApplicationStats {
  final int totalApplications;
  final int totalInterviews;
  final int totalOffers;
  final int totalRejected;
  final double interviewRate;
  final double offerRate;

  ApplicationStats({
    required this.totalApplications,
    required this.totalInterviews,
    required this.totalOffers,
    required this.totalRejected,
    required this.interviewRate,
    required this.offerRate,
  });

  factory ApplicationStats.fromJson(Map<String, dynamic> json) {
    return ApplicationStats(
      totalApplications: json['total_applications'],
      totalInterviews: json['total_interviews'],
      totalOffers: json['total_offers'],
      totalRejected: json['total_rejected'],
      interviewRate: (json['interview_rate'] as num).toDouble(),
      offerRate: (json['offer_rate'] as num).toDouble(),
    );
  }
}

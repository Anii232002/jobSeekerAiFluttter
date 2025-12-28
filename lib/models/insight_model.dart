class Skill {
  final String skill;
  final int count;
  final int rank;

  Skill({
    required this.skill,
    required this.count,
    required this.rank,
  });

  factory Skill.fromJson(Map<String, dynamic> json) {
    return Skill(
      skill: json['skill'],
      count: json['count'],
      rank: json['rank'],
    );
  }
}

class Company {
  final String company;
  final int count;
  final int rank;

  Company({
    required this.company,
    required this.count,
    required this.rank,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      company: json['company'],
      count: json['count'],
      rank: json['rank'],
    );
  }
}

class Location {
  final String location;
  final int count;
  final int rank;

  Location({
    required this.location,
    required this.count,
    required this.rank,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      location: json['location'],
      count: json['count'],
      rank: json['rank'],
    );
  }
}

class InsightStats {
  final int totalApplications;
  final int totalInterviews;
  final double interviewRate;
  final int totalOffers;
  final double offerRate;

  InsightStats({
    required this.totalApplications,
    required this.totalInterviews,
    required this.interviewRate,
    required this.totalOffers,
    required this.offerRate,
  });

  factory InsightStats.fromJson(Map<String, dynamic> json) {
    return InsightStats(
      totalApplications: json['total_applications'],
      totalInterviews: json['total_interviews'],
      interviewRate: (json['interview_rate'] as num).toDouble(),
      totalOffers: json['total_offers'],
      offerRate: (json['offer_rate'] as num).toDouble(),
    );
  }
}

class InsightSummary {
  final String status;
  final InsightStats stats;
  final List<Skill> skills;
  final List<Company> companies;
  final List<Location> locations;

  InsightSummary({
    required this.status,
    required this.stats,
    required this.skills,
    required this.companies,
    required this.locations,
  });

  factory InsightSummary.fromJson(Map<String, dynamic> json) {
    return InsightSummary(
      status: json['status'],
      stats: InsightStats.fromJson(json['stats']),
      skills: (json['skills'] as List).map((s) => Skill.fromJson(s)).toList(),
      companies:
          (json['companies'] as List).map((c) => Company.fromJson(c)).toList(),
      locations:
          (json['locations'] as List).map((l) => Location.fromJson(l)).toList(),
    );
  }
}

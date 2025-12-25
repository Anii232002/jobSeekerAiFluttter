class Resume {
  final String id;
  final String userId;
  final String fileName;
  final String? filePath; // Path on device (mobile)
  final List<int>? fileBytes; // Bytes (web)
  final DateTime uploadDate;

  Resume({
    required this.id,
    required this.userId,
    required this.fileName,
    this.filePath,
    this.fileBytes,
    required this.uploadDate,
  });

  factory Resume.fromJson(Map<String, dynamic> json) {
    return Resume(
      id: json['id'].toString(),
      userId: json['user_id'].toString(),
      fileName: json['filename'] ?? 'Unknown',
      filePath: json['filepath'],
      uploadDate: json['created_at'] != null
          ? DateTime.tryParse(json['created_at']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'filename': fileName,
      'filepath': filePath,
      'created_at': uploadDate.toIso8601String(),
    };
  }
}

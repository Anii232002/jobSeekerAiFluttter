class User {
  final String id;
  final String username;
  final String? email;

  User({required this.id, required this.username, this.email});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'].toString(), // Handle int or string id
      username: json['username'] ?? '',
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'username': username, 'email': email};
  }
}

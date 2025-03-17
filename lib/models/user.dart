import 'dart:convert';

class User {
  final String id;
  final String name;
  final String email;
  final String token;
   String password;
   String? profilePicture; // optional (nullable)
   String? bio;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.token,
    required this.password,
    this.profilePicture, // ✅ No longer required
    this.bio,
  });

  // ✅ Bio Getter
  // String get safeBio => bio ?? "Write a bio already!";
  

  String get safeBio => bio ?? "Write a bio already!";
  set safeBio(String value) => bio = value;

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'token': token,
      'password': password,
      'profile_picture': profilePicture, // ✅ Match API field
      'bio': safeBio,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['_id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      token: map['token'] ?? '',
      password: map['password'] ?? '',
      profilePicture: map['profile_picture'], // ✅ Handle profile_picture
      bio: map['bio'],
    );
  }

  String toJson() => json.encode(toMap());

  factory User.fromJson(String source) => User.fromMap(json.decode(source));
}
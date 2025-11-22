class UserModel {
  final String id;
  final String fullname;
  final String email;
  final String? bio;
  final String? imageUrl;
  final String gender;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.fullname,
    required this.email,
    this.bio,
    this.imageUrl,
    required this.gender,
    required this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['uid'] as String,
      fullname: map['fullname'] as String,
      email: map['email'] as String,
      bio: map['bio'] as String?,
      imageUrl: map['imageurl'] as String?,
      gender: map['gender'] as String,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : DateTime.now(),
    );
  }
}

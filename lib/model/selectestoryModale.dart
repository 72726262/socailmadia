class Story {
  final String id;
  final String userId;
  final String imageUrl;
  final DateTime createdAt;
  final DateTime expiresAt;
  final String userName;
  final String userImage;

  Story({
    required this.id,
    required this.userId,
    required this.imageUrl,
    required this.createdAt,
    required this.expiresAt,
    required this.userName,
    required this.userImage,
  });

  factory Story.fromMap(Map<String, dynamic> map) {
    return Story(
      id: map['id'].toString(),
      userId: map['user_id'] ?? "",
      imageUrl: map['image_url'] ?? "",
      createdAt: DateTime.parse(map['created_at']),
      expiresAt: DateTime.parse(map['expires_at']),
      userName: map['userName'] ?? "Unknown User",
      userImage:
          map['userImage'] ?? "https://i.ibb.co/2y8dHjG/default-avatar.png",
    );
  }
}

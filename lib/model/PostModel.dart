class Post {
  final int id;
  final String userId;
  final String content;
  final String? imageUrl;
  final String? imageuser;
  final String? userName;
  final DateTime createdAt;
  int likesCount; // ⬅️ غير final عشان يتعدل
  int commentsCount; // ⬅️ غير final عشان يتعدل
  final List<String> likedBy;

  Post({
    required this.id,
    required this.userId,
    required this.content,
    this.imageUrl,
    required this.createdAt,
    required this.likesCount, // ⬅️ غير required
    required this.commentsCount, // ⬅️ غير required
    required this.likedBy,
    this.imageuser,
    this.userName,
  });

  // إضافة دالة لتحديث الإحصائيات
  Post copyWith({int? likesCount, int? commentsCount, List<String>? likedBy}) {
    return Post(
      id: id,
      userId: userId,
      content: content,
      imageUrl: imageUrl,
      createdAt: createdAt,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      likedBy: likedBy ?? this.likedBy,
      imageuser: imageuser,
      userName: userName,
    );
  }

  factory Post.fromMap(Map<String, dynamic> map) {
    return Post(
      id: map['id'],
      userId: map['user_id'] ?? "",
      content: map['contenttext'] ?? "",
      imageUrl: map['image_url'],
      createdAt: DateTime.parse(map['created_at']),
      likesCount: map['likes_count'] ?? 0,
      commentsCount: map['comments_count'] ?? 0,
      likedBy: List<String>.from(map['liked_by'] ?? []),
      imageuser: map["imageuser"],
      userName: map["username"],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "user_id": userId,
      "contenttext": content,
      "image_url": imageUrl,
      "likes_count": likesCount,
      "comments_count": commentsCount,
      "liked_by": likedBy,
      "imageuser": imageuser,
      "userName": userName,
    };
  }
}

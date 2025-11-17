class Comment {
  final int id;
  final int postId;
  final String userId;
  final String content;
  final DateTime createdAt;
  final String fullname;
  final String? userimage;

  Comment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.content,
    required this.createdAt,
    required this.fullname,
    required this.userimage,
  });

  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      id: map['id'],
      postId: map['post_id'],
      userId: map['user_id'],
      content: map['contenttext'] ?? "",
      createdAt: DateTime.parse(map['created_at']),
      fullname: map["fullname"] ?? "User",
      userimage: map["userimage"],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "post_id": postId,
      "user_id": userId,
      "contenttext": content,
      "fullname": fullname,
      "userimage": userimage,
    };
  }
}

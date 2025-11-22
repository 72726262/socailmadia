class NotificationModel {
  final int id;
  final String type; // 'like', 'comment', 'follow'
  final String senderId;
  final String receiverId;
  final int? postId;
  final int? commentId;
  final String senderName;
  final String senderImage;
  final String? postImage;
  final DateTime createdAt;
  final bool isRead;

  NotificationModel({
    required this.id,
    required this.type,
    required this.senderId,
    required this.receiverId,
    this.postId,
    this.commentId,
    required this.senderName,
    required this.senderImage,
    this.postImage,
    required this.createdAt,
    required this.isRead,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'],
      type: map['type'],
      senderId: map['sender_id'],
      receiverId: map['receiver_id'],
      postId: map['post_id'], // تم تصحيح النوع
      commentId: map['comment_id'], // تم تصحيح النوع
      senderName: map['sender_name'] ?? 'User',
      senderImage: map['sender_image'] ?? '',
      postImage: map['post_image'],
      createdAt: DateTime.parse(map['created_at']),
      isRead: map['is_read'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'sender_id': senderId,
      'receiver_id': receiverId,
      'post_id': postId,
      'comment_id': commentId,
      'sender_name': senderName,
      'sender_image': senderImage,
      'post_image': postImage,
      'is_read': isRead,
    };
  }
}

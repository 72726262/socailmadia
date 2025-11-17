class seelcteMassagesusers {
  final int id;
  final String sender_id;
  final String receiver_id;
  final String message_text;
  final String created_at;
  final String chat_id;
  final String image;

  seelcteMassagesusers({
    required this.id,
    required this.sender_id,
    required this.receiver_id,
    required this.message_text,
    required this.created_at,
    required this.chat_id,
    required this.image,
  });

  // Factory لتحويل Map إلى Object من النوع ProductModel
  factory seelcteMassagesusers.fromMap(Map<String, dynamic> map) {
    return seelcteMassagesusers(
      id: map['id'],
      sender_id: map['sender_id'],
      receiver_id: map['receiver_id'],
      message_text: map['message_text'],
      created_at: map['created_at'],
      chat_id: map['chat_id'],
      image: map['image'],
    );
  }
}

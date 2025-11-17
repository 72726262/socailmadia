class SelectUsermodale {
  final int id;
  final String email;
  final String name;
  final String image;
  final String datetime;
  final String type;
  final String uid;

  SelectUsermodale({
    required this.id,
    required this.email,
    required this.name,
    required this.image,
    required this.datetime,
    required this.type,
    required this.uid,
  });

  factory SelectUsermodale.fromMap(Map<String, dynamic> map) {
    return SelectUsermodale(
      id: map["id"],
      email: map['email'] ?? '',
      name: map['fullname'] ?? '',
      uid: map["uid"],
      image: map['image'] ?? '',
      datetime: map["datetime"] ?? '',
      type: map["type"] ?? '',
    );
  }
}

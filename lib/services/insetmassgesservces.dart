import 'package:supabase_flutter/supabase_flutter.dart';

class Insetmassgesservces {
  Future<void> addmassages({
    required String sender_id,
    required String receiver_id,
    required String message_text,
    required String created_at,
    required String chat_id,
    required String image,
  }) async {
    try {
      await Supabase.instance.client.from("chatusers").insert({
        "sender_id": sender_id,
        "receiver_id": receiver_id,
        "message_text": message_text,
        "created_at": created_at,
        "chat_id": chat_id,
        "image": image,
      });
    } catch (e) {}
  }
}

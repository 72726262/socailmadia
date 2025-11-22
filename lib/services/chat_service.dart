import 'dart:io';
import 'package:soso/model/UserModel.dart'; // تأكد من وجود هذا النموذج
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatService {
  final SupabaseClient supabase = Supabase.instance.client; // ⬅️ غيرت لـ public

  // ⭐ إنشاء أو جلب شات بين userين
  Future<int> getOrCreateChat(String user1Id, String user2Id) async {
    try {
      // البحث عن شات موجود باستخدام query مباشر
      final existingChat =
          await supabase // ⬅️ غيرت هنا
              .from('chats')
              .select()
              .or('user1_id.eq.$user1Id,user2_id.eq.$user1Id')
              .or('user1_id.eq.$user2Id,user2_id.eq.$user2Id')
              .maybeSingle();

      if (existingChat != null) {
        return existingChat['id'];
      }

      // نعمل شات جديد
      final newChat =
          await supabase // ⬅️ غيرت هنا
              .from('chats')
              .insert({'user1_id': user1Id, 'user2_id': user2Id})
              .select()
              .single();

      return newChat['id'];
    } catch (e) {
      print('Error creating chat: $e');
      rethrow;
    }
  }

  // ⭐ إرسال رسالة
  Future<void> sendMessage({
    required int chatId,
    required String senderId,
    required String text,
    String? imageUrl,
  }) async {
    try {
      // تحديد نوع الرسالة بناءً على وجود رابط الصورة
      final messageType = imageUrl != null ? 'image' : 'text';

      await supabase.from('messages').insert({
        'chat_id': chatId,
        'sender_id': senderId,
        'message_text': text,
        'image_url': imageUrl ?? '', // ✅ إرسال نص فارغ بدلاً من null
        'message_type': messageType, // ✅ إضافة نوع الرسالة
      });

      // تحديث وقت الشات
      await supabase
          .from('chats')
          .update({'updated_at': DateTime.now().toIso8601String()})
          .eq('id', chatId);
    } catch (e) {
      print('Error sending message: $e'); // طباعة الخطأ للمساعدة في التصحيح
      rethrow;
    }
  }

  // ⭐ جلب الرسائل (Stream) - الطريقة الصحيحة
  Stream<List<Map<String, dynamic>>> getMessagesStream(int chatId) {
    return supabase // ⬅️ غيرت هنا
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('chat_id', chatId)
        .order('created_at', ascending: true)
        .map((list) => list as List<Map<String, dynamic>>);
  }

  // ⭐ جلب الـ chats للمستخدم - الطريقة الصحيحة
  Stream<List<Map<String, dynamic>>> getUserChats(String userId) {
    return supabase // ⭐ تم إرجاع الدالة لحالتها الأصلية
        .from('chats')
        .stream(primaryKey: ['id'])
        .order('updated_at', ascending: false);
  }

  // ⭐ رفع صورة للشات
  Future<String?> uploadChatImage(File imageFile) async {
    try {
      final fileName = 'chat${DateTime.now().millisecondsSinceEpoch}.jpg';

      await supabase
          .storage // ⬅️ غيرت هنا
          .from('posts')
          .upload(fileName, imageFile);

      return supabase
          .storage // ⬅️ غيرت هنا
          .from('posts')
          .getPublicUrl(fileName);
    } catch (e) {
      return null;
    }
  }

  // ⭐ جلب بيانات المستخدم الآخر في الشات
  Future<UserModel?> getChatUserInfo(int chatId, String currentUserId) async {
    try {
      final chat =
          await supabase // ⬅️ غيرت هنا
              .from('chats')
              .select()
              .eq('id', chatId)
              .single();

      final otherUserId = chat['user1_id'] == currentUserId
          ? chat['user2_id']
          : chat['user1_id'];

      final user =
          await supabase // ⬅️ غيرت هنا
              .from('users')
              .select()
              .eq('uid', otherUserId)
              .single();

      return UserModel.fromMap(user);
    } catch (e) {
      return null;
    }
  }

  // ⭐ جلب كل المستخدمين ما عدا المستخدم الحالي
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      final currentUserId = supabase.auth.currentUser!.id;
      final response = await supabase
          .from('users')
          .select()
          .neq('uid', currentUserId); // استثناء المستخدم الحالي

      return response as List<Map<String, dynamic>>;
    } catch (e) {
      return [];
    }
  }

  // ⭐ جديد: جلب مستخدم معين عن طريق ID
  Future<UserModel?> getUserById(String userId) async {
    try {
      final response = await supabase
          .from('users')
          .select()
          .eq('uid', userId)
          .single();

      return UserModel.fromMap(response);
    } catch (e) {
      return null;
    }
  }
}

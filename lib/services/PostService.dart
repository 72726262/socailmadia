import 'dart:io';

import 'package:soso/model/PostModel.dart';
import 'package:soso/services/notification_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PostService {
  final SupabaseClient supabase = Supabase.instance.client;

  // ⭐ جديد: تحديث عدد التعليقات - الطريقة الصحيحة
  Future<void> updateCommentsCount(int postId) async {
    try {
      // جلب عدد التعليقات باستخدام count
      final response = await supabase
          .from('Comments')
          .select('*')
          .eq('post_id', postId);

      // response بيكون List، وبنعدده
      final commentsCount = response.length;

      // تحديث عدد التعليقات في البوست
      await supabase
          .from('posts')
          .update({'comments_count': commentsCount})
          .eq('id', postId);
    } catch (e) {
      print("Error updating comments count: $e");
    }
  }

  // ⭐ جديد: تحديث عدد الإعجابات
  Future<void> updateLikesCount(int postId, List<String> likedBy) async {
    try {
      await supabase
          .from('posts')
          .update({'likes_count': likedBy.length, 'liked_by': likedBy})
          .eq('id', postId);
    } catch (e) {
      print("Error updating likes count: $e");
    }
  }

  // داخل class PostService أضف:
  final NotificationService _notificationService = NotificationService();

  // ⭐ تعديل دالة toggleLike لإضافة إشعار
  Future<void> toggleLike(int postId, String userId) async {
    try {
      // جلب البيانات الحالية
      final response = await supabase
          .from('posts')
          .select('liked_by, user_id, username, imageuser')
          .eq('id', postId)
          .single();

      List<dynamic> likedByDynamic = response['liked_by'] ?? [];
      List<String> likedBy = likedByDynamic.map((e) => e.toString()).toList();

      final postOwnerId = response['user_id'];
      final postOwnerName = response['username'];
      final postImage = response['imageuser'];

      if (likedBy.contains(userId)) {
        // إلغاء الإعجاب
        likedBy.remove(userId);
      } else {
        // إعجاب + إضافة إشعار
        likedBy.add(userId);

        // إشعار للمالك إن حد عجب بمنشوره
        if (userId != postOwnerId) {
          await _notificationService.addNotification(
            type: 'like',
            senderId: userId,
            receiverId: postOwnerId,
            senderName: 'User', // هنا ممكن تجيب اسم المستخدم من الـ user data
            senderImage: '', // هنا ممكن تجيب صورة المستخدم
            postId: postId.toString(),
            postImage: postImage,
          );
        }
      }

      // تحديث في الداتابيز
      await updateLikesCount(postId, likedBy);
    } catch (e) {
      print("Error toggling like: $e");
    }
  }

  // الباقي زي ما هو...
  Future<String?> uploadPostImage(File imageFile, int postId) async {
    final fileExt = imageFile.path.split('.').last;
    final filePath = 'post_images/$postId.$fileExt';

    await supabase.storage
        .from('posts')
        .upload(
          filePath,
          imageFile,
          fileOptions: FileOptions(cacheControl: '3600'),
        );

    return supabase.storage.from('posts').getPublicUrl(filePath);
  }

  // إنشاء بوست جديد
  Future<void> createPost({
    required String userId,
    required String content,
    File? imageFile,
    required String userName,
    required String imageUser,
  }) async {
    try {
      final response = await supabase
          .from('posts')
          .insert({
            "user_id": userId,
            "contenttext": content,
            "username": userName,
            "imageuser": imageUser,
            "image_url": null,
            "likes_count": 0,
            "comments_count": 0,
            "liked_by": [],
          })
          .select()
          .single();

      final int postId = response['id'];

      // رفع الصورة لو موجودة
      if (imageFile != null) {
        final imageUrl = await uploadPostImage(imageFile, postId);
        await supabase
            .from('posts')
            .update({"image_url": imageUrl})
            .eq('id', postId);
      }
    } catch (e) {
      print("Error creating post: $e");
      rethrow;
    }
  }

  // جلب كل البوستات
  Future<List<Post>> fetchPosts() async {
    final response = await supabase
        .from('posts')
        .select('*')
        .order('created_at', ascending: false);
    return response.map<Post>((data) => Post.fromMap(data)).toList();
  }

  // Stream للبث الحي
  Stream<List<Post>> getPostsStream() {
    return supabase
        .from("posts")
        .stream(primaryKey: ["id"])
        .order("created_at", ascending: false)
        .map((rows) => rows.map<Post>((data) => Post.fromMap(data)).toList());
  }
}

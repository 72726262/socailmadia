import 'dart:async';
import 'package:soso/model/PostModel.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/CommentModel.dart';
import 'notification_service.dart';
import 'PostService.dart';

class CommentService {
  final SupabaseClient supabase = Supabase.instance.client;

  /// ⭐ إضافة تعليق جديد
  Future<bool> addComment({
    required int postId,
    required String userId,
    required String content,
    required String fullname,
    required String userimage,
    required String postOwnerId, // ⭐ جديد: معرف صاحب البوست
    required String postImage, // ⭐ جديد: صورة البوست
  }) async {
    final postService = PostService();
    final notificationService = NotificationService(); // ⭐ جديد
    try {
      await supabase.from('Comments').insert({
        'post_id': postId,
        'user_id': userId,
        'contenttext': content,
        "fullname": fullname,
        "userimage": userimage,
        "postOwnerId": postOwnerId,
        "postImage": postImage,
      });

      // ⭐ جديد: تحديث عدد التعليقات في البوست
      await postService.updateCommentsCount(postId);

      // ⭐ جديد: إرسال إشعار لصاحب البوست
      await notificationService.addNotification(
        type: 'comment',
        senderId: userId,
        receiverId: postOwnerId,
        postId: postId.toString(),
        senderName: fullname,
        senderImage: userimage,
        postImage: postImage,
      );

      return true;
    } catch (e) {
      print("Error adding comment: $e");
      return false;
    }
  }

  /// ⭐ جلب Stream للتعليقات - الطريقة المحسّنة باستخدام Realtime
  Stream<List<Comment>> getCommentsStreamByPostId(int postId) {
    return supabase
        .from('Comments')
        .stream(primaryKey: ['id'])
        .eq('post_id', postId)
        .order('created_at', ascending: true)
        .map((listOfMaps) {
          // تحويل قائمة الـ Maps إلى قائمة من الـ Comment objects
          return listOfMaps.map((commentMap) {
            return Comment.fromMap(commentMap);
          }).toList();
        });
  }

  /// ⭐ جلب التعليقات من الداتابيز
  Future<List<Comment>> _getCommentsFromDB(int postId) async {
    try {
      final response = await supabase
          .from('Comments')
          .select()
          .eq('post_id', postId)
          .order('created_at', ascending: true);

      return response.map((c) => Comment.fromMap(c)).toList();
    } catch (e) {
      print("Error getting comments: $e");
      return [];
    }
  }

  Future<List<Comment>> getCommentsByPostId(int postId) async {
    return await _getCommentsFromDB(postId);
  }

  /// ⭐ حذف تعليق
  Future<bool> deleteComment(int commentId, int postId) async {
    try {
      final postService = PostService();
      await supabase.from('Comments').delete().eq('id', commentId);
      await postService.updateCommentsCount(postId); // تحديث عدد التعليقات
      return true;
    } catch (e) {
      print("Error deleting comment: $e");
      return false;
    }
  }
}

import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/CommentModel.dart';

class CommentService {
  final SupabaseClient supabase = Supabase.instance.client;

  // ⭐ خريطة لحفظ الـ Streams لكل بوست
  final Map<int, StreamController<List<Comment>>> _streamControllers = {};

  /// ⭐ إضافة تعليق جديد
  Future<bool> addComment({
    required int postId,
    required String userId,
    required String content,
    required String fullname,
    required String userimage,
  }) async {
    try {
      await supabase.from('Comments').insert({
        'post_id': postId,
        'user_id': userId,
        'contenttext': content,
        "fullname": fullname,
        "userimage": userimage,
      });
      return true;
    } catch (e) {
      print("Error adding comment: $e");
      return false;
    }
  }

  /// ⭐ جلب Stream للتعليقات - الطريقة المضمونة
  Stream<List<Comment>> getCommentsStreamByPostId(int postId) {
    // إذا فيه Stream مفتوح خلاص، نرجعه
    if (_streamControllers.containsKey(postId) &&
        !_streamControllers[postId]!.isClosed) {
      return _streamControllers[postId]!.stream;
    }

    // نفتح Stream جديد
    final controller = StreamController<List<Comment>>.broadcast();
    _streamControllers[postId] = controller;

    // دالة لتحديث البيانات
    void updateComments() async {
      try {
        final comments = await _getCommentsFromDB(postId);
        if (!controller.isClosed) {
          controller.add(comments);
        }
      } catch (e) {
        print('Error updating comments: $e');
      }
    }

    // أول تحديث فوري
    updateComments();

    // ⭐ التحديث التلقائي كل 2 ثانية - بديل الـ Realtime
    Timer.periodic(Duration(seconds: 2), (timer) {
      if (controller.isClosed) {
        timer.cancel();
        return;
      }
      updateComments();
    });

    return controller.stream;
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

  /// ⭐ جلب التعليقات بشكل عادي (بدون Stream)
  Future<List<Comment>> getCommentsByPostId(int postId) async {
    return await _getCommentsFromDB(postId);
  }

  /// ⭐ حذف تعليق
  Future<bool> deleteComment(int commentId, int postId) async {
    try {
      await supabase.from('Comments').delete().eq('id', commentId);
      return true;
    } catch (e) {
      print("Error deleting comment: $e");
      return false;
    }
  }

  /// ⭐ تنظيف الـ Streams
  void disposeStream(int postId) {
    _streamControllers[postId]?.close();
    _streamControllers.remove(postId);
  }
}

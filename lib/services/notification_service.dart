import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/NotificationModel.dart';

class NotificationService {
  final supabase = Supabase.instance.client;

  // ⭐ إضافة إشعار جديد
  Future<void> addNotification({
    required String type,
    required String senderId,
    required String receiverId,
    required String senderName,
    required String senderImage,
    String? postId,
    String? commentId,
    String? postImage,
  }) async {
    try {
      // نتأكد إن المرسل مش المستقبل (عشان ما نبعثش إشعار لنفسك)
      if (senderId == receiverId) return;

      await supabase.from('notifications').insert({
        'type': type,
        'sender_id': senderId,
        'receiver_id': receiverId,
        'post_id': postId,
        'comment_id': commentId,
        'sender_name': senderName,
        'sender_image': senderImage,
        'post_image': postImage,
        'is_read': false,
      });
    } catch (e) {
      print("Error adding notification: $e");
    }
  }

  // ⭐ جلب الإشعارات للمستخدم (Stream)
  Stream<List<NotificationModel>> getNotificationsStream(String userId) {
    return supabase
        .from('notifications')
        .stream(primaryKey: ['id'])
        .eq('receiver_id', userId)
        .order('created_at', ascending: false)
        .map(
          (data) => data.map((row) => NotificationModel.fromMap(row)).toList(),
        );
  }

  // ⭐ جلب عدد الإشعارات غير المقروءة
  Stream<int> getUnreadCountStream(String userId) {
    // ✅ أحدث وأسرع طريقة: استخدام ميزة العد المباشر (count) من Supabase Realtime
    // هذا يتطلب تحديث حزمة supabase_flutter إلى أحدث إصدار
    final channel = supabase.channel('public:notifications_count');
    return channel
        .on(
          RealtimeListenTypes.postgresChanges,
          ChannelFilter(
            event: 'COUNT',
            schema: 'public',
            table: 'notifications',
            filter: 'receiver_id=eq.$userId&is_read=eq.false',
          ),
          (payload, [ref]) {
            // 'payload' يحتوي مباشرة على العدد الجديد
            final newCount = payload['count'] as int;
            return newCount;
          },
        )
        .map((payload) {
          // هذه الخطوة ضرورية لتحويل الـ Stream إلى Stream<int>
          // قد تحتاج إلى تعديل بسيط هنا حسب نوع البيانات العائدة بالضبط
          if (payload is Map && payload.containsKey('count')) {
            return payload['count'] as int;
          }
          return 0; // قيمة افتراضية في حالة عدم وجود العدد
        });
  }

  // ⭐ تحديث الإشعار كمقروء
  Future<void> markAsRead(int notificationId) async {
    try {
      await supabase
          .from('notifications')
          .update({'is_read': true})
          .eq('id', notificationId);
    } catch (e) {
      print("Error marking notification as read: $e");
    }
  }

  // ⭐ تحديث كل الإشعارات كمقروءة
  Future<void> markAllAsRead(String userId) async {
    try {
      await supabase
          .from('notifications')
          .update({'is_read': true})
          .eq('receiver_id', userId)
          .eq('is_read', false);
    } catch (e) {
      print("Error marking all notifications as read: $e");
    }
  }

  // ⭐ حذف إشعار
  Future<void> deleteNotification(int notificationId) async {
    try {
      await supabase.from('notifications').delete().eq('id', notificationId);
    } catch (e) {
      print("Error deleting notification: $e");
    }
  }
}

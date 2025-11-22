import 'dart:async';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:soso/services/chat_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationController {
  static final NotificationController _instance =
      NotificationController._internal();

  factory NotificationController() => _instance;

  NotificationController._internal();

  final _chatService = ChatService();
  RealtimeChannel? _messagesChannel;
  String? _currentOpenChatId;

  void setCurrentOpenChat(int? chatId) {
    _currentOpenChatId = chatId?.toString();
  }

  void initialize() {
    final client = Supabase.instance.client;
    final currentUser = client.auth.currentUser;

    if (currentUser == null) return;

    // إلغاء أي اشتراك قديم
    _messagesChannel?.unsubscribe();

    // الاستماع لكل الرسائل الجديدة
    _messagesChannel = client.channel('public:messages');
    _messagesChannel!
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          callback: (payload) async {
            final newMessage = payload.newRecord;
            final senderId = newMessage['sender_id'];

            // 1. لا تظهر إشعار لرسائلك
            // 2. لا تظهر إشعار إذا كنت فاتح الشات بالفعل
            if (senderId == currentUser.id ||
                newMessage['chat_id'].toString() == _currentOpenChatId) {
              return;
            }

            // جلب بيانات مرسل الرسالة
            final sender = await _chatService.getUserById(senderId);
            if (sender == null) return;

            // عرض الإشعار
            showOverlayNotification((context) {
              return Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 60,
                ),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFFFD1D1D), // red
                      Color(0xFFC13584), // pink
                      Color(0xFF833AB4), // purple
                      Color(0xFF5851DB), // deep purple
                      Color(0xFF0099FF), // blue
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),

                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundImage: sender.imageUrl != null
                          ? NetworkImage(sender.imageUrl!)
                          : null,
                      child: sender.imageUrl == null
                          ? Text(
                              sender.fullname.isNotEmpty
                                  ? sender.fullname[0]
                                  : '?',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),

                    // النصوص
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            sender.fullname,
                            style: const TextStyle(
                              fontSize: 22,
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              decoration: TextDecoration.none,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            newMessage['message_text'] ?? 'رسالة جديدة',
                            maxLines: 2,

                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }, duration: const Duration(seconds: 4));
          },
        )
        .subscribe();
  }

  void dispose() {
    _messagesChannel?.unsubscribe();
    _currentOpenChatId = null;
  }
}

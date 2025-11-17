import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:soso/main.dart';
import 'package:soso/model/NotificationModel.dart';
import 'package:soso/services/notification_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationsDrawer extends StatefulWidget {
  const NotificationsDrawer({super.key});

  @override
  State<NotificationsDrawer> createState() => _NotificationsDrawerState();
}

class _NotificationsDrawerState extends State<NotificationsDrawer> {
  final NotificationService _notificationService = NotificationService();
  final String _currentUserId = Supabase.instance.client.auth.currentUser!.id;
  bool _isLoading = true;

  @override
  Widget build(BuildContext context) {
    bool isArabic = appLocale.value.languageCode == 'ar';

    return Drawer(
      child: Directionality(
        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
        child: Container(
          color: const Color(0xFFF8FAFF),
          child: Column(
            children: [
              // Header
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0066FF), Color(0xFF4D9FFF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 20,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.notifications,
                                  color: Colors.white,
                                  size: 28,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  isArabic ? "الإشعارات" : "Notifications",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            StreamBuilder<int>(
                              stream: _notificationService.getUnreadCountStream(
                                _currentUserId,
                              ),
                              builder: (context, snapshot) {
                                final unreadCount = snapshot.data ?? 0;
                                if (unreadCount > 0) {
                                  return GestureDetector(
                                    onTap: _markAllAsRead,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        isArabic
                                            ? "تعليم الكل كمقروء"
                                            : "Mark all read",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  );
                                }
                                return const SizedBox();
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // List of notifications
              Expanded(
                child: StreamBuilder<List<NotificationModel>>(
                  stream: _notificationService.getNotificationsStream(
                    _currentUserId,
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return _buildNotificationsSkeleton();
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return _buildEmptyNotifications(isArabic);
                    }

                    final notifications = snapshot.data!;
                    return ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: notifications.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final notification = notifications[index];
                        return _buildNotificationTile(notification, isArabic);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ⭐ بناء بطاقة الإشعار
  Widget _buildNotificationTile(NotificationModel notification, bool isArabic) {
    return GestureDetector(
      onTap: () {
        _handleNotificationTap(notification);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: notification.isRead ? Colors.white : const Color(0xFFF0F7FF),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: notification.isRead
                ? Colors.transparent
                : const Color(0xFF0066FF).withOpacity(0.2),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // صورة المرسل
            Stack(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundImage: NetworkImage(notification.senderImage),
                  backgroundColor: Colors.grey[200],
                ),
                if (!notification.isRead)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: Color(0xFF0066FF),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),

            // محتوى الإشعار
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                        height: 1.4,
                      ),
                      children: [
                        TextSpan(
                          text: notification.senderName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const TextSpan(text: " "),
                        TextSpan(
                          text: _getActionText(notification.type, isArabic),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(notification.createdAt, isArabic),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),

            // صورة البوست (لو موجودة)
            if (notification.postImage != null &&
                notification.postImage!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  notification.postImage!,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ⭐ بناء هيكل عظمي للإشعارات
  Widget _buildNotificationsSkeleton() {
    return Skeletonizer(
      enabled: true,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: 5,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(radius: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 14,
                        margin: const EdgeInsets.only(bottom: 6),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(7),
                        ),
                      ),
                      Container(
                        width: 120,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ⭐ واجهة فارغة عندما لا يوجد إشعارات
  Widget _buildEmptyNotifications(bool isArabic) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none_rounded,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            isArabic ? "لا توجد إشعارات" : "No notifications",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isArabic
                ? "سيظهر هنا الإشعارات الجديدة"
                : "New notifications will appear here",
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ⭐ الحصول على نص الإجراء حسب نوع الإشعار
  String _getActionText(String type, bool isArabic) {
    switch (type) {
      case 'like':
        return isArabic ? "أعجب بمنشورك" : "liked your post";
      case 'comment':
        return isArabic ? "علق على منشورك" : "commented on your post";
      case 'follow':
        return isArabic ? "تابعك" : "followed you";
      default:
        return isArabic ? "تفاعل مع منشورك" : "interacted with your post";
    }
  }

  // ⭐ تنسيق الوقت
  String _formatTime(DateTime time, bool isArabic) {
    final diff = DateTime.now().difference(time);

    if (diff.inMinutes < 1) return isArabic ? "الآن" : "Just now";
    if (diff.inMinutes < 60)
      return "${diff.inMinutes}${isArabic ? " دقيقة" : "m"}";
    if (diff.inHours < 24) return "${diff.inHours}${isArabic ? " ساعة" : "h"}";
    return "${diff.inDays}${isArabic ? " يوم" : "d"}";
  }

  // ⭐ التعامل مع الضغط على الإشعار
  void _handleNotificationTap(NotificationModel notification) {
    // تحديث الإشعار كمقروء
    if (!notification.isRead) {
      _notificationService.markAsRead(notification.id);
    }

    // إغلاق الدراور
    Navigator.pop(context);

    // عرض تفاصيل الإشعار
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          appLocale.value.languageCode == 'ar'
              ? "تم فتح الإشعار من ${notification.senderName}"
              : "Opened notification from ${notification.senderName}",
        ),
        backgroundColor: const Color(0xFF0066FF),
      ),
    );
  }

  // ⭐ تعليم كل الإشعارات كمقروءة
  void _markAllAsRead() {
    _notificationService.markAllAsRead(_currentUserId);
  }
}

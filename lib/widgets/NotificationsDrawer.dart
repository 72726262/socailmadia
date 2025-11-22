import 'package:flutter/material.dart';
import 'package:soso/main.dart';
import 'package:soso/model/NotificationModel.dart';
import 'package:soso/services/notification_service.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationsDrawer extends StatefulWidget {
  @override
  _NotificationsDrawerState createState() => _NotificationsDrawerState();
}

class _NotificationsDrawerState extends State<NotificationsDrawer> {
  final NotificationService _notificationService = NotificationService();
  final String _currentUserId = Supabase.instance.client.auth.currentUser!.id;

  @override
  void initState() {
    super.initState();
    // عند فتح القائمة، يتم تحديد كل الإشعارات كمقروءة
    _notificationService.markAllAsRead(_currentUserId);
  }

  @override
  Widget build(BuildContext context) {
    bool isArabic = appLocale.value.languageCode == 'ar';

    return Drawer(
      child: Column(
        children: [
          AppBar(
            title: Text(isArabic ? 'الإشعارات' : 'Notifications'),
            automaticallyImplyLeading: false,
            backgroundColor: const Color(0xFF0066FF),
            actions: [
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          Expanded(
            child: StreamBuilder<List<NotificationModel>>(
              stream: _notificationService.getNotificationsStream(
                _currentUserId,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      isArabic ? 'لا توجد إشعارات' : 'No notifications yet',
                      style: const TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  );
                }

                final notifications = snapshot.data!;

                return ListView.separated(
                  padding: EdgeInsets.zero,
                  itemCount: notifications.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
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
    );
  }

  Widget _buildNotificationTile(NotificationModel notification, bool isArabic) {
    String title = '';
    String subtitle = timeago.format(
      notification.createdAt,
      locale: isArabic ? 'ar' : 'en',
    );
    IconData iconData;

    switch (notification.type) {
      case 'like':
        title = isArabic
            ? '${notification.senderName} أعجب بمنشورك.'
            : '${notification.senderName} liked your post.';
        iconData = Icons.favorite;
        break;
      case 'comment':
        title = isArabic
            ? '${notification.senderName} علّق على منشورك.'
            : '${notification.senderName} commented on your post.';
        iconData = Icons.comment;
        break;
      default:
        title = isArabic ? 'إشعار جديد' : 'New Notification';
        iconData = Icons.notifications;
    }

    return ListTile(
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundImage: NetworkImage(notification.senderImage),
            backgroundColor: Colors.grey[200],
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                iconData,
                size: 16,
                color: notification.type == 'like' ? Colors.red : Colors.blue,
              ),
            ),
          ),
        ],
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: Colors.grey, fontSize: 12),
      ),
      trailing: notification.postImage != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                notification.postImage!,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 50,
                    height: 50,
                    color: Colors.grey[200],
                    child: const Icon(
                      Icons.hide_image_outlined,
                      color: Colors.grey,
                    ),
                  );
                },
              ),
            )
          : null,
      onTap: () {
        // يمكنك هنا إضافة منطق للانتقال إلى المنشور عند الضغط على الإشعار
        print('Tapped on notification for post ID: ${notification.postId}');
      },
    );
  }
}

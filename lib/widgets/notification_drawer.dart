import 'package:flutter/material.dart';
import 'package:soso/main.dart';
import 'package:soso/model/NotificationModel.dart';
import 'package:soso/services/PostService.dart';
import 'package:soso/services/notification_service.dart';

import 'package:soso/views/homepage/CommentsScreen.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationDrawer extends StatefulWidget {
  const NotificationDrawer({super.key});

  @override
  State<NotificationDrawer> createState() => _NotificationDrawerState();
}

class _NotificationDrawerState extends State<NotificationDrawer> {
  late final Stream<List<NotificationModel>> _notificationsStream;

  @override
  void initState() {
    super.initState();
    final userId = Supabase.instance.client.auth.currentUser!.id;
    _notificationsStream = NotificationService().getNotificationsStream(userId);
  }

  @override
  Widget build(BuildContext context) {
    bool isArabic = appLocale.value.languageCode == 'ar';

    return Drawer(
      child: Column(
        children: [
          AppBar(
            title: Text(isArabic ? 'الإشعارات' : 'Notifications'),
            automaticallyImplyLeading: false, // لإخفاء زر الرجوع
            backgroundColor: const Color(0xFF0066FF),
            titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
          ),
          Expanded(
            child: StreamBuilder<List<NotificationModel>>(
              stream: _notificationsStream,
              builder: (context, snapshot) {
                // الحالة 1: انتظار البيانات -> عرض الواجهة الهيكلية
                if (snapshot.connectionState == ConnectionState.waiting &&
                    !snapshot.hasData) {
                  return _buildNotificationsSkeleton();
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.notifications_off_outlined,
                          size: 60,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          isArabic
                              ? 'لا توجد إشعارات جديدة'
                              : 'No new notifications',
                        ),
                      ],
                    ),
                  );
                }

                final notifications = snapshot.data!;
                return ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notification = notifications[index];
                    return NotificationListItem(notification: notification);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // دالة لبناء الواجهة الهيكلية للإشعارات
  Widget _buildNotificationsSkeleton() {
    return Skeletonizer(
      enabled: true,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 8, // عرض 8 عناصر هيكلية
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Row(
              children: [
                const CircleAvatar(radius: 28),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // استبدال Bone.text بـ Container
                      Container(
                        width: MediaQuery.of(context).size.width * 0.4,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 100,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // استبدال Bone.box بـ Container ليمثل الصورة
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey,
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
}

class NotificationListItem extends StatelessWidget {
  final NotificationModel notification;

  const NotificationListItem({super.key, required this.notification});

  Future<void> _handleNotificationTap(BuildContext context) async {
    if (notification.postId == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final postService = PostService();
      final postData = await postService.getPostById(notification.postId!);
      Navigator.of(context, rootNavigator: true).pop();

      if (postData != null) {
        final profileData = postData['profiles'] as Map<String, dynamic>?;
        postData['userimage'] = profileData?['avatar_url'];
        postData['fullname'] = postData['username'];

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => CommentsScreen(post: postData),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('لم يتم العثور على المنشور')),
        );
      }
    } catch (e) {
      Navigator.of(context, rootNavigator: true).pop();
      print("Error handling tap: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isArabic = appLocale.value.languageCode == 'ar';
    String message = notification.type == 'like'
        ? (isArabic ? 'أعجب بمنشورك' : 'liked your post')
        : (isArabic ? 'علّق على منشورك' : 'commented on your post');

    return ListTile(
      leading: CircleAvatar(
        radius: 28,
        backgroundImage: NetworkImage(notification.senderImage),
      ),
      title: Text('${notification.senderName} $message'),
      subtitle: Text(
        _formatTime(notification.createdAt, isArabic),
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
              ),
            )
          : null,
      onTap: () => _handleNotificationTap(context),
    );
  }

  String _formatTime(DateTime time, bool isArabic) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return isArabic ? "الآن" : "Just now";
    if (diff.inMinutes < 60) return "${diff.inMinutes}${isArabic ? " د" : "m"}";
    if (diff.inHours < 24) return "${diff.inHours}${isArabic ? " س" : "h"}";
    return "${diff.inDays}${isArabic ? " ي" : "d"}";
  }
}

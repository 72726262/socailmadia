import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:soso/model/PostModel.dart';
import 'package:soso/model/selectUsermodeale.dart';
import 'package:soso/model/selectestoryModale.dart';
import 'package:soso/services/PostService.dart';
import 'package:soso/services/addstorys.dart';
import 'package:soso/services/notification_service.dart';
import 'package:soso/services/selecteusers.dart';
import 'package:soso/services/selectstoryservice.dart';
import 'package:soso/views/homepage/CommentsScreen.dart';
import 'package:soso/widgets/NotificationsDrawer.dart';
import 'package:soso/widgets/UserStoryViewer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeContent extends StatefulWidget {
  HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String? username;
  String? userimage;
  int unreadNotifications = 3;

  // ⭐ جديد: حفظ البيانات القديمة
  List<Post> _cachedPosts = [];
  List<Story> _cachedStories = [];
  final NotificationService _notificationService = NotificationService();
  final String _currentUserId = Supabase.instance.client.auth.currentUser!.id;
  @override
  Widget build(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;

    return Scaffold(
      key: _scaffoldKey,
      drawer: NotificationsDrawer(),
      body: Padding(
        padding: EdgeInsets.fromLTRB(15, 12, 16, 80),
        child: Column(
          children: [
            // ---------------- Header ----------------
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                StreamBuilder<SelectUsermodale?>(
                  stream: Selecteuserssereverse().getuser(),
                  builder: (context, snapshot) {
                    final isLoading =
                        snapshot.connectionState == ConnectionState.waiting;
                    final user = snapshot.data;

                    if (user == null) {
                      return const SizedBox.shrink();
                    }

                    username = user.name;
                    userimage = user.image;

                    return Skeletonizer(
                      enabled: isLoading,
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundImage: NetworkImage(user.image),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.name,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
                // أيقونة الإشعارات مع عداد
                // الكود الجديد للإشعارات
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    IconButton(
                      onPressed: () {
                        _scaffoldKey.currentState?.openDrawer();
                      },
                      icon: const Icon(Icons.notifications, size: 30),
                    ),
                    StreamBuilder<int>(
                      stream: _notificationService.getUnreadCountStream(
                        _currentUserId,
                      ),
                      builder: (context, snapshot) {
                        final unreadCount = snapshot.data ?? 0;
                        if (unreadCount > 0) {
                          return Positioned(
                            right: 4,
                            top: 4,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 20,
                                minHeight: 20,
                              ),
                              child: Center(
                                child: Text(
                                  unreadCount > 9
                                      ? "9+"
                                      : "$unreadCount", // ⬅️ رقم حيوي
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
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
              ],
            ),

            const SizedBox(height: 20),

            // ---------------- Scrollable Body ----------------
            Expanded(
              child: ListView(
                children: [
                  // ---------------- Stories Horizontal ----------------
                  SizedBox(
                    height: 90,
                    child: StreamBuilder<List<Story>>(
                      stream: StoryService().getStoriesStream(),
                      builder: (context, snapshot) {
                        final isLoading =
                            snapshot.connectionState == ConnectionState.waiting;

                        // ⭐ استخدام البيانات المخزنة أو الجديدة
                        List<Story> storiesToShow = _cachedStories;

                        if (snapshot.hasData) {
                          storiesToShow = snapshot.data!;
                          _cachedStories =
                              storiesToShow; // تحديث البيانات المخزنة
                        }

                        if (username == null || userimage == null) {
                          return const SizedBox.shrink();
                        }

                        final myId =
                            Supabase.instance.client.auth.currentUser!.id;
                        final myStories = storiesToShow
                            .where((s) => s.userId == myId)
                            .toList();
                        final otherStories = storiesToShow
                            .where((s) => s.userId != myId)
                            .toList();

                        return Skeletonizer(
                          enabled: isLoading && storiesToShow.isEmpty,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: 1 + 1 + otherStories.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(width: 12),
                            itemBuilder: (context, index) {
                              // زر إضافة ستوري
                              if (index == 0) {
                                return Column(
                                  children: [
                                    GestureDetector(
                                      onTap: () async {
                                        final addStory = AddStories();
                                        await addStory.handleAddStory(
                                          context: context,
                                          userName: username!,
                                          userImage: userimage!,
                                        );
                                      },
                                      child: CircleAvatar(
                                        radius: 30,
                                        backgroundColor: Colors.blueAccent,
                                        child: Icon(
                                          Icons.add,
                                          color: Colors.white,
                                          size: 28,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      lang == "ar" ? "أضف ستوري" : "Add Story",
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ],
                                );
                              }

                              // ستوري المستخدم
                              if (index == 1) {
                                if (myStories.isEmpty) {
                                  return Column(
                                    children: [
                                      CircleAvatar(
                                        radius: 30,
                                        backgroundColor: Colors.grey[200],
                                        child: Icon(
                                          Icons.person,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      const Text(
                                        "My Story",
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  );
                                }

                                final lastMyStory = myStories.last;

                                return Column(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => UserStoryViewer(
                                              stories: myStories,
                                            ),
                                          ),
                                        );
                                      },
                                      child: CircleAvatar(
                                        radius: 30,
                                        backgroundImage: NetworkImage(
                                          lastMyStory.imageUrl,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      "My Story",
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ],
                                );
                              }

                              // باقي المستخدمين
                              final storyIndex = index - 2;
                              if (storyIndex >= otherStories.length) {
                                return const SizedBox.shrink();
                              }

                              final story = otherStories[storyIndex];
                              return Column(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      final userStories = otherStories
                                          .where(
                                            (s) => s.userId == story.userId,
                                          )
                                          .toList();
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => UserStoryViewer(
                                            stories: userStories,
                                          ),
                                        ),
                                      );
                                    },
                                    child: CircleAvatar(
                                      radius: 30,
                                      backgroundImage: NetworkImage(
                                        story.imageUrl,
                                      ),
                                      backgroundColor: Colors.grey[200],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  SizedBox(
                                    width: 70,
                                    child: Text(
                                      story.userName,
                                      style: const TextStyle(fontSize: 12),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ---------------- Posts From Supabase ----------------
                  StreamBuilder<List<Post>>(
                    stream: PostService().getPostsStream(),
                    builder: (context, snapshot) {
                      final isLoading =
                          snapshot.connectionState == ConnectionState.waiting;

                      // ⭐ استخدام البيانات المخزنة أو الجديدة
                      List<Post> postsToShow = _cachedPosts;

                      if (snapshot.hasData) {
                        postsToShow = snapshot.data!;
                        _cachedPosts = postsToShow; // تحديث البيانات المخزنة
                      }

                      if (isLoading && postsToShow.isEmpty) {
                        // ⭐ عرض Skeleton للبوستات أثناء التحميل
                        return _buildPostsSkeleton();
                      }

                      if (postsToShow.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Text(
                              lang == "ar"
                                  ? "لا يوجد بوستات حالياً"
                                  : "No posts available",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        );
                      }

                      return Skeletonizer(
                        enabled: isLoading,
                        child: Column(
                          children: postsToShow.map((post) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _postCardFromSupabase(post),
                            );
                          }).toList(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ⭐ جديد: بناء هيكل عظمي للبوستات أثناء التحميل
  Widget _buildPostsSkeleton() {
    return Column(
      children: List.generate(3, (index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 8),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Skeleton
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.grey[300],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 120,
                              height: 16,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              width: 80,
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
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ],
                  ),
                ),

                // Content Skeleton
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(7),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: 200,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(7),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Image Skeleton
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(20),
                    ),
                  ),
                ),

                // Actions Skeleton
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            width: 20,
                            height: 14,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(7),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            width: 20,
                            height: 14,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(7),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _postCardFromSupabase(Post post) {
    final currentUserId = Supabase.instance.client.auth.currentUser?.id ?? '';
    bool isLiked = post.likedBy.contains(currentUserId);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---------------- Header ----------------
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundImage: NetworkImage(post.imageuser ?? ''),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.userName ?? 'User',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatTime(post.createdAt),
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.more_vert, color: Colors.grey[600]),
              ],
            ),
          ),

          // ---------------- Content ----------------
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Text(post.content, style: const TextStyle(fontSize: 14)),
          ),

          const SizedBox(height: 8),

          if ((post.imageUrl ?? "").isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(20),
              ),
              child: Image.network(
                post.imageUrl!,
                fit: BoxFit.cover,
                width: double.infinity,
                height: 200,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 200,
                    color: Colors.grey[200],
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    color: Colors.grey[200],
                    child: const Icon(Icons.error, color: Colors.grey),
                  );
                },
              ),
            ),

          // ---------------- Actions ----------------
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // ❤️ Likes - محدث تلقائياً
                StreamBuilder<List<Post>>(
                  stream: PostService().getPostsStream(),
                  builder: (context, snapshot) {
                    Post currentPost = post;

                    if (snapshot.hasData) {
                      final updatedPosts = snapshot.data!;
                      final updatedPost = updatedPosts.firstWhere(
                        (p) => p.id == post.id,
                        orElse: () => post,
                      );
                      currentPost = updatedPost;
                    }

                    return Row(
                      children: [
                        GestureDetector(
                          onTap: () async {
                            final postService = PostService();
                            await postService.toggleLike(
                              post.id,
                              currentUserId,
                            );
                          },
                          child: Icon(
                            currentPost.likedBy.contains(currentUserId)
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: currentPost.likedBy.contains(currentUserId)
                                ? Colors.red
                                : Colors.grey[700],
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text("${currentPost.likesCount}"),
                      ],
                    );
                  },
                ),

                // 💬 Comments - محدث تلقائياً
                StreamBuilder<List<Post>>(
                  stream: PostService().getPostsStream(),
                  builder: (context, snapshot) {
                    int commentsCount = post.commentsCount;

                    if (snapshot.hasData) {
                      final updatedPosts = snapshot.data!;
                      final updatedPost = updatedPosts.firstWhere(
                        (p) => p.id == post.id,
                        orElse: () => post,
                      );
                      commentsCount = updatedPost.commentsCount;
                    }

                    return GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          CommentsScreen.routeName,
                          arguments: {
                            "id": post.id,
                            "user_id": post.userId,
                            "contenttext": post.content,
                            "image_url": post.imageUrl,
                            "created_at": post.createdAt.toIso8601String(),
                            "fullname": username,
                            "userimage": userimage,
                          },
                        ).then((_) {
                          setState(() {});
                        });
                      },
                      child: Row(
                        children: [
                          const Icon(Icons.comment, size: 22),
                          const SizedBox(width: 6),
                          Text("$commentsCount"),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);

    if (diff.inMinutes < 1) return "Just now";
    if (diff.inMinutes < 60) return "${diff.inMinutes}m ago";
    if (diff.inHours < 24) return "${diff.inHours}h ago";
    return "${diff.inDays}d ago";
  }
}

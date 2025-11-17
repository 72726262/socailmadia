import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:soso/main.dart';
import 'package:soso/model/PostModel.dart';
import 'package:soso/model/selectUsermodeale.dart';
import 'package:soso/services/PostService.dart';
import 'package:soso/services/selecteusers.dart';
import 'package:soso/views/homepage/CommentsScreen.dart';
import 'package:soso/widgets/EditProfileScreen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileScreen extends StatefulWidget {
  static const routeName = "ProfileScreen";

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool get isArabic => appLocale.value.languageCode == 'ar';

  // ⭐ بيانات المستخدم الحقيقية
  SelectUsermodale? _currentUser;
  List<Post> _userPosts = [];
  bool _isLoading = true;
  int _totalLikes = 0;
  int _totalComments = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // ⭐ تحميل بيانات المستخدم والبوستات
  Future<void> _loadUserData() async {
    try {
      final currentUserId = Supabase.instance.client.auth.currentUser!.id;

      // جلب بيانات المستخدم
      final userResponse = await Supabase.instance.client
          .from('users')
          .select()
          .eq('uid', currentUserId)
          .single();

      setState(() {
        _currentUser = SelectUsermodale.fromMap(userResponse);
      });

      // جلب بوستات المستخدم
      final postsService = PostService();
      final allPosts = await postsService.fetchPosts();
      final userPosts = allPosts
          .where((post) => post.userId == currentUserId)
          .toList();

      // حساب الإحصائيات
      int totalLikes = 0;
      int totalComments = 0;

      for (var post in userPosts) {
        totalLikes += post.likesCount;
        totalComments += post.commentsCount;
      }

      setState(() {
        _userPosts = userPosts;
        _totalLikes = totalLikes;
        _totalComments = totalComments;
        _isLoading = false;
      });
    } catch (e) {
      print("Error loading user data: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: const Color(0xFFF2F6FF),
        body: _isLoading
            ? _buildProfileSkeleton()
            : ListView(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 12,
                  bottom: 90,
                ),
                children: [
                  _buildProfileHeader(),
                  const SizedBox(height: 20),
                  _buildStatsSection(),
                  const SizedBox(height: 20),
                  _buildPostsSection(),
                ],
              ),
      ),
    );
  }

  // ⭐ بناء هيكل عظمي أثناء التحميل
  Widget _buildProfileSkeleton() {
    return Skeletonizer(
      enabled: true,
      child: ListView(
        padding: EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 90),
        children: [
          // Header Skeleton
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 16),
              child: Column(
                children: [
                  CircleAvatar(radius: 55),
                  const SizedBox(height: 16),
                  Container(
                    width: 150,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 100,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: 160,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Stats Skeleton
          _buildStatsSkeleton(),
          const SizedBox(height: 20),
          // Posts Skeleton
          _buildPostsSkeleton(),
        ],
      ),
    );
  }

  // ⭐ بناء رأس البروفايل
  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0066FF), Color(0xFF4D9FFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 16),
        child: Column(
          children: [
            // صورة البروفايل
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: CircleAvatar(
                radius: 55,
                backgroundImage: NetworkImage(
                  _currentUser?.image ?? "assets/avatar.png",
                ),
                backgroundColor: Colors.grey[200],
              ),
            ),
            const SizedBox(height: 16),

            // اسم المستخدم
            Text(
              _currentUser?.name ?? "User",
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    color: Colors.black38,
                    offset: Offset(1, 1),
                    blurRadius: 3,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),

            // البريد الإلكتروني
            Text(
              _currentUser?.email ?? "",
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            const SizedBox(height: 4),

            // النوع وتاريخ الميلاد
            if (_currentUser?.type != null && _currentUser!.type.isNotEmpty)
              Text(
                "${_currentUser?.type ?? ""} • ${_formatDate(_currentUser?.datetime ?? "")}",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.8),
                  fontStyle: FontStyle.italic,
                ),
              ),

            const SizedBox(height: 16),

            // فاصل سينمائي
            Container(
              height: 3,
              width: 60,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            // زر تعديل البروفايل
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, EditProfileScreen.routeName).then((
                  _,
                ) {
                  // إعادة تحميل البيانات بعد العودة من التعديل
                  _loadUserData();
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Text(
                  isArabic ? "تعديل الملف الشخصي" : "Edit Profile",
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF0066FF),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ⭐ قسم الإحصائيات
  Widget _buildStatsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            icon: Icons.post_add_rounded,
            value: _userPosts.length.toString(),
            label: isArabic ? "المنشورات" : "Posts",
          ),
          _buildStatItem(
            icon: Icons.favorite_rounded,
            value: _totalLikes.toString(),
            label: isArabic ? "الإعجابات" : "Likes",
          ),
          _buildStatItem(
            icon: Icons.comment_rounded,
            value: _totalComments.toString(),
            label: isArabic ? "التعليقات" : "Comments",
          ),
        ],
      ),
    );
  }

  // ⭐ بناء عنصر إحصائية
  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F4FF),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Color(0xFF0066FF), size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  // ⭐ قسم البوستات
  Widget _buildPostsSection() {
    if (_userPosts.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(Icons.post_add_rounded, size: 60, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              isArabic ? "لا توجد منشورات بعد" : "No posts yet",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isArabic
                  ? "شارك أول منشور لك مع الأصدقاء!"
                  : "Share your first post with friends!",
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Text(
            isArabic
                ? "منشوراتي (${_userPosts.length})"
                : "My Posts (${_userPosts.length})",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ),
        Column(
          children: _userPosts.map((post) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _postCard(post),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ⭐ بناء بطاقة البوست
  Widget _postCard(Post post) {
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
          // الهيدر
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
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
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
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

          // المحتوى
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              post.content,
              style: const TextStyle(fontSize: 15, height: 1.4),
            ),
          ),

          const SizedBox(height: 8),

          // الصورة
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
              ),
            ),

          // الإجراءات
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // الإعجابات
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
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "${currentPost.likesCount}",
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    );
                  },
                ),

                // التعليقات
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
                            "fullname": _currentUser?.name,
                            "userimage": _currentUser?.image,
                          },
                        ).then((_) {
                          setState(() {});
                        });
                      },
                      child: Row(
                        children: [
                          const Icon(
                            Icons.comment,
                            size: 22,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "$commentsCount",
                            style: const TextStyle(fontSize: 14),
                          ),
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

  // ⭐ Skeleton للإحصائيات
  Widget _buildStatsSkeleton() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatSkeleton(),
          _buildStatSkeleton(),
          _buildStatSkeleton(),
        ],
      ),
    );
  }

  Widget _buildStatSkeleton() {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 30,
          height: 16,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 40,
          height: 12,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ],
    );
  }

  // ⭐ Skeleton للبوستات
  Widget _buildPostsSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Container(
            width: 120,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        Column(
          children: List.generate(2, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.grey[300],
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 100,
                                  height: 14,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(7),
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
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
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
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  // ⭐ تنسيق الوقت
  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);

    if (diff.inMinutes < 1) return isArabic ? "الآن" : "Just now";
    if (diff.inMinutes < 60)
      return "${diff.inMinutes}${isArabic ? " دقيقة" : "m ago"}";
    if (diff.inHours < 24)
      return "${diff.inHours}${isArabic ? " ساعة" : "h ago"}";
    return "${diff.inDays}${isArabic ? " يوم" : "d ago"}";
  }

  // ⭐ تنسيق التاريخ
  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return "${date.day}/${date.month}/${date.year}";
    } catch (e) {
      return dateString;
    }
  }
}

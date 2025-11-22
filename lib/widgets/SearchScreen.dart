import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:soso/main.dart';
import 'package:soso/model/PostModel.dart';
import 'package:soso/model/UserModel.dart'; // ⭐ تغيير الموديل
import 'package:soso/services/chat_service.dart';
import 'package:soso/services/PostService.dart';
import 'package:soso/widgets/ChatScreen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SearchScreen extends StatefulWidget {
  static const routeName = "SearchScreen";

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  bool get isArabic => appLocale.value.languageCode == "ar";

  late final TabController _tabController;
  int _selectedTabIndex = 0;

  // ⭐ بيانات البحث
  List<UserModel> _filteredUsers = [];
  List<Post> _filteredPosts = [];
  List<UserModel> _allUsers = [];
  List<Post> _allPosts = [];

  bool _isLoading = true;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabSelection);
    _searchController.addListener(_performSearch);
    _loadInitialData();
  }

  void _handleTabSelection() {
    setState(() {
      _selectedTabIndex = _tabController.index;
    });
  }

  void _loadInitialData() async {
    try {
      final chatService = ChatService();
      // جلب جميع المستخدمين
      final usersData = await chatService.getAllUsers();
      _allUsers = usersData.map((userMap) {
        return UserModel.fromMap(userMap);
      }).toList();

      // جلب جميع البوستات
      final postsService = PostService();
      _allPosts = await postsService.fetchPosts();

      setState(() {
        _isLoading = false;
        _filteredUsers = _allUsers;
        _filteredPosts = []; // ⭐ لا تعرض أي منشورات في البداية
      });
    } catch (e) {
      print("Error loading initial data: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _performSearch() {
    String query = _searchController.text.trim().toLowerCase();

    setState(() {
      _isSearching = query.isNotEmpty;
    });

    if (query.isEmpty) {
      // عرض كل البيانات عند عدم البحث
      setState(() {
        _filteredUsers = _allUsers;
        _filteredPosts = []; // ⭐ لا تعرض أي منشورات عند مسح البحث
      });
      return;
    }

    // البحث في المستخدمين
    final filteredUsers = _allUsers.where((user) {
      return user.fullname.toLowerCase().contains(query) ||
          (user.email).toLowerCase().contains(query);
    }).toList();

    // البحث في البوستات
    final filteredPosts = _allPosts.where((post) {
      return post.content.toLowerCase().contains(query) ||
          (post.userName ?? '').toLowerCase().contains(query);
    }).toList();

    setState(() {
      _filteredUsers = filteredUsers;
      _filteredPosts = filteredPosts;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ⭐ نتحقق إذا الـ TabController جاهز
    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFF),
        body: SafeArea(
          child: Column(
            children: [
              // ----------------------------------
              // ✅ Search Header
              // ----------------------------------
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // شريط البحث
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F7FA),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: const Color(0xFFE8ECF4),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.search_rounded,
                            color: Colors.grey[600],
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: isArabic
                                    ? "ابحث عن أشخاص أو منشورات..."
                                    : "Search for people or posts...",
                                hintStyle: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[500],
                                ),
                                border: InputBorder.none,
                              ),
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                          ),
                          if (_searchController.text.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _searchController.clear();
                                  _isSearching = false;
                                  _filteredUsers = _allUsers;
                                  _filteredPosts = _allPosts;
                                });
                              },
                              child: Icon(
                                Icons.close_rounded,
                                color: Colors.grey[600],
                                size: 22,
                              ),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Tabs
                    Container(
                      height: 60,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F4FF),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        indicator: BoxDecoration(
                          color: const Color(0xFF0066FF),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        labelColor: Colors.white,
                        unselectedLabelColor: const Color(0xFF666666),
                        labelStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        unselectedLabelStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        tabs: [
                          Tab(
                            text: isArabic ? "الأشخاص" : "People",
                            icon: Icon(Icons.people_alt_rounded, size: 20),
                          ),
                          Tab(
                            text: isArabic ? "المنشورات" : "Posts",
                            icon: Icon(Icons.post_add_rounded, size: 20),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ----------------------------------
              // ✅ Search Results
              // ----------------------------------
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // تبويب الأشخاص
                    _buildUsersTab(),

                    // تبويب المنشورات
                    _buildPostsTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUsersTab() {
    if (_isLoading) {
      return _buildUsersSkeleton();
    }

    if (_isSearching && _filteredUsers.isEmpty) {
      return _buildNoResults(
        icon: Icons.people_outline_rounded,
        message: isArabic ? "لا يوجد مستخدمين بهذا الاسم" : "No users found",
      );
    }

    if (!_isSearching && _filteredUsers.isEmpty) {
      return _buildNoResults(
        icon: Icons.people_outline_rounded,
        message: isArabic ? "لا يوجد مستخدمين" : "No users available",
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredUsers.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final user = _filteredUsers[index];
        return _buildUserTile(user);
      },
    );
  }

  Widget _buildPostsTab() {
    if (_isLoading) {
      return _buildPostsSkeleton();
    }

    // ⭐ جديد: عرض رسالة توجيهية إذا لم يكن المستخدم يبحث
    if (!_isSearching) {
      return _buildNoResults(
        icon: Icons.search_off_rounded,
        message: isArabic
            ? "ابدأ البحث عن المنشورات"
            : "Start searching for posts",
        subMessage: isArabic
            ? "اكتب في الشريط أعلاه للعثور على منشورات"
            : "Type in the bar above to find posts",
      );
    }

    if (_isSearching && _filteredPosts.isEmpty) {
      return _buildNoResults(
        icon: Icons.article_outlined,
        message: isArabic ? "لا يوجد منشورات بهذا المحتوى" : "No posts found",
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredPosts.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final post = _filteredPosts[index];
        return _buildPostTile(post);
      },
    );
  }

  Widget _buildUserTile(UserModel user) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundImage: user.imageUrl != null
                ? NetworkImage(user.imageUrl!)
                : null,
            backgroundColor: Colors.grey[200],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.fullname,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              _navigateToChat(user);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF0066FF).withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.chat_bubble_outline_rounded,
                    color: Color(0xFF0066FF),
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    isArabic ? "مراسلة" : "Message",
                    style: const TextStyle(
                      color: Color(0xFF0066FF),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostTile(Post post) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
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
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              post.content,
              style: const TextStyle(
                fontSize: 15,
                height: 1.4,
                color: Color(0xFF444444),
              ),
            ),
          ),

          const SizedBox(height: 12),

          if ((post.imageUrl ?? "").isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  post.imageUrl!,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            ),

          const SizedBox(height: 12),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(Icons.favorite_border, size: 20, color: Colors.grey[600]),
                const SizedBox(width: 6),
                Text("${post.likesCount}"),
                const SizedBox(width: 20),
                Icon(Icons.comment, size: 20, color: Colors.grey[600]),
                const SizedBox(width: 6),
                Text("${post.commentsCount}"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersSkeleton() {
    return Skeletonizer(
      enabled: true,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: 6,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const CircleAvatar(radius: 28),
                const SizedBox(width: 16),
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
                      const SizedBox(height: 8),
                      Container(
                        width: 180,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(7),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 80,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPostsSkeleton() {
    return Skeletonizer(
      enabled: true,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: 4,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const CircleAvatar(radius: 20),
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
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
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
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildNoResults({
    required IconData icon,
    required String message,
    String? subMessage,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subMessage ??
                (isArabic
                    ? "جرب كلمات بحث مختلفة"
                    : "Try different search terms"),
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _navigateToChat(UserModel otherUser) async {
    final chatService = ChatService();
    final currentUserId = Supabase.instance.client.auth.currentUser!.id;

    // إظهار مؤشر تحميل
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );

    try {
      // جلب أو إنشاء محادثة
      await chatService.getOrCreateChat(currentUserId, otherUser.id);

      // إغلاق مؤشر التحميل
      Navigator.pop(context);

      // الانتقال لشاشة الشات
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(
            user: {
              "uid": otherUser.id,
              "fullname": otherUser.fullname,
              "imageurl": otherUser.imageUrl,
            },
          ),
        ),
      );
    } catch (e) {
      // إغلاق مؤشر التحميل في حالة الخطأ
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to start chat: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);

    if (diff.inMinutes < 1) return isArabic ? "الآن" : "Just now";
    if (diff.inMinutes < 60) {
      return isArabic
          ? "منذ ${diff.inMinutes} دقيقة"
          : "${diff.inMinutes}m ago";
    }
    if (diff.inHours < 24) {
      return isArabic ? "منذ ${diff.inHours} ساعة" : "${diff.inHours}h ago";
    }
    return isArabic ? "منذ ${diff.inDays} يوم" : "${diff.inDays}d ago";
  }
}

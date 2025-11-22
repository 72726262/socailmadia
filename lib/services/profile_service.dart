import 'dart:io';
import 'package:soso/model/UserModel.dart';
import 'package:soso/model/PostModel.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileService {
  final _supabase = Supabase.instance.client;

  /// يجلب بيانات الملف الشخصي للمستخدم الحالي
  Future<UserModel?> getCurrentUserProfile() async {
    try {
      final userId = _supabase.auth.currentUser!.id;
      final data = await _supabase
          .from('users')
          .select()
          .eq('uid', userId)
          .single();
      return UserModel.fromMap(data);
    } catch (e) {
      print('Error fetching profile: $e');
      return null;
    }
  }

  /// تحديث بيانات الملف الشخصي
  Future<bool> updateProfile({
    required String name,
    required String bio,
    File? newImage,
  }) async {
    try {
      final userId = _supabase.auth.currentUser!.id;
      String? imageUrl;

      // 1. رفع الصورة الجديدة إذا تم اختيارها
      if (newImage != null) {
        final imagePath = '/$userId/profile';
        final imageFile = newImage;

        // .upload بدلاً من .update لضمان الكتابة فوق الصورة القديمة
        await _supabase.storage
            .from('avatars')
            .upload(
              imagePath,
              imageFile,
              fileOptions: const FileOptions(
                cacheControl: '3600',
                upsert: true,
              ),
            );

        // 2. جلب الرابط العام للصورة
        imageUrl = _supabase.storage.from('avatars').getPublicUrl(imagePath);
      }

      // 3. تحديث البيانات في جدول users
      final updates = {'fullname': name, 'bio': bio};

      // إضافة رابط الصورة فقط إذا تم تغييره
      if (imageUrl != null) {
        updates['imageurl'] = imageUrl;
      }

      await _supabase.from('users').update(updates).eq('uid', userId);
      return true;
    } catch (e) {
      print('Error updating profile: $e');
      return false;
    }
  }
}

/// ⭐ جديد: نموذج لتجميع بيانات شاشة الملف الشخصي
class ProfileData {
  final UserModel user;
  final List<Post> posts;
  final int totalLikes;
  final int totalComments;

  ProfileData({
    required this.user,
    required this.posts,
    required this.totalLikes,
    required this.totalComments,
  });
}

extension ProfileServiceExtensions on ProfileService {
  /// ⭐ جديد: دالة لجلب كل بيانات شاشة الملف الشخصي مرة واحدة
  Future<ProfileData?> getProfileScreenData() async {
    try {
      final userId = _supabase.auth.currentUser!.id;

      // 1. جلب بيانات المستخدم
      final userResponse = await _supabase
          .from('users')
          .select()
          .eq('uid', userId)
          .single();
      final user = UserModel.fromMap(userResponse);

      // 2. جلب منشورات المستخدم
      final postsResponse = await _supabase
          .from('posts')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      final userPosts = postsResponse
          .map<Post>((data) => Post.fromMap(data))
          .toList();

      // 3. حساب الإحصائيات
      final totalLikes = userPosts.fold<int>(
        0,
        (sum, post) => sum + post.likesCount,
      );
      final totalComments = userPosts.fold<int>(
        0,
        (sum, post) => sum + post.commentsCount,
      );

      return ProfileData(
        user: user,
        posts: userPosts,
        totalLikes: totalLikes,
        totalComments: totalComments,
      );
    } catch (e) {
      print('Error fetching profile screen data: $e');
      return null;
    }
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:soso/main.dart';
import 'package:soso/model/UserModel.dart';
import 'package:soso/services/profile_service.dart';

class EditProfileScreen extends StatefulWidget {
  static const routeName = "EditProfileScreen";

  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  bool get isArabic => appLocale.value.languageCode == 'ar';

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _profileService = ProfileService();

  File? _pickedImage;
  final ImagePicker _picker = ImagePicker();
  UserModel? _currentUser;

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final user = await _profileService.getCurrentUserProfile();
    if (user != null) {
      setState(() {
        _currentUser = user;
        _nameController.text = user.fullname;
        _bioController.text = user.bio ?? '';
        _isLoading = false;
      });
    } else {
      // التعامل مع خطأ جلب البيانات
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isArabic ? 'فشل تحميل البيانات' : 'Failed to load data',
            ),
          ),
        );
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 70,
      );
      if (pickedFile != null) {
        setState(() {
          _pickedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      print("Image pick error: $e");
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final success = await _profileService.updateProfile(
      name: _nameController.text.trim(),
      bio: _bioController.text.trim(),
      newImage: _pickedImage,
    );

    setState(() => _isSaving = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? (isArabic
                      ? "تم تحديث الملف الشخصي بنجاح!"
                      : "Profile updated successfully!")
                : (isArabic
                      ? "فشل تحديث الملف الشخصي"
                      : "Failed to update profile"),
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
      if (success) {
        Navigator.of(context).pop(true); // إرجاع true للإشارة إلى النجاح
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        body: _isLoading
            ? _buildSkeleton() // ⭐ عرض واجهة هيكلية أثناء التحميل
            : Stack(
                children: [
                  // الخلفية بتدرج ألوان جذاب
                  Container(
                    height: 250,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF0066FF), Color(0xFF4D9FFF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),

                  // محتوى الصفحة
                  SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 50,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // الصورة الشخصية مع تأثير السينمائي و إمكانية التغيير
                          Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 10,
                                      offset: Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: CircleAvatar(
                                  radius: 65,
                                  backgroundImage: _pickedImage != null
                                      ? FileImage(_pickedImage!)
                                      : (_currentUser?.imageUrl != null &&
                                            _currentUser!.imageUrl!.isNotEmpty)
                                      ? NetworkImage(_currentUser!.imageUrl!)
                                      : const AssetImage("assets/avatar.png")
                                            as ImageProvider,
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.blueAccent,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                                child: PopupMenuButton<int>(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.white,
                                  ),
                                  onSelected: (value) {
                                    if (value == 0) {
                                      _pickImage(ImageSource.camera);
                                    } else if (value == 1) {
                                      _pickImage(ImageSource.gallery);
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    PopupMenuItem(
                                      value: 0,
                                      child: Row(
                                        children: [
                                          const Icon(Icons.camera_alt),
                                          const SizedBox(width: 8),
                                          Text(isArabic ? "كاميرا" : "Camera"),
                                        ],
                                      ),
                                    ),
                                    PopupMenuItem(
                                      value: 1,
                                      child: Row(
                                        children: [
                                          const Icon(Icons.photo_library),
                                          const SizedBox(width: 8),
                                          Text(
                                            isArabic ? "معرض الصور" : "Gallery",
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // اسم المستخدم
                          _buildProfileField(
                            controller: _nameController,
                            label: isArabic ? "الاسم" : "Name",
                            icon: Icons.person_outline,
                            validator: (val) =>
                                val == null || val.trim().isEmpty
                                ? (isArabic
                                      ? 'الاسم مطلوب'
                                      : 'Name is required')
                                : null,
                          ),
                          _buildProfileField(
                            controller: _bioController,
                            label: isArabic ? "النبذة التعريفية" : "Bio",
                            icon: Icons.info_outline,
                          ),
                          const SizedBox(height: 30),

                          // زر حفظ التغييرات
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _saveProfile,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                backgroundColor: const Color(0xFF0066FF),
                                elevation: 6,
                                shadowColor: Colors.black45,
                              ),
                              child: _isSaving
                                  ? const SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 3,
                                      ),
                                    )
                                  : Text(
                                      isArabic
                                          ? "حفظ التغييرات"
                                          : "Save Changes",
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 50), // مسافة إضافية للتمرير
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 50,
                    right: 20,
                    child: IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(
                        Icons.arrow_back,
                        size: 32,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // ⭐ واجهة هيكلية احترافية
  Widget _buildSkeleton() {
    return Skeletonizer(
      enabled: true,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 50),
        child: Column(
          children: [
            const CircleAvatar(radius: 65),
            const SizedBox(height: 24),
            Container(
              height: 68,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              height: 68,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            const SizedBox(height: 30),
            Container(
              height: 54,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // دالة لبناء حقل نصي بشكل احترافي
  Widget _buildProfileField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        validator: validator,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          prefixIcon: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Icon(icon, color: const Color(0xFF0066FF)),
          ),
          labelText: label,
          labelStyle: TextStyle(
            fontSize: 16,
            color: Colors.blueGrey[700],
            fontWeight: FontWeight.w600,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 20,
            horizontal: 8,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }
}

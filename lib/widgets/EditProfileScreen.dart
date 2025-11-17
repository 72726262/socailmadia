import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:soso/main.dart'; // لإحضار appLocale

class EditProfileScreen extends StatefulWidget {
  static const routeName = "EditProfileScreen";

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  bool get isArabic => appLocale.value.languageCode == 'ar';

  final TextEditingController _nameController = TextEditingController(
    text: "Akram Atiia",
  );
  final TextEditingController _bioController = TextEditingController(
    text: "المستخدم",
  );

  File? _pickedImage;
  final ImagePicker _picker = ImagePicker();

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

  void _saveProfile() {
    String name = _nameController.text.trim();
    String bio = _bioController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isArabic ? "الاسم لا يمكن أن يكون فارغًا" : "Name cannot be empty",
          ),
        ),
      );
      return;
    }

    print("Profile updated: name=$name, bio=$bio, image=${_pickedImage?.path}");

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isArabic ? "تم تحديث الملف الشخصي!" : "Profile updated!"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        body: Stack(
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 50),
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
                              ? FileImage(_pickedImage!) as ImageProvider
                              : AssetImage("assets/avatar.png"),
                        ),
                      ),

                      Container(
                        decoration: BoxDecoration(
                          color: Colors.blueAccent,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: PopupMenuButton<int>(
                          icon: const Icon(Icons.edit, color: Colors.white),
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
                                  Text(isArabic ? "معرض الصور" : "Gallery"),
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
                  // داخل العمود الرئيسي
                  _buildProfileField(
                    controller: _nameController,
                    label: isArabic ? "الاسم" : "Name",
                    icon: Icons.person,
                  ),
                  _buildProfileField(
                    controller: _bioController,
                    label: isArabic ? "الحالة" : "Bio",
                    icon: Icons.info_outline,
                  ),

                  const SizedBox(height: 30),

                  // زر حفظ التغييرات
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveProfile,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        backgroundColor: const Color(0xFF0066FF),
                        elevation: 6,
                        shadowColor: Colors.black45,
                      ),
                      child: Text(
                        isArabic ? "حفظ التغييرات" : "Save Changes",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black26,
                              offset: Offset(1, 1),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 50), // مسافة إضافية للتمرير
                ],
              ),
            ),
            Positioned(
              top: 50,
              right: 20,
              child: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(Icons.arrow_back, size: 32, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // دالة لبناء حقل نصي بشكل سينمائي
  Widget _buildProfileField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFFE0F0FF), Color(0xFFB0D9FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Color(0xFF0066FF)),
          labelText: label,
          labelStyle: TextStyle(
            fontSize: 22,
            color: Colors.blueGrey[700],
            fontWeight: FontWeight.bold,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white.withOpacity(0.1),
        ),
      ),
    );
  }
}

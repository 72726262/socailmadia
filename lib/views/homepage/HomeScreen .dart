// -------------------- HomeScreen بعد إضافة Bottom Nav --------------------

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:soso/main.dart';
import 'package:soso/widgets/AddPostScreen.dart';
import 'package:soso/widgets/ChatListScreen.dart';

import 'package:soso/widgets/CustomBottomNavBar.dart';
import 'package:soso/widgets/NotificationsDrawer.dart';
import 'package:soso/widgets/ProfileScreen.dart';
import 'package:soso/widgets/SearchScreen.dart';
import 'package:soso/widgets/_homeContent.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = "HomeScreen";

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  int _selectedIndex = 0;

  bool get isArabic => appLocale.value.languageCode == 'ar';

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOut,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  // ---------------- Language Toggle ----------------
  Future<void> toggleLanguage() async {
    bool arabic = appLocale.value.languageCode == 'ar';
    appLocale.value = arabic
        ? const Locale('en', 'US')
        : const Locale('ar', 'EG');
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("app_lang", appLocale.value.languageCode);
    setState(() {});
  }

  // ✅ الصفحات اللي هتتغير حسب الـ bottom navigation
  List<Widget> get pages => [
    HomeContent(),
    SearchScreen(),
    AddPostScreen(),
    ChatListScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NotificationsDrawer(),

      backgroundColor: const Color(0xFFF2F6FF),

      body: Stack(
        children: [
          FadeTransition(
            opacity: _fadeAnimation,
            child: SafeArea(child: pages[_selectedIndex]),
          ),

          // ✅ Bottom Navigation ثابت
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: CustomBottomNavBar(
              currentIndex: _selectedIndex,
              onTap: (index) {
                setState(() => _selectedIndex = index);
              },
            ),
          ),
        ],
      ),
    );
  }
}

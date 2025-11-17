import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:soso/main.dart';

class CustomBottomNavBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  CustomBottomNavBar({required this.currentIndex, required this.onTap});

  @override
  State<CustomBottomNavBar> createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar>
    with SingleTickerProviderStateMixin {
  bool get isArabic => appLocale.value.languageCode == "ar";

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.85),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 20,
                offset: Offset(0, -4),
              ),
            ],
          ),
          child: Directionality(
            textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  Icons.home_rounded,
                  isArabic ? "الرئيسية" : "Home",
                  0,
                ),
                _buildNavItem(
                  Icons.search_rounded,
                  isArabic ? "بحث" : "Search",
                  1,
                ),
                _buildNavItem(
                  Icons.add_circle_rounded,
                  isArabic ? "إضافة" : "Post",
                  2,
                ),
                _buildNavItem(
                  Icons.chat_bubble_rounded,
                  isArabic ? "الدردشة" : "Chats",
                  3,
                ),
                _buildNavItem(
                  Icons.person_rounded,
                  isArabic ? "الملف" : "Profile",
                  4,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    bool selected = widget.currentIndex == index;

    return GestureDetector(
      onTap: () => widget.onTap(index),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        width: 70,
        height: selected ? 70 : 58,
        padding: EdgeInsets.symmetric(vertical: selected ? 6 : 3),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF0066FF).withOpacity(0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: selected ? 30 : 26,
              color: selected ? const Color(0xFF0066FF) : Colors.grey[600],
            ),
            const SizedBox(height: 4),
            AnimatedOpacity(
              duration: Duration(milliseconds: 300),
              opacity: selected ? 1 : 0,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF0066FF),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soso/main.dart';
import 'Registerpage2.dart';

class Registerpage1 extends StatefulWidget {
  static const routename = "Registerpage1";

  @override
  State<Registerpage1> createState() => _Registerpage1State();
}

class _Registerpage1State extends State<Registerpage1>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  String? fullName;
  String? gender;
  DateTime? birthDate;

  late AnimationController _anim;
  late Animation<double> fade;

  bool get isArabic => appLocale.value.languageCode == 'ar';

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    fade = CurvedAnimation(parent: _anim, curve: Curves.easeOut);
    _anim.forward();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  Future<void> pickBirthDate() async {
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      locale: appLocale.value,
      firstDate: DateTime(1960),
      lastDate: DateTime(now.year - 13),
      initialDate: DateTime(now.year - 18),
      helpText: isArabic ? "اختر تاريخ ميلادك" : "Select your birthday",
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0066FF),
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => birthDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: fade,
        child: Container(
          height: double.infinity,
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFEEF2FF), Color(0xFFE0EAFF), Color(0xFFD6E1FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),

          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 65),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ---------------------------
                  // زر تغيير اللغة
                  // ---------------------------
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // السهم
                      IconButton(
                        icon: Icon(
                          appLocale.value.languageCode == 'ar'
                              ? Icons
                                    .arrow_back // عربي: السهم للجهة اليمنى
                              : Icons
                                    .arrow_forward, // إنجليزي: السهم للجهة اليسرى
                          color: Colors.black87,
                          size: 28,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),

                      // زر تغيير اللغة
                      GestureDetector(
                        onTap: () async {
                          bool arabic = appLocale.value.languageCode == 'ar';
                          appLocale.value = arabic
                              ? const Locale('en', 'US')
                              : const Locale('ar', 'EG');

                          final prefs = await SharedPreferences.getInstance();
                          prefs.setString(
                            "app_lang",
                            appLocale.value.languageCode,
                          );
                          setState(() {}); // لتحديث النص والموقع
                        },
                        child: Row(
                          children: appLocale.value.languageCode == 'ar'
                              ? const [
                                  Icon(
                                    Icons.language,
                                    size: 28,
                                    color: Colors.black87,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    "الإنجليزية",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ]
                              : [
                                  const Text(
                                    "Arabic",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Icon(
                                    Icons.language,
                                    size: 28,
                                    color: Colors.black87,
                                  ),
                                ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  /// ✅ العنوان الرئيسي
                  Text(
                    isArabic
                        ? "خلينا نتعرف عليك 👋"
                        : "Let’s get to know you 👋",
                    style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                      height: 1.1,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    isArabic
                        ? "املأ بياناتك الأساسية"
                        : "Fill in your basic information",
                    style: const TextStyle(fontSize: 17, color: Colors.black54),
                  ),

                  const SizedBox(height: 35),

                  // ✅ الاسم
                  _inputBox(
                    label: isArabic ? "الاسم الكامل" : "Full Name",
                    hint: isArabic
                        ? "ادخل اسمك الحقيقي"
                        : "Enter your full name",
                    icon: Icons.person,
                    validator: (v) => v!.length < 3
                        ? (isArabic ? "اسم غير صالح" : "Invalid Name")
                        : null,
                    onChanged: (v) => fullName = v,
                  ),

                  const SizedBox(height: 22),

                  // ✅ النوع
                  Text(
                    isArabic ? "النوع" : "Gender",
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      genderButton(isArabic ? "ذكر" : "Male", Icons.male),
                      const SizedBox(width: 12),
                      genderButton(isArabic ? "أنثى" : "Female", Icons.female),
                    ],
                  ),

                  const SizedBox(height: 25),

                  // ✅ تاريخ الميلاد
                  GestureDetector(
                    onTap: pickBirthDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      decoration: boxStyle(),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_month,
                            color: Colors.blueAccent,
                          ),
                          const SizedBox(width: 15),
                          Text(
                            birthDate == null
                                ? (isArabic
                                      ? "اختر تاريخ ميلادك"
                                      : "Select your birthday")
                                : DateFormat(
                                    "yyyy / MM / dd",
                                  ).format(birthDate!),
                            style: TextStyle(
                              fontSize: 16,
                              color: birthDate == null
                                  ? Colors.black45
                                  : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 50),

                  // ✅ زر التالي (احترافي)
                  GestureDetector(
                    onTap: () {
                      if (_formKey.currentState!.validate() &&
                          gender != null &&
                          birthDate != null) {
                        Navigator.pushNamed(
                          context,
                          Registerpage2.routeName,
                          arguments: {
                            "name": fullName,
                            "gender": gender,
                            "birthDate": birthDate!.toIso8601String(),
                          },
                        );
                      }
                    },
                    child: Container(
                      alignment: Alignment.center,
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0066FF),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0066FF).withOpacity(0.3),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        isArabic ? "التالي" : "Next",
                        style: const TextStyle(
                          fontSize: 19,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ✅ صندوق إدخال
  Widget _inputBox({
    required String label,
    required String hint,
    required IconData icon,
    required Function(String) onChanged,
    required String? Function(String?) validator,
  }) {
    return Container(
      decoration: boxStyle(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: TextFormField(
        onChanged: onChanged,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon),
          border: InputBorder.none,
        ),
      ),
    );
  }

  // ✅ اختيار النوع
  Widget genderButton(String text, IconData icon) {
    final bool selected = gender == text;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => gender = text),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF0066FF) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? Colors.blueAccent : Colors.grey.shade300,
              width: 1.5,
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 28,
                color: selected ? Colors.white : Colors.black54,
              ),
              const SizedBox(height: 6),
              Text(
                text,
                style: TextStyle(
                  color: selected ? Colors.white : Colors.black87,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ Box Style
  BoxDecoration boxStyle() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      boxShadow: const [
        BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
      ],
    );
  }
}

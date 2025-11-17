import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soso/Cubit/cubitsignInuser.dart';
import 'package:soso/main.dart';
import 'package:soso/services/signInUserfirebase.dart';
import 'package:soso/views/homepage/HomeScreen%20.dart';
import 'package:soso/views/pageLogin/ChangePasswordScreen.dart';

import 'package:soso/views/pageLogin/ForgotPasswordPhone.dart';
import 'package:soso/views/pageLogin/Registerpage1.dart';

class LoginPage extends StatefulWidget {
  static const routeName = "LoginPage";

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  String? email;
  String? phone;
  String? password;

  bool hidePassword = true;
  bool isEmailSelected = true; // تسجيل بالإيميل أو بالرقم
  bool _isloding = false;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<Signinuserfirebase, counterstate2>(
        listener: (context, state) {
          if (state is counterstateLoding2) {
            _isloding = true;
          } else if (state is counterstateSuccuss2) {
            _isloding = false;
            Navigator.pushNamed(context, HomeScreen.routeName);
          } else if (state is counterstateFaliuer2) {
            _isloding = false;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  context.read<Signinuserfirebase>().error22.toString(),
                  style: TextStyle(fontSize: 28),
                ),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  context.read<Signinuserfirebase>().error22.toString(),
                ),
              ),
            );
          }
        },
        builder: (context, asyncSnapshot) {
          return Stack(
            children: [
              FadeTransition(
                opacity: fade,
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 26,
                    vertical: 70,
                  ),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFFF2F6FF),
                        Color(0xFFE2EBFF),
                        Color(0xFFD4E1FF),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ---------------------------
                          // زر تغيير اللغة
                          // ---------------------------
                          Align(
                            alignment: appLocale.value.languageCode == 'ar'
                                ? Alignment.topRight
                                : Alignment.topLeft,
                            child: GestureDetector(
                              onTap: () async {
                                bool arabic =
                                    appLocale.value.languageCode == 'ar';
                                appLocale.value = arabic
                                    ? const Locale('en', 'US')
                                    : const Locale('ar', 'EG');

                                final prefs =
                                    await SharedPreferences.getInstance();
                                prefs.setString(
                                  "app_lang",
                                  appLocale.value.languageCode,
                                );
                                setState(() {}); // لتحديث النص والموقع
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: appLocale.value.languageCode == 'ar'
                                    ? [
                                        const Icon(
                                          Icons.language,
                                          size: 28,
                                          color: Colors.black87,
                                        ),
                                        const SizedBox(width: 6),
                                        const Text(
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
                          ),

                          const SizedBox(height: 20),

                          // ---------------------------
                          // عنوان الشاشة
                          // ---------------------------
                          Text(
                            isArabic ? "تسجيل الدخول 🔑" : "Login 🔑",
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            isArabic
                                ? "اختر طريقة تسجيل الدخول وأدخل بياناتك"
                                : "Choose login method and enter your details",
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                          ),

                          const SizedBox(height: 30),

                          // ---------------------------
                          // اختيار تسجيل بالإيميل أو بالرقم
                          // ---------------------------
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () =>
                                      setState(() => isEmailSelected = true),
                                  child: _methodButton(
                                    text: isArabic ? "الإيميل" : "Email",
                                    icon: Icons.email,
                                    selected: isEmailSelected,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () =>
                                      setState(() => isEmailSelected = false),
                                  child: _methodButton(
                                    text: isArabic ? "الهاتف" : "Phone",
                                    icon: Icons.phone,
                                    selected: !isEmailSelected,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 30),

                          // ---------------------------
                          // الحقول الديناميكية
                          // ---------------------------
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 400),
                            transitionBuilder: (child, animation) =>
                                SizeTransition(
                                  sizeFactor: animation,
                                  axisAlignment: -1,
                                  child: child,
                                ),
                            child: isEmailSelected
                                ? _inputBox(
                                    key: const ValueKey("email"),
                                    label: isArabic
                                        ? "البريد الإلكتروني"
                                        : "Email Address",
                                    hint: "",
                                    icon: Icons.email,
                                    validator: (v) => v!.contains("@")
                                        ? null
                                        : (isArabic
                                              ? "بريد غير صالح"
                                              : "Invalid Email"),
                                    onChanged: (v) => email = v,
                                  )
                                : _inputBox(
                                    key: const ValueKey("phone"),
                                    label: isArabic
                                        ? "رقم الهاتف"
                                        : "Phone Number",
                                    hint: isArabic
                                        ? "010*****678"
                                        : "Enter your phone number",
                                    icon: Icons.phone,
                                    keyboardType: TextInputType.phone,
                                    validator: (v) => v!.length >= 10
                                        ? null
                                        : (isArabic
                                              ? "رقم غير صالح"
                                              : "Invalid number"),
                                    onChanged: (v) => phone = v,
                                  ),
                          ),

                          const SizedBox(height: 22),

                          // ---------------------------
                          // كلمة المرور
                          // ---------------------------
                          _inputBox(
                            label: isArabic ? "كلمة المرور" : "Password",
                            hint: "********",
                            icon: Icons.lock,
                            obscure: hidePassword,
                            suffixIcon: GestureDetector(
                              onTap: () =>
                                  setState(() => hidePassword = !hidePassword),
                              child: Icon(
                                hidePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.grey,
                              ),
                            ),
                            validator: (v) => v!.length >= 6
                                ? null
                                : (isArabic ? "قصيرة جداً" : "Too short"),
                            onChanged: (v) => password = v,
                          ),

                          const SizedBox(height: 50),

                          // ---------------------------
                          // زر تسجيل الدخول
                          // ---------------------------
                          GestureDetector(
                            onTap: () async {
                              if (!_formKey.currentState!.validate()) return;

                              if (isEmailSelected) {
                                context.read<Signinuserfirebase>().signIn(
                                  email: email!,
                                  password: password!,
                                );
                              } else {}
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
                                    color: const Color(
                                      0xFF0066FF,
                                    ).withOpacity(0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Text(
                                isArabic ? "تسجيل الدخول" : "Login",
                                style: const TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                          // بعد حقل كلمة المرور مباشرة
                          const SizedBox(height: 12),

                          Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: () {
                                if (isEmailSelected) {
                                } else {
                                  Navigator.pushNamed(
                                    context,
                                    ForgotPasswordPhone.routeName,
                                  );
                                }
                              },
                              child: Text(
                                isArabic
                                    ? "نسيت كلمة المرور؟"
                                    : "Forgot Password?",
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Color(0xFF0066FF),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 30),
                          // بدل Align الحالي للغة ونقلناه للأسفل مع "لا تمتلك حساب؟"
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(width: 20),
                              Text(
                                isArabic
                                    ? "لا تمتلك حساب؟"
                                    : "Don't have an account?",
                                style: const TextStyle(
                                  fontSize: 20,
                                  color: Colors.black54,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    Registerpage1.routename,
                                  );
                                },
                                child: Text(
                                  isArabic ? " إنشاء حساب" : " Sign Up",
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0066FF),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              if (_isloding)
                Container(
                  color: Colors.black.withOpacity(0.3),
                  child: SpinKitFadingCircle(
                    color: Color.fromARGB(255, 17, 64, 146),
                    size: 70.0,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  // ---------------------------
  // زرّ اختيار الطريقة
  // ---------------------------
  Widget _methodButton({
    required String text,
    required IconData icon,
    required bool selected,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFF0066FF) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: selected ? const Color(0xFF0066FF) : Colors.grey.shade300,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: selected
                ? const Color(0xFF0066FF).withOpacity(0.3)
                : Colors.black12,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: selected ? Colors.white : Colors.black87),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: selected ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------
  // صندوق إدخال
  // ---------------------------
  Widget _inputBox({
    Key? key,
    required String label,
    required String hint,
    required IconData icon,
    required Function(String) onChanged,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
    bool obscure = false,
    Widget? suffixIcon,
  }) {
    return Container(
      key: key,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: TextFormField(
        keyboardType: keyboardType,
        obscureText: obscure,
        validator: validator,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
        ),
      ),
    );
  }
}

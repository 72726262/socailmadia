import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:soso/Cubit/cubitcreateuser.dart';
import 'package:soso/main.dart';
import 'package:soso/services/createUserfirebase.dart';
import 'package:soso/views/pageLogin/EmailConfirmationScreen.dart';

class Registerpage2 extends StatefulWidget {
  static const routeName = "Registerpage2";

  @override
  State<Registerpage2> createState() => _Registerpage2State();
}

class _Registerpage2State extends State<Registerpage2>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  String? fullname;
  String? datetime;
  String? gender;
  String? email;
  String? phone;
  String? password;
  String? confirmPassword;
  bool _isloding = false;
  late AnimationController _anim;
  late Animation<double> fade;

  bool get isArabic => appLocale.value.languageCode == 'ar';

  bool hidePassword = true;
  bool hideConfirmPassword = true;

  // ✅ تسجيل بالإيميل أو برقم الهاتف
  bool isEmailSelected = true;

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
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;

    fullname = args["name"];
    gender = args["gender"];
    datetime = args["birthDate"];
    return Scaffold(
      body: BlocConsumer<CreateUserFirebase, counterstate>(
        listener: (context, state) {
          if (state is counterstateLoding) {
            _isloding = true;
          } else if (state is counterstateSuccuss) {
            _isloding = false;
            Navigator.pushNamed(context, EmailConfirmationScreen.routeName);
          } else if (state is counterstateFaliuer) {
            _isloding = false;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  context.read<CreateUserFirebase>().error22.toString(),
                  style: TextStyle(fontSize: 28),
                ),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  context.read<CreateUserFirebase>().error22.toString(),
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
                  height: double.infinity,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFFF2F6FF),
                        Color(0xFFE8F0FF),
                        Color(0xFFDDE7FF),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 26,
                      vertical: 65,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                          // -------------------------------------------------------------
                          // ✅ عنوان الشاشة
                          // -------------------------------------------------------------
                          Text(
                            isEmailSelected
                                ? (isArabic
                                      ? "إنشاء حساب بالإيميل"
                                      : "Email Sign Up")
                                : (isArabic
                                      ? "إنشاء حساب بالهاتف"
                                      : "Phone Sign Up"),
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                            ),
                          ),

                          const SizedBox(height: 8),
                          Text(
                            isArabic
                                ? "اختر طريقة التسجيل ثم أكمل بياناتك"
                                : "Choose your registration method",
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                          ),

                          const SizedBox(height: 30),

                          // -------------------------------------------------------------
                          // ✅ اختيار طريقة التسجيل
                          // -------------------------------------------------------------
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () =>
                                      setState(() => isEmailSelected = true),
                                  child: _methodButton(
                                    text: isArabic
                                        ? "التسجيل بالإيميل"
                                        : "Email Sign Up",
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
                                    text: isArabic
                                        ? "التسجيل بالهاتف"
                                        : "Phone Sign Up",
                                    icon: Icons.phone,
                                    selected: !isEmailSelected,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 30),

                          // -------------------------------------------------------------
                          // ✅ إيميل أو هاتف حسب الاختيار
                          // -------------------------------------------------------------
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 400),
                            child: isEmailSelected
                                ? _inputBox(
                                    key: const ValueKey("email"),
                                    label: isArabic
                                        ? "البريد الإلكتروني"
                                        : "Email Address",
                                    hint: "example@gmail.com",
                                    icon: Icons.email,
                                    validator: (v) => v!.contains("@")
                                        ? null
                                        : (isArabic
                                              ? "البريد غير صالح"
                                              : "Invalid Email"),
                                    onChanged: (v) => email = v,
                                  )
                                : _inputBox(
                                    key: const ValueKey("phone"),
                                    label: isArabic
                                        ? "رقم الهاتف"
                                        : "Phone Number",
                                    hint: isArabic
                                        ? "01012345678"
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

                          // -------------------------------------------------------------
                          // ✅ كلمة المرور
                          // -------------------------------------------------------------
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

                          const SizedBox(height: 22),

                          // -------------------------------------------------------------
                          // ✅ تأكيد كلمة المرور
                          // -------------------------------------------------------------
                          _inputBox(
                            label: isArabic
                                ? "تأكيد كلمة المرور"
                                : "Confirm Password",
                            hint: "********",
                            icon: Icons.lock_outline,
                            obscure: hideConfirmPassword,
                            suffixIcon: GestureDetector(
                              onTap: () => setState(() {
                                hideConfirmPassword = !hideConfirmPassword;
                              }),
                              child: Icon(
                                hideConfirmPassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.grey,
                              ),
                            ),
                            validator: (v) => v == password
                                ? null
                                : (isArabic
                                      ? "كلمتا المرور غير متطابقتين"
                                      : "Passwords don't match"),
                            onChanged: (v) => confirmPassword = v,
                          ),

                          const SizedBox(height: 50),

                          // -------------------------------------------------------------
                          // ✅ زر التالي
                          // -------------------------------------------------------------
                          GestureDetector(
                            onTap: () async {
                              if (!_formKey.currentState!.validate()) return;

                              if (isEmailSelected) {
                                context.read<CreateUserFirebase>().signUp(
                                  email: email!,
                                  password: password!,
                                  fullName: fullname.toString(),
                                  gender: gender.toString(),
                                  datetime: datetime.toString(),
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
                                isArabic ? "التالي" : "Next",
                                style: const TextStyle(
                                  fontSize: 20,
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

  // -----------------------------------------------------------------------
  // ✅ زر UI لاختيار طريقة التسجيل
  // -----------------------------------------------------------------------
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

  // -----------------------------------------------------------------------
  // ✅ صندوق إدخال
  // -----------------------------------------------------------------------
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

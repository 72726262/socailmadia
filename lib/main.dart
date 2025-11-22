import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soso/on_generate_Route.dart';
import 'package:soso/controllers/notification_controller.dart';
import 'package:soso/services/createUserfirebase.dart';
import 'package:soso/services/signInUserfirebase.dart';
import 'package:soso/views/pageLogin/LoginPage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

ValueNotifier<Locale> appLocale = ValueNotifier(const Locale('ar', 'EG'));

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final savedLang = prefs.getString("app_lang");

  if (savedLang != null) {
    appLocale.value = Locale(savedLang, savedLang == 'ar' ? 'EG' : 'US');
  }
  await Supabase.initialize(
    url: "https://sfthmdxrknqocaenvxbs.supabase.co",
    anonKey:
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNmdGhtZHhya25xb2NhZW52eGJzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI3MjE2MjcsImV4cCI6MjA3ODI5NzYyN30.vqZ8nt5-oHc4xOMKv0aiv0alotXLz59oMCJRIKIEPvQ",
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => CreateUserCubit()),
        BlocProvider(create: (context) => SignInCubit()),
      ],
      child: ValueListenableBuilder<Locale>(
        valueListenable: appLocale,
        builder: (context, locale, _) {
          // ⭐ جديد: لف التطبيق بـ OverlaySupport.global()
          return OverlaySupport.global(
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              locale: appLocale.value,
              supportedLocales: const [Locale('en', 'US'), Locale('ar', 'EG')],
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              localeResolutionCallback: (locale, supportedLocales) {
                return appLocale.value;
              },

              home: const AuthStateListener(),
              onGenerateRoute: onGenerateRoute,
            ),
          );
        },
      ),
    );
  }
}

// ⭐ جديد: ويدجت جديد للاستماع لحالة تسجيل الدخول وتفعيل الإشعارات
class AuthStateListener extends StatefulWidget {
  const AuthStateListener({super.key});

  @override
  State<AuthStateListener> createState() => _AuthStateListenerState();
}

class _AuthStateListenerState extends State<AuthStateListener> {
  @override
  void initState() {
    super.initState();
    // الاستماع لتغيرات حالة المصادقة
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      if (event == AuthChangeEvent.signedIn) {
        NotificationController().initialize();
      } else if (event == AuthChangeEvent.signedOut) {
        NotificationController().dispose();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // يعرض شاشة الدخول مباشرة عند فتح التطبيق
    return LoginPage();
  }
}

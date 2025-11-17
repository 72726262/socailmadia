import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soso/Cubit/cubitcreateuser.dart';
import 'package:soso/Cubit/cubitsignInuser.dart';

import 'package:soso/on_generate_Route.dart';
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
        BlocProvider(
          create: (context) => CreateUserFirebase(counterstateintial()),
        ),
        BlocProvider(
          create: (context) => Signinuserfirebase(counterstateintial2()),
        ),
      ],
      child: ValueListenableBuilder<Locale>(
        valueListenable: appLocale,
        builder: (context, locale, _) {
          return MaterialApp(
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

            onGenerateRoute: onGenerateRoute,

            initialRoute: LoginPage.routeName,
          );
        },
      ),
    );
  }
}

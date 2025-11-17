import 'package:flutter/material.dart';
import 'package:soso/views/homepage/CommentsScreen.dart';
import 'package:soso/views/homepage/HomeScreen%20.dart';
import 'package:soso/views/pageLogin/ChangePasswordScreen.dart';
import 'package:soso/views/pageLogin/EmailConfirmationScreen.dart';

import 'package:soso/views/pageLogin/ForgotPasswordPhone.dart';
import 'package:soso/views/pageLogin/LoginPage.dart';
import 'package:soso/views/pageLogin/PhoneOtpScreen.dart';
import 'package:soso/views/pageLogin/Registerpage1.dart';
import 'package:soso/views/pageLogin/Registerpage2.dart';
import 'package:soso/views/pageLogin/ResetPasswordOtpScreen.dart';
import 'package:soso/widgets/ChatScreen.dart';
import 'package:soso/widgets/EditProfileScreen.dart';

Route<dynamic> onGenerateRoute(RouteSettings settings) {
  switch (settings.name) {
    case Registerpage1.routename:
      return MaterialPageRoute(
        builder: (context) => Registerpage1(),
        settings: settings,
      );
    case Registerpage2.routeName:
      return MaterialPageRoute(
        builder: (context) => Registerpage2(),
        settings: settings,
      );
    case EditProfileScreen.routeName:
      return MaterialPageRoute(
        builder: (context) => EditProfileScreen(),
        settings: settings,
      );
    case EmailConfirmationScreen.routeName:
      return MaterialPageRoute(
        builder: (context) => EmailConfirmationScreen(),
        settings: settings,
      );
    case PhoneOtpScreen.routeName:
      return MaterialPageRoute(
        builder: (context) => PhoneOtpScreen(),
        settings: settings,
      );
    case LoginPage.routeName:
      return MaterialPageRoute(
        builder: (context) => LoginPage(),
        settings: settings,
      );

    case ForgotPasswordPhone.routeName:
      return MaterialPageRoute(
        builder: (context) => ForgotPasswordPhone(),
        settings: settings,
      );
    case ResetPasswordOtpScreen.routeName:
      return MaterialPageRoute(
        builder: (context) => ResetPasswordOtpScreen(),
        settings: settings,
      );
    case ChangePasswordScreen.routeName:
      return MaterialPageRoute(
        builder: (context) => ChangePasswordScreen(),
        settings: settings,
      );
    case HomeScreen.routeName:
      return MaterialPageRoute(
        builder: (context) => HomeScreen(),
        settings: settings,
      );
    case CommentsScreen.routeName:
      final args = settings.arguments as Map<String, dynamic>;
      return MaterialPageRoute(
        builder: (context) => CommentsScreen(post: args),
        settings: settings,
      );
    case ChatScreen.routeName:
      final args = settings.arguments as Map<String, dynamic>;
      return MaterialPageRoute(
        builder: (context) => ChatScreen(user: args),
        settings: settings,
      );

    default:
      return MaterialPageRoute(builder: (context) => Scaffold());
  }
}

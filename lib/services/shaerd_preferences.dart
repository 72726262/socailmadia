

import 'package:shared_preferences/shared_preferences.dart';

class SharedprefencesSingleton
{
  static late SharedPreferences instance;

  static Future<void> init() async
  {
      instance=await SharedPreferences.getInstance();
  }

 static setBool(String key , bool value)
 {
  instance.setBool(key, value);
 }


 static getBool(String key)
 {
   return instance.getBool(key)??false;
 }



}
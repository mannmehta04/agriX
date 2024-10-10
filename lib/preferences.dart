import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  static SharedPreferences? preferences;
  static bool isEnglish = true;
  static init() async {
    preferences = await SharedPreferences.getInstance();
  }
  static  setLanguge(bool value) async {
    isEnglish = value;
    await preferences!.setBool("language", value);
  }
  static  getLanguage() async {
    isEnglish = await preferences?.getBool("language")??true;
  }
}
import 'package:app/resources/user_settings.dart';
import 'package:flutter/services.dart';

class AppSettings {
  //Colors
  static Color get primary => UserSettings.isDarkmode ? const Color(0xFF00FF00) : const Color(0xFF0074B6);
  static Color get primaryShade80 => UserSettings.isDarkmode ? const Color(0xFF00FF00) : const Color(0x500074B6);
  static Color get primaryShade48 => UserSettings.isDarkmode ? const Color(0xFF00FF00) : const Color(0x300074B6);
  static Color get startUp => UserSettings.isDarkmode ? const Color(0xFF00FF00) : const Color(0xFF02B3EE);
  static Color get background => UserSettings.isDarkmode ? const Color(0xFF00FF00) : const Color(0xFFFFFFFF);
  static Color get backgroundV1 => UserSettings.isDarkmode ? const Color(0xFF00FF00) : const Color(0xFF0074B6);
  static Color get error => UserSettings.isDarkmode ? const Color(0xFF00FF00) : const Color(0xFFB02020);
  static Color get confirm => UserSettings.isDarkmode ? const Color(0xFF00FF00) : const Color.fromARGB(255, 51, 95, 47);
  static Color get font => UserSettings.isDarkmode ? const Color(0xFF00FF00) : const Color(0xFF000000);
  static Color get fontV1 => UserSettings.isDarkmode ? const Color(0xFF00FF00) : const Color(0xFFFFFFFF);
  static Color get blocked => UserSettings.isDarkmode ? const Color(0xFF00FF00) : const Color(0x30FFFFFF);

  //Style
  static double elevation = 10.0;

  //Fontsize
  static double fontsize = UserSettings.fontsize;
  static double fontsizeTitle = UserSettings.fontsize + 8;
  static double fontsizeMainTitle = UserSettings.fontsize + 20;
  static double fontsizeDescription = UserSettings.fontsize - 3;
  static double fontsizeSubDescription = UserSettings.fontsize - 6;
}

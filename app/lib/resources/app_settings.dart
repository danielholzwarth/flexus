import 'package:app/resources/user_settings.dart';
import 'package:flutter/services.dart';

class AppSettings {
  //Colors
  static Color get primary => UserSettings.isDarkMode ? const Color(0xFF00FF00) : const Color(0xFF0074B6);
  static Color get primaryShade80 => UserSettings.isDarkMode ? const Color(0xFF00FF00) : const Color(0x500074B6);
  static Color get primaryShade48 => UserSettings.isDarkMode ? const Color(0xFF00FF00) : const Color(0x300074B6);
  static Color get startUp => UserSettings.isDarkMode ? const Color(0xFF00FF00) : const Color(0xFF02B3EE);
  static Color get background => UserSettings.isDarkMode ? const Color(0xFF00FF00) : const Color(0xFFFFFFFF);
  static Color get backgroundV1 => UserSettings.isDarkMode ? const Color(0xFF00FF00) : const Color(0xFF0074B6);
  static Color get error => UserSettings.isDarkMode ? const Color(0xFF00FF00) : const Color(0xFFB02020);
  static Color get confirm => UserSettings.isDarkMode ? const Color(0xFF00FF00) : const Color.fromARGB(255, 51, 95, 47);
  static Color get font => UserSettings.isDarkMode ? const Color(0xFF00FF00) : const Color(0xFF000000);
  static Color get fontV1 => UserSettings.isDarkMode ? const Color(0xFF00FF00) : const Color(0xFFFFFFFF);
  static Color get blocked => UserSettings.isDarkMode ? const Color(0xFF00FF00) : const Color(0x30FFFFFF);

  //Style
  static double elevation = 10.0;

  //Fontsize
  static double fontSize = UserSettings.fontSize;
  static double fontSizeTitleSmall = UserSettings.fontSize + 4;
  static double fontSizeTitle = UserSettings.fontSize + 8;
  static double fontSizeMainTitle = UserSettings.fontSize + 24;
  static double fontSizeDescription = UserSettings.fontSize - 3;
  static double fontSizeSubDescription = UserSettings.fontSize - 6;
}

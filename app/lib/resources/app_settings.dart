import 'package:flutter/services.dart';

class AppSettings {
  static String ipv4 = "";

  static bool hasConnection = false;
  static bool isTokenExpired = true;

  static var fontSize = 15.0;
  static var isDarkMode = false;
  static var language = "DE";

  static double screenWidth = 0.0;
  static double screenHeight = 0.0;

  //Colors
  static Color get primary => isDarkMode ? const Color(0xFFFFFFFF) : const Color(0xFF0074B6);
  static Color get primaryShade80 => isDarkMode ? const Color(0xFFFFFFFF) : const Color(0x500074B6);
  static Color get primaryShade48 => isDarkMode ? const Color(0xFFFFFFFF) : const Color(0x300074B6);
  static Color get startUp => isDarkMode ? const Color(0xFF000000) : const Color(0xFF02B3EE);
  static Color get background => isDarkMode ? const Color(0xFF000000) : const Color(0xFFFFFFFF);
  static Color get backgroundV1 => isDarkMode ? const Color(0xFF404040) : const Color(0xFF0074B6);
  static Color get error => isDarkMode ? const Color(0xFFB02020) : const Color(0xFFB02020);
  static Color get confirm => isDarkMode ? const Color(0xFF00FF00) : const Color.fromARGB(255, 51, 95, 47);
  static Color get font => isDarkMode ? const Color(0xFF0074B6) : const Color(0xFF000000);
  static Color get fontV1 => isDarkMode ? const Color(0xFF00FF00) : const Color(0xFFFFFFFF);
  static Color get blocked => isDarkMode ? const Color(0xFF00FF00) : const Color(0x30FFFFFF);

  //Style
  static double elevation = 10.0;

  //Fontsize
  static double fontSizeTitleSmall = fontSize + 4;
  static double fontSizeTitle = fontSize + 8;
  static double fontSizeMainTitle = fontSize + 24;
  static double fontSizeDescription = fontSize - 3;
  static double fontSizeSubDescription = fontSize - 6;
}

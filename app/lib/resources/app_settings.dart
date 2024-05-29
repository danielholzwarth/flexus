import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppSettings {
  static String ipv4 = "213.109.162.134";
  static bool useIPv4 = true;

  static bool hasConnection = true;
  static bool isTokenExpired = false;

  static Duration timeZoneOffset = const Duration();

  static var isDarkMode = false;
  static var language = "DE";

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
  static Color get blocked => isDarkMode ? const Color(0xFF00FF00) : const Color.fromARGB(255, 202, 202, 202);

  //Style
  static double elevation = 10.0;

  //Fontsize
  static double fontSize = 15.0;
  static double fontSizeBig = 80.0;
  static double fontSizeH1 = 40.0;
  static double fontSizeH2 = 32.0;
  static double fontSizeH3 = 24.0;
  static double fontSizeH4 = 20.0;
  static double fontSizeT2 = 12.0;
  static double fontSizeT3 = 10.0;
  static double fontSizeT4 = 8.0;

  static List<Color> statisticColors = [
    const Color(0xFF0074B6),
    const Color(0xFF1D5CAD),
    const Color(0xFF3A45A4),
    const Color(0xFF572D9B),
    const Color(0xFF741692),
    const Color(0xFF910089),
    const Color(0xFF4300B6),
  ];
}

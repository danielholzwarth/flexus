import 'package:app/resources/user_settings.dart';
import 'package:flutter/services.dart';

class AppColors {
  static Color get primary => UserAppSettings.isDarkmode ? const Color(0xFF00FF00) : const Color(0xFF0074B6);
  static Color get primaryV1 => UserAppSettings.isDarkmode ? const Color(0xFF00FF00) : const Color(0x500074B6);
  static Color get primaryV2 => UserAppSettings.isDarkmode ? const Color(0xFF00FF00) : const Color(0x300074B6);
  static Color get background => UserAppSettings.isDarkmode ? const Color(0xFF00FF00) : const Color(0xFFFFFFFF);
  static Color get error => UserAppSettings.isDarkmode ? const Color(0xFF00FF00) : const Color(0xFFB02020);
  static Color get font => UserAppSettings.isDarkmode ? const Color(0xFF00FF00) : const Color(0xFF000000);
  static Color get blocked => UserAppSettings.isDarkmode ? const Color(0xFF00FF00) : const Color(0x30FFFFFF);
}

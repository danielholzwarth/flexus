import 'package:hive/hive.dart';

part 'user_settings.g.dart';

@HiveType(typeId: 1)
class UserSettings extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  int userAccountID;

  @HiveField(2)
  double fontSize;

  @HiveField(3)
  bool isDarkMode;

  @HiveField(4)
  int languageID;

  @HiveField(5)
  bool isUnlisted;

  @HiveField(6)
  bool isPullFromEveryone;

  @HiveField(7)
  int? pullUserListID;

  @HiveField(8)
  bool isNotifyEveryone;

  @HiveField(9)
  int? notifyUserListID;

  @HiveField(10)
  bool isQuickAccess;

  UserSettings({
    required this.id,
    required this.userAccountID,
    required this.fontSize,
    required this.isDarkMode,
    required this.languageID,
    required this.isUnlisted,
    required this.isPullFromEveryone,
    this.pullUserListID,
    required this.isNotifyEveryone,
    this.notifyUserListID,
    required this.isQuickAccess,
  });
}

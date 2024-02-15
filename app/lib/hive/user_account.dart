import 'package:hive/hive.dart';

part 'user_account.g.dart';

@HiveType(typeId: 0)
class UserAccount extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  String username;

  @HiveField(2)
  String name;

  @HiveField(3)
  DateTime createdAt;

  @HiveField(4)
  int level;

  @HiveField(5)
  String? profilePicture;

  @HiveField(6)
  int? bodyweight;

  @HiveField(7)
  int? genderID;

  UserAccount({
    required this.id,
    required this.username,
    required this.name,
    required this.createdAt,
    required this.level,
    this.profilePicture,
    this.bodyweight,
    this.genderID,
  });
}

import 'package:hive/hive.dart';

part 'user_account.g.dart';

@HiveType(typeId: 0)
class UserAccount extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  int username;

  @HiveField(2)
  int name;

  @HiveField(3)
  int createdAt;

  @HiveField(4)
  bool level;

  @HiveField(5)
  bool profilePicture;

  @HiveField(6)
  int bodyweight;

  @HiveField(7)
  bool genderID;

  UserAccount({
    required this.id,
    required this.username,
    required this.name,
    required this.createdAt,
    required this.level,
    required this.profilePicture,
    required this.bodyweight,
    required this.genderID,
  });
}

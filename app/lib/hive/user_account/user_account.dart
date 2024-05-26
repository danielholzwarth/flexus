import 'dart:convert';
import 'dart:typed_data';

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
  DateTime? createdAt;

  @HiveField(4)
  int level;

  @HiveField(5)
  Uint8List? profilePicture;

  UserAccount({
    required this.id,
    required this.username,
    required this.name,
    required this.createdAt,
    required this.level,
    this.profilePicture,
  });

  UserAccount.fromJson(Map<String, dynamic> json)
      : id = json['userAccountID'] as int,
        username = json['username'] as String,
        name = json['name'] as String,
        createdAt = DateTime.parse(json['createdAt']),
        level = json['level'] as int,
        profilePicture = json['profilePicture'] != null ? base64Decode(json['profilePicture']) : null;
}

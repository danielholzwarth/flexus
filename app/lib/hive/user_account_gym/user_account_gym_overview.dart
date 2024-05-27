import 'dart:convert';
import 'dart:typed_data';
import 'package:app/resources/app_settings.dart';
import 'package:hive/hive.dart';

part 'user_account_gym_overview.g.dart';

@HiveType(typeId: 9)
class UserAccountGymOverview extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  String username;

  @HiveField(2)
  String name;

  @HiveField(3)
  Uint8List? profilePicture;

  @HiveField(4)
  DateTime workoutStartTime;

  @HiveField(5)
  Duration? averageWorkoutDuration;

  UserAccountGymOverview({
    required this.id,
    required this.username,
    required this.name,
    this.profilePicture,
    required this.workoutStartTime,
    this.averageWorkoutDuration,
  });

  UserAccountGymOverview.fromJson(Map<String, dynamic> json)
      : id = json['userAccountID'] as int,
        username = json['username'] as String,
        name = json['name'] as String,
        profilePicture = json['profilePicture'] != null ? base64Decode(json['profilePicture']) : null,
        workoutStartTime = DateTime.parse(json['workoutStartTime']).add(AppSettings.timeZoneOffset),
        averageWorkoutDuration = Duration(seconds: json['averageWorkoutDuration'] != null ? json['averageWorkoutDuration']?.toInt() : 0);
}

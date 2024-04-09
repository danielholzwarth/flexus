import 'dart:typed_data';

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
}

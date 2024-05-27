import 'package:app/resources/app_settings.dart';
import 'package:hive/hive.dart';

part 'workout.g.dart';

@HiveType(typeId: 2)
class Workout extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  int userAccountID;

  @HiveField(2)
  int? splitID;

  @HiveField(3)
  DateTime createdAt;

  @HiveField(4)
  DateTime starttime;

  @HiveField(5)
  DateTime? endtime;

  @HiveField(6)
  bool isActive;

  @HiveField(7)
  bool isArchived;

  @HiveField(8)
  bool isStared;

  @HiveField(9)
  bool isPinned;

  Workout({
    required this.id,
    required this.userAccountID,
    this.splitID,
    required this.createdAt,
    required this.starttime,
    this.endtime,
    required this.isActive,
    required this.isArchived,
    required this.isStared,
    required this.isPinned,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userAccountID': userAccountID,
      'starttime': starttime.subtract(AppSettings.timeZoneOffset).toIso8601String(),
      'endtime': endtime?.subtract(AppSettings.timeZoneOffset).toIso8601String(),
      'isArchived': isArchived,
      'isStared': isStared,
      'isPinned': isPinned,
    };
  }

  Workout.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int,
        userAccountID = json['userAccountID'] as int,
        splitID = json['splitID'] != null ? json['split'] as int : null,
        createdAt = DateTime.parse(json['createdAt']).add(AppSettings.timeZoneOffset),
        starttime = DateTime.parse(json['starttime']).add(AppSettings.timeZoneOffset),
        endtime = json['endtime'] != null ? DateTime.parse(json['endtime']).add(AppSettings.timeZoneOffset) : null,
        isActive = json['isActive'] as bool,
        isArchived = json['isArchived'] as bool,
        isStared = json['isStared'] as bool,
        isPinned = json['isPinned'] as bool;
}

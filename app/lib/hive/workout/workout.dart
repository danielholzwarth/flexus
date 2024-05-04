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
      'starttime': starttime.toIso8601String(),
      'endtime': endtime?.toIso8601String(),
      'isArchived': isArchived,
      'isStared': isStared,
      'isPinned': isPinned,
    };
  }
}

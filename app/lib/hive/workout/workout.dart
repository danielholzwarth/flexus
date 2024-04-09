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
  DateTime starttime;

  @HiveField(4)
  DateTime? endtime;

  @HiveField(5)
  bool isArchived;

  @HiveField(6)
  bool isStared;

  @HiveField(7)
  bool isPinned;

  Workout({
    required this.id,
    required this.userAccountID,
    this.splitID,
    required this.starttime,
    this.endtime,
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

import 'package:hive/hive.dart';

part 'workout.g.dart';

@HiveType(typeId: 1)
class Workout extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  int userAccountID;

  @HiveField(2)
  int? planID;

  @HiveField(3)
  int? splitID;

  @HiveField(4)
  DateTime starttime;

  @HiveField(5)
  DateTime? endtime;

  @HiveField(6)
  bool isArchived;

  Workout({
    required this.id,
    required this.userAccountID,
    this.planID,
    this.splitID,
    required this.starttime,
    this.endtime,
    required this.isArchived,
  });
}

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

  Workout({
    required this.id,
    required this.userAccountID,
    this.splitID,
    required this.starttime,
    this.endtime,
    required this.isArchived,
  });
}

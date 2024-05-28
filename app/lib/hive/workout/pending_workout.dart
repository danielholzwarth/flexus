import 'package:hive/hive.dart';

part 'pending_workout.g.dart';

@HiveType(typeId: 25)
class PendingWorkout extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  int workoutID;

  @HiveField(2)
  int? planID;

  @HiveField(3)
  int? splitID;

  @HiveField(4)
  int? gymID;

  @HiveField(5)
  List<Map<String, dynamic>> exercisesJSON;

  PendingWorkout({
    required this.id,
    required this.workoutID,
    this.planID,
    this.splitID,
    this.gymID,
    required this.exercisesJSON,
  });
}

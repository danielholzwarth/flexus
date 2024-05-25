import 'package:hive/hive.dart';

part 'workout_set.g.dart';

@HiveType(typeId: 19)
class WorkoutSet extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  int workoutID;

  @HiveField(2)
  int exerciseID;

  @HiveField(3)
  int orderNumber;

  @HiveField(4)
  int repetitions;

  @HiveField(5)
  double workload;

  WorkoutSet({
    required this.id,
    required this.workoutID,
    required this.exerciseID,
    required this.orderNumber,
    required this.repetitions,
    required this.workload,
  });

  WorkoutSet.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int,
        workoutID = json['workoutID'] as int,
        exerciseID = json['exerciseID'] as int,
        orderNumber = json['orderNumber'] as int,
        repetitions = json['repetitions'] as int,
        workload = double.parse(json['workload'].toString());
}

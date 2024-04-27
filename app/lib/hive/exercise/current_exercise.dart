import 'package:app/hive/exercise/exercise.dart';
import 'package:app/hive/workout/measurement.dart';
import 'package:hive/hive.dart';

part 'current_exercise.g.dart';

@HiveType(typeId: 21)
class CurrentExercise extends HiveObject {
  @HiveField(0)
  Exercise exercise;

  @HiveField(1)
  String goal;

  @HiveField(2)
  List<Measurement> measurements;

  CurrentExercise({
    required this.exercise,
    required this.goal,
    required this.measurements,
  });
}

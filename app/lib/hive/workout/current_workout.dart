import 'package:app/hive/exercise/current_exercise.dart';
import 'package:app/hive/gym/gym.dart';
import 'package:app/hive/plan/plan.dart';
import 'package:app/hive/split/split.dart';
import 'package:hive/hive.dart';

part 'current_workout.g.dart';

@HiveType(typeId: 20)
class CurrentWorkout extends HiveObject {
  @HiveField(0)
  Gym? gym;

  @HiveField(1)
  Plan? plan;

  @HiveField(2)
  Split? split;

  @HiveField(3)
  List<CurrentExercise> exercises;

  CurrentWorkout({
    this.gym,
    this.plan,
    this.split,
    required this.exercises,
  });
}

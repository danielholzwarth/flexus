import 'package:app/hive/exercise/exercise.dart';
import 'package:app/hive/gym/gym.dart';
import 'package:app/hive/set/workout_set.dart';
import 'package:app/hive/split/split.dart';
import 'package:hive/hive.dart';

part 'workout_details.g.dart';

@HiveType(typeId: 17)
class WorkoutDetails extends HiveObject {
  @HiveField(0)
  int workoutID;

  @HiveField(1)
  DateTime date;

  @HiveField(2)
  Gym? gym;

  @HiveField(3)
  int duration;

  @HiveField(4)
  Split? split;

  @HiveField(5)
  List<Exercise> exercises;

  @HiveField(6)
  List<List<WorkoutSet>> sets;

  @HiveField(7)
  List<int> pbSetIDs;

  WorkoutDetails({
    required this.workoutID,
    required this.gym,
    required this.date,
    required this.duration,
    this.split,
    required this.exercises,
    required this.sets,
    required this.pbSetIDs,
  });
}

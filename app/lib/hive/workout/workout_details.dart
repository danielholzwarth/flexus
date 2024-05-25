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
  DateTime startTime;

  @HiveField(2)
  DateTime? endtime;

  @HiveField(3)
  Gym? gym;

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
    required this.startTime,
    required this.endtime,
    required this.gym,
    this.split,
    required this.exercises,
    required this.sets,
    required this.pbSetIDs,
  });

  WorkoutDetails.fromJson(Map<String, dynamic> json)
      : workoutID = json['workoutID'] as int,
        startTime = DateTime.parse(json['starttime']),
        endtime = json['endtime'] != null ? DateTime.parse(json['endtime']) : null,
        gym = json['gym'] != null ? Gym.fromJson(json['gym']) : null,
        split = json['split'] != null ? Split.fromJson(json['split']) : null,
        exercises = json['measurements'] != null
            ? List<Exercise>.from(json['exercises'].map((exercisesJson) {
                return Exercise.fromJson(exercisesJson);
              }))
            : [],
        sets = json['split'] != null
            ? List<List<WorkoutSet>>.from(json['split'].map((measurementListJson) {
                return List<Map<String, dynamic>>.from(measurementListJson).map((measurementMap) {
                  return WorkoutSet.fromJson(measurementMap);
                });
              }))
            : [],
        pbSetIDs = List<int>.from(json['pbSetIDs']);
}

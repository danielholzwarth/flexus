import 'package:app/hive/exercise/exercise.dart';
import 'package:app/hive/split/split.dart';
import 'package:app/hive/workout/measurement.dart';
import 'package:hive/hive.dart';

part 'split_overview.g.dart';

@HiveType(typeId: 16)
class SplitOverview extends HiveObject {
  @HiveField(0)
  Split split;

  @HiveField(1)
  List<Exercise> exercises;

  @HiveField(2)
  List<Measurement> measurements;

  SplitOverview({
    required this.split,
    required this.exercises,
    required this.measurements,
  });

  SplitOverview.fromJson(Map<String, dynamic> json)
      : split = Split.fromJson(json['split']),
        exercises = json['exercises'] != null
            ? List<Exercise>.from(json['exercises'].map((exercisesJson) {
                return Exercise.fromJson(exercisesJson);
              }))
            : [],
        measurements = json['measurements'] != null
            ? List<Measurement>.from(json['measurements'].map((measurementsJson) {
                return Measurement.fromJson(measurementsJson);
              }))
            : [];
}

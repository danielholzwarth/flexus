import 'package:app/hive/exercise/exercise.dart';
import 'package:app/hive/workout/measurement.dart';
import 'package:hive/hive.dart';

part 'current_exercise.g.dart';

@HiveType(typeId: 21)
class CurrentExercise extends HiveObject {
  @HiveField(0)
  Exercise exercise;

  @HiveField(1)
  List<Measurement> oldMeasurements;

  @HiveField(2)
  List<Measurement> measurements;

  CurrentExercise({
    required this.exercise,
    required this.oldMeasurements,
    required this.measurements,
  });

  Map<String, dynamic> toJson() {
    return {
      'exercise': exercise.toJson(),
      'oldMeasurements': oldMeasurements.map((measurement) => measurement.toJson()).toList(),
      'measurements': measurements.map((measurement) => measurement.toJson()).toList(),
    };
  }

  CurrentExercise.fromJson(Map<String, dynamic> json)
      : exercise = Exercise.fromJson(json),
        oldMeasurements = json['oldMeasurements'] != null
            ? List<Measurement>.from((json['oldMeasurements']).map((measurementJson) {
                return Measurement.fromJson(measurementJson);
              }))
            : [],
        measurements = [];
}

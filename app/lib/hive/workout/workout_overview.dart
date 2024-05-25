import 'package:app/hive/workout/workout.dart';
import 'package:hive/hive.dart';

part 'workout_overview.g.dart';

@HiveType(typeId: 3)
class WorkoutOverview extends HiveObject {
  @HiveField(0)
  Workout workout;

  @HiveField(1)
  String? splitName;

  @HiveField(2)
  String? planName;

  @HiveField(3)
  int bestLiftCount;

  WorkoutOverview({
    required this.workout,
    this.splitName,
    this.planName,
    required this.bestLiftCount,
  });

  WorkoutOverview.fromJson(Map<String, dynamic> json)
      : workout = Workout.fromJson(json['workout']),
        splitName = json['splitName'] as String?,
        planName = json['planName'] as String?,
        bestLiftCount = json['pbCount'] as int;
}

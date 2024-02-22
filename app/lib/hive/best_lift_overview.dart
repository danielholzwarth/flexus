import 'package:app/hive/best_lift.dart';
import 'package:hive/hive.dart';

part 'best_lift_overview.g.dart';

@HiveType(typeId: 6)
class BestLiftOverview extends HiveObject {
  @HiveField(0)
  BestLift bestLift;

  @HiveField(1)
  String exerciseName;

  @HiveField(2)
  int? repetitions;

  @HiveField(3)
  double? weight;

  @HiveField(4)
  double? duration;

  BestLiftOverview({
    required this.bestLift,
    required this.exerciseName,
    this.repetitions,
    this.weight,
    this.duration,
  });
}

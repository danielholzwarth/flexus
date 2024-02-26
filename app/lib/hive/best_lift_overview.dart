import 'package:hive/hive.dart';

part 'best_lift_overview.g.dart';

@HiveType(typeId: 6)
class BestLiftOverview extends HiveObject {
  @HiveField(0)
  String exerciseName;

  @HiveField(1)
  int? repetitions;

  @HiveField(2)
  double? weight;

  @HiveField(3)
  double? duration;

  BestLiftOverview({
    required this.exerciseName,
    this.repetitions,
    this.weight,
    this.duration,
  });
}

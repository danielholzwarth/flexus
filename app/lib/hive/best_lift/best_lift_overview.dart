import 'package:hive/hive.dart';

part 'best_lift_overview.g.dart';

@HiveType(typeId: 6)
class BestLiftOverview extends HiveObject {
  @HiveField(0)
  String exerciseName;

  @HiveField(1)
  int repetitions;

  @HiveField(2)
  double workload;

  @HiveField(3)
  bool isRepetition;

  @HiveField(4)
  int position;

  BestLiftOverview({
    required this.exerciseName,
    required this.repetitions,
    required this.workload,
    required this.isRepetition,
    required this.position,
  });
}

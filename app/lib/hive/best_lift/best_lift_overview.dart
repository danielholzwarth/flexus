import 'package:hive/hive.dart';

part 'best_lift_overview.g.dart';

@HiveType(typeId: 6)
class BestLiftOverview extends HiveObject {
  @HiveField(0)
  String exerciseName;

  @HiveField(1)
  String? measurement;

  BestLiftOverview({
    required this.exerciseName,
    this.measurement,
  });
}

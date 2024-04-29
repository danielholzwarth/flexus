import 'package:app/hive/plan/plan.dart';
import 'package:app/hive/split/split.dart';
import 'package:hive/hive.dart';

part 'current_plan.g.dart';

@HiveType(typeId: 22)
class CurrentPlan extends HiveObject {
  @HiveField(0)
  Plan plan;

  @HiveField(1)
  int currentSplit;

  @HiveField(2)
  List<Split> splits;

  CurrentPlan({
    required this.plan,
    required this.currentSplit,
    required this.splits,
  });
}

import 'package:app/hive/plan.dart';
import 'package:app/hive/split_overview.dart';
import 'package:hive/hive.dart';

part 'plan_overview.g.dart';

@HiveType(typeId: 14)
class PlanOverview extends HiveObject {
  @HiveField(0)
  Plan plan;

  @HiveField(1)
  List<SplitOverview> splitOverviews;

  PlanOverview({
    required this.plan,
    required this.splitOverviews,
  });
}

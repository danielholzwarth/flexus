part of 'plan_bloc.dart';

@immutable
abstract class PlanEvent {}

class PostPlan extends PlanEvent {
  final int splitCount;
  final String planName;
  final bool isWeekly;
  final List<bool> weeklyRestList;

  PostPlan({
    required this.splitCount,
    required this.planName,
    required this.isWeekly,
    required this.weeklyRestList,
  });
}

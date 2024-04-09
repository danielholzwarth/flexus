part of 'plan_bloc.dart';

@immutable
abstract class PlanEvent {}

class GetActivePlan extends PlanEvent {}

class GetPlans extends PlanEvent {}

class PostPlan extends PlanEvent {
  final int splitCount;
  final String planName;
  final bool isWeekly;
  final List<bool> weeklyRestList;
  final List<String> splits;
  final List<List<int>> exercises;

  PostPlan({
    required this.splitCount,
    required this.planName,
    required this.isWeekly,
    required this.weeklyRestList,
    required this.splits,
    required this.exercises,
  });
}

class PatchPlan extends PlanEvent {
  final int planID;
  final String name;
  final dynamic value;

  PatchPlan({
    required this.planID,
    required this.name,
    required this.value,
  });
}

class GetPlanOverview extends PlanEvent {}

class DeletePlan extends PlanEvent {
  final int planID;

  DeletePlan({
    required this.planID,
  });
}

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
  final dynamic value2;
  final dynamic value3;

  PatchPlan({
    required this.planID,
    required this.name,
    required this.value,
    this.value2,
    this.value3,
  });
}

class GetPlanOverview extends PlanEvent {
  final int planID;

  GetPlanOverview({
    required this.planID,
  });
}

class DeletePlan extends PlanEvent {
  final int planID;

  DeletePlan({
    required this.planID,
  });
}

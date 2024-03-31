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

  PostPlan({
    required this.splitCount,
    required this.planName,
    required this.isWeekly,
    required this.weeklyRestList,
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

class DeletePlan extends PlanEvent {
  final int planID;

  DeletePlan({
    required this.planID,
  });
}

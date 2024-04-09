part of 'plan_bloc.dart';

@immutable
abstract class PlanState {}

class PlanInitial extends PlanState {}

class PlanCreating extends PlanState {}

class PlanCreated extends PlanState {}

class PlanLoading extends PlanState {}

class PlanLoaded extends PlanState {
  final Plan? plan;

  PlanLoaded({
    required this.plan,
  });
}

class PlansLoading extends PlanState {}

class PlansLoaded extends PlanState {
  final List<Plan> plans;

  PlansLoaded({
    required this.plans,
  });
}

class PlanPatching extends PlanState {}

class PlanDeleting extends PlanState {}

class PlanDeleted extends PlanState {}

class PlanOverviewLoading extends PlanState {}

class PlanOverviewLoaded extends PlanState {
  final PlanOverview? planOverview;

  PlanOverviewLoaded({
    required this.planOverview,
  });
}

class PlanError extends PlanState {
  final String error;

  PlanError({
    required this.error,
  });
}

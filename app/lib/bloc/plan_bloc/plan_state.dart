part of 'plan_bloc.dart';

@immutable
abstract class PlanState {}

class PlanInitial extends PlanState {}

class PlanCreating extends PlanState {}

class PlanCreated extends PlanState {}

class PlansLoading extends PlanState {}

class PlansLoaded extends PlanState {
  final List<Plan> plans;

  PlansLoaded({
    required this.plans,
  });
}

class PlanError extends PlanState {
  final String error;

  PlanError({
    required this.error,
  });
}

part of 'plan_bloc.dart';

@immutable
abstract class PlanState {}

class PlanInitial extends PlanState {}

class PlanCreating extends PlanState {}

class PlanCreated extends PlanState {}

class PlanError extends PlanState {
  final String error;

  PlanError({
    required this.error,
  });
}

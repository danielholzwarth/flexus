part of 'workout_bloc.dart';

@immutable
abstract class WorkoutState {}

class WorkoutInitial extends WorkoutState {}

class WorkoutLoading extends WorkoutState {}

class WorkoutLoaded extends WorkoutState {
  final List<WorkoutOverview> workoutOverviews;

  WorkoutLoaded({
    required this.workoutOverviews,
  });
}

class WorkoutError extends WorkoutState {}

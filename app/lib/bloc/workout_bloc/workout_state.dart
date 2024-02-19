part of 'workout_bloc.dart';

@immutable
abstract class WorkoutState {}

class WorkoutInitial extends WorkoutState {}

class WorkoutLoading extends WorkoutState {}

class WorkoutLoaded extends WorkoutState {
  final List<Workout> workouts;
  final bool isOffline;

  WorkoutLoaded({
    required this.workouts,
    required this.isOffline,
  });
}

class WorkoutError extends WorkoutState {}

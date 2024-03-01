part of 'workout_bloc.dart';

@immutable
abstract class WorkoutState {}

class WorkoutInitial extends WorkoutState {}

class WorkoutLoading extends WorkoutState {}

class WorkoutLoaded extends WorkoutState {}

class WorkoutDeleting extends WorkoutState {}

class WorkoutDeleted extends WorkoutState {}

class WorkoutError extends WorkoutState {}

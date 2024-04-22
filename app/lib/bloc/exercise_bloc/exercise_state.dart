part of 'exercise_bloc.dart';

@immutable
abstract class ExerciseState {}

class ExerciseInitial extends ExerciseState {}

class ExerciseCreating extends ExerciseState {}

class ExerciseCreated extends ExerciseState {}

class ExerciseLoading extends ExerciseState {}

class ExerciseLoaded extends ExerciseState {
  final Exercise exercise;

  ExerciseLoaded({required this.exercise});
}

class ExercisesLoading extends ExerciseState {}

class ExercisesLoaded extends ExerciseState {
  final List<Exercise> exercises;

  ExercisesLoaded({required this.exercises});
}

class ExerciseError extends ExerciseState {
  final String error;

  ExerciseError({
    required this.error,
  });
}

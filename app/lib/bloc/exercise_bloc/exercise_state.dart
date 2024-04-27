part of 'exercise_bloc.dart';

@immutable
abstract class ExerciseState {}

class ExerciseInitial extends ExerciseState {}

class ExerciseCreating extends ExerciseState {}

class ExerciseCreated extends ExerciseState {}

class ExercisesLoading extends ExerciseState {}

class ExercisesLoaded extends ExerciseState {
  final List<Exercise> exercises;

  ExercisesLoaded({required this.exercises});
}

class ExercisesFromSplitIDLoaded extends ExerciseState {
  final List<Exercise> exercises;

  ExercisesFromSplitIDLoaded({required this.exercises});
}

class ExerciseError extends ExerciseState {
  final String error;

  ExerciseError({
    required this.error,
  });
}

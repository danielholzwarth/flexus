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

class ExerciseFromExerciseIDLoaded extends ExerciseState {
  final CurrentExercise? currentExercise;

  ExerciseFromExerciseIDLoaded({
    required this.currentExercise,
  });
}

class ExercisesFromSplitIDLoaded extends ExerciseState {
  final List<CurrentExercise> currentExercises;

  ExercisesFromSplitIDLoaded({
    required this.currentExercises,
  });
}

class CurrentExercisesLoaded extends ExerciseState {
  final List<CurrentExercise> currentExercises;

  CurrentExercisesLoaded({required this.currentExercises});
}

class ExerciseError extends ExerciseState {
  final String error;

  ExerciseError({
    required this.error,
  });
}

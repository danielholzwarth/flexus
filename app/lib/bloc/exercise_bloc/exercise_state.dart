part of 'exercise_bloc.dart';

@immutable
abstract class ExerciseState {}

class ExerciseInitial extends ExerciseState {}

class ExerciseCreated extends ExerciseState {}

class ExercisesLoaded extends ExerciseState {
  final List<Exercise> exercises;

  ExercisesLoaded({required this.exercises});
}

class CurrentExerciseFromExerciseIDLoaded extends ExerciseState {
  final CurrentExercise? currentExercise;

  CurrentExerciseFromExerciseIDLoaded({
    required this.currentExercise,
  });
}

class CurrentExercisesFromSplitIDLoaded extends ExerciseState {
  final List<CurrentExercise> currentExercises;

  CurrentExercisesFromSplitIDLoaded({
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

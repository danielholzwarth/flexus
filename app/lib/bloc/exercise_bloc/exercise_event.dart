part of 'exercise_bloc.dart';

@immutable
abstract class ExerciseEvent {}

class PostExercise extends ExerciseEvent {
  final String name;
  final bool isRepetition;

  PostExercise({
    required this.name,
    required this.isRepetition,
  });
}

class GetExercises extends ExerciseEvent {}

class GetCurrentExerciseFromExerciseID extends ExerciseEvent {
  final int exerciseID;

  GetCurrentExerciseFromExerciseID({
    required this.exerciseID,
  });
}

class GetCurrentExercisesFromSplitID extends ExerciseEvent {
  final int splitID;
  final CurrentPlan currentPlan;

  GetCurrentExercisesFromSplitID({
    required this.splitID,
    required this.currentPlan,
  });
}

class RefreshGetExercisesState extends ExerciseEvent {
  final List<Exercise> exercises;

  RefreshGetExercisesState({
    required this.exercises,
  });
}

class RefreshGetCurrentExercisesState extends ExerciseEvent {
  final List<CurrentExercise> currentExercises;

  RefreshGetCurrentExercisesState({
    required this.currentExercises,
  });
}

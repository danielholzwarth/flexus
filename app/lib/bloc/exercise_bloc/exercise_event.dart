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

class GetExercisesFromSplitID extends ExerciseEvent {
  final int splitID;

  GetExercisesFromSplitID({
    required this.splitID,
  });
}

class RefreshGetExercisesState extends ExerciseEvent {
  final List<Exercise> exercises;

  RefreshGetExercisesState({
    required this.exercises,
  });
}

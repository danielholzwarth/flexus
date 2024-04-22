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

class RefreshGetExercisesState extends ExerciseEvent {
  final List<Exercise> exercises;

  RefreshGetExercisesState({
    required this.exercises,
  });
}

part of 'exercise_bloc.dart';

@immutable
abstract class ExerciseEvent {}

class PostExercise extends ExerciseEvent {
  final Exercise exercise;

  PostExercise({
    required this.exercise,
  });
}

class GetExercises extends ExerciseEvent {}

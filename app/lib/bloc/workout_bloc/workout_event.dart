part of 'workout_bloc.dart';

@immutable
abstract class WorkoutEvent {}

class LoadWorkout extends WorkoutEvent {}

class SearchWorkout extends WorkoutEvent {
  final bool isArchive;
  final String keyWord;

  SearchWorkout({
    this.isArchive = false,
    this.keyWord = "",
  });
}

class UpdateWorkout extends WorkoutEvent {
  final int workoutID;
  final bool isArchive;
  final String name;
  final dynamic value;

  UpdateWorkout({
    required this.workoutID,
    this.isArchive = false,
    required this.name,
    required this.value,
  });
}

class DeleteWorkout extends WorkoutEvent {
  final int workoutID;
  final bool isArchive;

  DeleteWorkout({
    required this.workoutID,
    this.isArchive = false,
  });
}

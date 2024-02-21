part of 'workout_bloc.dart';

@immutable
abstract class WorkoutEvent {}

class LoadWorkout extends WorkoutEvent {
  final bool isArchive;
  final bool isFromCache;
  final bool isSearch;
  final String keyWord;

  LoadWorkout({
    this.isArchive = false,
    this.isFromCache = false,
    this.isSearch = false,
    this.keyWord = "",
  });
}

class ChangeArchiveWorkout extends WorkoutEvent {
  final int workoutID;

  ChangeArchiveWorkout({
    required this.workoutID,
  });
}

class DeleteWorkout extends WorkoutEvent {
  final int workoutID;

  DeleteWorkout({
    required this.workoutID,
  });
}

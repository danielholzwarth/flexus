part of 'workout_bloc.dart';

@immutable
abstract class WorkoutEvent {}

class GetWorkout extends WorkoutEvent {
  final bool isArchive;

  GetWorkout({
    this.isArchive = false,
  });
}

class GetSearchWorkout extends WorkoutEvent {
  final bool? isArchive;
  final String keyWord;

  GetSearchWorkout({
    this.isArchive = false,
    this.keyWord = "",
  });
}

class PatchWorkout extends WorkoutEvent {
  final int workoutID;
  final bool isArchive;
  final String name;
  final dynamic value;

  PatchWorkout({
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

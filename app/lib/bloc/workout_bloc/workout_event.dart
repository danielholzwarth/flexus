part of 'workout_bloc.dart';

@immutable
abstract class WorkoutEvent {}

class PostWorkout extends WorkoutEvent {
  final int? gymID;
  final int? splitID;
  final DateTime startTime;

  PostWorkout({
    this.gymID,
    this.splitID,
    required this.startTime,
  });
}

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

class GetWorkoutDetails extends WorkoutEvent {
  final int workoutID;

  GetWorkoutDetails({
    required this.workoutID,
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

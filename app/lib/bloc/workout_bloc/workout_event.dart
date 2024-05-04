part of 'workout_bloc.dart';

@immutable
abstract class WorkoutEvent {}

class PostWorkout extends WorkoutEvent {
  final int? gymID;
  final int? splitID;
  final DateTime startTime;
  final bool? isActive;

  PostWorkout({
    this.gymID,
    this.splitID,
    required this.startTime,
    this.isActive = false,
  });
}

class GetWorkoutFromID extends WorkoutEvent {
  final int workoutID;

  GetWorkoutFromID({
    required this.workoutID,
  });
}

class GetWorkouts extends WorkoutEvent {
  final bool isArchive;

  GetWorkouts({
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
  final int? gymID;
  final int? splitID;
  final CurrentWorkout? currentWorkout;

  PatchWorkout({
    required this.workoutID,
    this.isArchive = false,
    required this.name,
    this.value,
    this.gymID,
    this.splitID,
    this.currentWorkout,
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

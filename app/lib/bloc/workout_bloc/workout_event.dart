part of 'workout_bloc.dart';

@immutable
abstract class WorkoutEvent {}

class LoadWorkout extends WorkoutEvent {
  final int userId;
  final bool fromCache;

  LoadWorkout({
    this.userId = 0,
    this.fromCache = true,
  });
}

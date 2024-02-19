import 'dart:convert';

import 'package:app/api/workout_service.dart';
import 'package:app/hive/workout.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'workout_event.dart';
part 'workout_state.dart';

class WorkoutBloc extends Bloc<WorkoutEvent, WorkoutState> {
  final WorkoutService _workoutService = WorkoutService.create();
  final userBox = Hive.box('userBox');

  WorkoutBloc() : super(WorkoutInitial()) {
    on<LoadWorkout>(_onLoadWorkout);
  }

  void _onLoadWorkout(LoadWorkout event, Emitter<WorkoutState> emit) async {
    emit(WorkoutLoading());

    var response = await _workoutService.getWorkouts(userBox.get("flexusjwt"));
    if (response.isSuccessful) {
      final List<dynamic> jsonList = jsonDecode(response.bodyString);
      final List<Workout> workouts = jsonList.map((json) {
        return Workout(
          id: json['id'],
          userAccountID: json['userAccountID'],
          planID: json['planID'],
          splitID: json['splitID'],
          starttime: json['starttime'],
          endtime: json['endtime'],
          isArchived: json['isArchived'],
        );
      }).toList();

      emit(WorkoutLoaded(workouts: workouts, isOffline: true));
    } else {
      emit(WorkoutError());
    }
  }
}

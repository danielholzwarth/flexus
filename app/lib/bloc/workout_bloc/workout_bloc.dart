import 'dart:convert';

import 'package:app/api/workout_service.dart';
import 'package:app/hive/workout.dart';
import 'package:chopper/chopper.dart';
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

    //simulate backend request delay
    await Future.delayed(const Duration(seconds: 1));

    Response<dynamic> response;
    if (event.isSearch && event.isArchive) {
      response = await _workoutService.getSearchedArchivedWorkouts(userBox.get("flexusjwt"), event.keyWord);
    } else if (event.isArchive) {
      response = await _workoutService.getArchivedWorkouts(userBox.get("flexusjwt"));
    } else if (event.isSearch) {
      response = await _workoutService.getSearchedWorkouts(userBox.get("flexusjwt"), event.keyWord);
    } else {
      response = await _workoutService.getWorkouts(userBox.get("flexusjwt"));
    }

    if (response.isSuccessful) {
      if (response.bodyString != "null") {
        final List<dynamic> jsonList = jsonDecode(response.bodyString);
        final List<Workout> workouts = jsonList.map((json) {
          return Workout(
            id: json['id'],
            userAccountID: json['userAccountID'],
            planID: json['planID'],
            splitID: json['splitID'],
            starttime: DateTime.parse(json['starttime']),
            endtime: json['endtime'] != null ? DateTime.parse(json['endtime']) : null,
            isArchived: json['isArchived'],
          );
        }).toList();

        emit(WorkoutLoaded(workouts: workouts));
      } else {
        emit(WorkoutLoaded(workouts: List.empty()));
      }
    } else {
      emit(WorkoutError());
    }
  }
}

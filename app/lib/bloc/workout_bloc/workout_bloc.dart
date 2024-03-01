import 'dart:convert';

import 'package:app/api/workout_service.dart';
import 'package:app/hive/workout.dart';
import 'package:app/hive/workout_overview.dart';
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
    on<ChangeArchiveWorkout>(_onChangeArchiveWorkout);
    on<DeleteWorkout>(_onDeleteWorkout);
  }

  void _onLoadWorkout(LoadWorkout event, Emitter<WorkoutState> emit) async {
    emit(WorkoutLoading());

    //simulate backend request delay
    // await Future.delayed(const Duration(seconds: 1));

    Response<dynamic> response;
    if (event.isSearch && event.isArchive) {
      response = await _workoutService.getSearchedArchivedWorkoutOverviews(userBox.get("flexusjwt"), event.keyWord);
    } else if (event.isArchive) {
      response = await _workoutService.getArchivedWorkoutOverviews(userBox.get("flexusjwt"));
    } else if (event.isSearch) {
      response = await _workoutService.getSearchedWorkoutOverviews(userBox.get("flexusjwt"), event.keyWord);
    } else {
      response = await _workoutService.getWorkoutOverviews(userBox.get("flexusjwt"));
    }

    if (response.isSuccessful) {
      if (response.bodyString != "null") {
        final List<dynamic> jsonList = jsonDecode(response.bodyString);
        final List<WorkoutOverview> workoutOverviews = jsonList.map((json) {
          return WorkoutOverview(
            workout: Workout(
              id: json['workout']['id'],
              userAccountID: json['workout']['userAccountID'],
              splitID: json['workout']['splitID'],
              starttime: DateTime.parse(json['workout']['starttime']),
              endtime: json['workout']['endtime'] != null ? DateTime.parse(json['workout']['endtime']) : null,
              isArchived: json['workout']['isArchived'],
            ),
            planName: json['planName'],
            splitName: json['splitName'],
          );
        }).toList();

        emit(WorkoutLoaded(workoutOverviews: workoutOverviews));
      } else {
        emit(WorkoutLoaded(workoutOverviews: List.empty()));
      }
    } else {
      emit(WorkoutError());
    }
  }

  void _onChangeArchiveWorkout(ChangeArchiveWorkout event, Emitter<WorkoutState> emit) async {
    emit(WorkoutLoading());

    //simulate backend request delay
    await Future.delayed(const Duration(seconds: 3));

    Response<dynamic> response;
    response = await _workoutService.putWorkoutArchiveStatus(userBox.get("flexusjwt"), event.workoutID);

    if (response.isSuccessful) {
      if (response.bodyString != "null") {
        final List<dynamic> jsonList = jsonDecode(response.bodyString);
        final List<WorkoutOverview> workoutOverviews = jsonList.map((json) {
          return WorkoutOverview(
            workout: Workout(
              id: json['workout']['id'],
              userAccountID: json['workout']['userAccountID'],
              splitID: json['workout']['splitID'],
              starttime: DateTime.parse(json['workout']['starttime']),
              endtime: json['workout']['endtime'] != null ? DateTime.parse(json['workout']['endtime']) : null,
              isArchived: json['workout']['isArchived'],
            ),
            planName: json['planName'],
            splitName: json['splitName'],
          );
        }).toList();

        emit(WorkoutLoaded(workoutOverviews: workoutOverviews));
      } else {
        emit(WorkoutLoaded(workoutOverviews: List.empty()));
      }
    } else {
      emit(WorkoutError());
    }
  }

  void _onDeleteWorkout(DeleteWorkout event, Emitter<WorkoutState> emit) async {
    emit(WorkoutLoading());

    //simulate backend request delay
    await Future.delayed(const Duration(seconds: 3));

    Response<dynamic> response;
    response = await _workoutService.putWorkoutArchiveStatus(userBox.get("flexusjwt"), event.workoutID);

    if (response.isSuccessful) {
      if (response.bodyString != "null") {
        final List<dynamic> jsonList = jsonDecode(response.bodyString);
        final List<WorkoutOverview> workoutOverviews = jsonList.map((json) {
          return WorkoutOverview(
            workout: Workout(
              id: json['workout']['id'],
              userAccountID: json['workout']['userAccountID'],
              splitID: json['workout']['splitID'],
              starttime: DateTime.parse(json['workout']['starttime']),
              endtime: json['workout']['endtime'] != null ? DateTime.parse(json['workout']['endtime']) : null,
              isArchived: json['workout']['isArchived'],
            ),
            planName: json['planName'],
            splitName: json['splitName'],
          );
        }).toList();

        emit(WorkoutLoaded(workoutOverviews: workoutOverviews));
      } else {
        emit(WorkoutLoaded(workoutOverviews: List.empty()));
      }
    } else {
      emit(WorkoutError());
    }
  }
}

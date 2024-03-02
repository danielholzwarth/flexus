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
    on<SearchWorkout>(_onSearchWorkout);
    on<UpdateWorkout>(_onPatchWorkout);
    on<DeleteWorkout>(_onDeleteWorkout);
  }

  void _onLoadWorkout(LoadWorkout event, Emitter<WorkoutState> emit) async {
    emit(WorkoutLoading());

    //simulate backend request delay
    // await Future.delayed(const Duration(seconds: 1));

    List<WorkoutOverview> workoutOverviews = List.empty();
    final response = await _workoutService.getWorkoutOverviews(userBox.get("flexusjwt"));

    if (response.isSuccessful) {
      if (response.bodyString != "null") {
        final List<dynamic> jsonList = jsonDecode(response.bodyString);
        workoutOverviews = jsonList.map((json) {
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
      }

      userBox.put("workoutOverviews", workoutOverviews);

      workoutOverviews = workoutOverviews.where((workoutOverview) => workoutOverview.workout.isArchived == false).toList();

      emit(WorkoutLoaded(workoutOverviews: workoutOverviews));
    } else {
      emit(WorkoutError());
    }
  }

  void _onSearchWorkout(SearchWorkout event, Emitter<WorkoutState> emit) async {
    emit(WorkoutSearching());

    //simulate backend request delay
    // await Future.delayed(const Duration(seconds: 1));

    List<WorkoutOverview> workoutOverviews = List.empty();
    List<WorkoutOverview> allWorkoutOvervies = userBox.get("workoutOverviews");

    if (allWorkoutOvervies.isNotEmpty) {
      if (event.keyWord.isNotEmpty) {
        workoutOverviews = allWorkoutOvervies
            .where((workoutOverview) =>
                workoutOverview.splitName != null && workoutOverview.splitName!.toLowerCase().contains(event.keyWord.toLowerCase()))
            .toList();
      } else {
        workoutOverviews = allWorkoutOvervies;
      }
    }
    workoutOverviews = workoutOverviews.where((workoutOverview) => workoutOverview.workout.isArchived == event.isArchive).toList();
    emit(WorkoutLoaded(workoutOverviews: workoutOverviews));
  }

  void _onPatchWorkout(UpdateWorkout event, Emitter<WorkoutState> emit) async {
    emit(WorkoutUpdating());

    //simulate backend request delay
    await Future.delayed(const Duration(seconds: 1));

    switch (event.name) {
      case "isArchived":
        bool isArchived = event.value;
        final response = await _workoutService.patchWorkout(
          userBox.get("flexusjwt"),
          event.workoutID,
          {"isArchived": isArchived},
        );
        List<WorkoutOverview> workoutOverviews = userBox.get("workoutOverviews");

        if (response.isSuccessful) {
          int index = workoutOverviews.indexWhere((workoutOverview) => workoutOverview.workout.id == event.workoutID);
          if (index != -1) {
            WorkoutOverview workoutOverview = workoutOverviews.elementAt(index);
            workoutOverview.workout.isArchived = event.value;
            workoutOverviews[index] = workoutOverview;

            userBox.put("workoutOverviews", workoutOverviews);
          }
        }

        workoutOverviews = workoutOverviews.where((workoutOverview) => workoutOverview.workout.isArchived == event.isArchive).toList();

        emit(WorkoutLoaded(workoutOverviews: workoutOverviews));
        break;

      default:
        emit(WorkoutError());
        break;
    }
  }

  void _onDeleteWorkout(DeleteWorkout event, Emitter<WorkoutState> emit) async {
    emit(WorkoutDeleting());

    //simulate backend request delay
    await Future.delayed(const Duration(seconds: 1));

    Response<dynamic> response;
    response = await _workoutService.deleteWorkout(userBox.get("flexusjwt"), event.workoutID);

    if (response.isSuccessful) {
      List<WorkoutOverview> workoutOverviews = userBox.get("workoutOverviews");

      workoutOverviews.removeWhere((overview) => overview.workout.id == event.workoutID);

      userBox.put("workoutOverviews", workoutOverviews);
      workoutOverviews = workoutOverviews.where((workoutOverview) => workoutOverview.workout.isArchived == event.isArchive).toList();
    } else {
      emit(WorkoutError());
    }
  }
}

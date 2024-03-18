import 'package:app/api/workout_service.dart';
import 'package:app/hive/workout.dart';
import 'package:app/hive/workout_overview.dart';
import 'package:app/resources/app_settings.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'workout_event.dart';
part 'workout_state.dart';

class WorkoutBloc extends Bloc<WorkoutEvent, WorkoutState> {
  final WorkoutService _workoutService = WorkoutService.create();
  final userBox = Hive.box('userBox');

  WorkoutBloc() : super(WorkoutInitial()) {
    on<GetWorkout>(_onGetWorkout);
    on<GetSearchWorkout>(_onGetSearchWorkout);
    on<PatchWorkout>(_onPatchWorkout);
    on<DeleteWorkout>(_onDeleteWorkout);
  }

  void _onGetWorkout(GetWorkout event, Emitter<WorkoutState> emit) async {
    emit(WorkoutLoading());

    List<WorkoutOverview> workoutOverviews = [];
    if (AppSettings.hasConnection) {
      final response = await _workoutService.getWorkoutOverviews(userBox.get("flexusjwt"));

      if (response.isSuccessful) {
        if (response.body != "null") {
          final List<dynamic> jsonList = response.body;
          workoutOverviews = jsonList.map((json) {
            return WorkoutOverview(
              workout: Workout(
                id: json['workout']['id'],
                userAccountID: json['workout']['userAccountID'],
                splitID: json['workout']['splitID'],
                starttime: DateTime.parse(json['workout']['starttime']),
                endtime: json['workout']['endtime'] != null ? DateTime.parse(json['workout']['endtime']) : null,
                isArchived: json['workout']['isArchived'],
                isStared: json['workout']['isStared'],
                isPinned: json['workout']['isPinned'],
              ),
              planName: json['planName'],
              splitName: json['splitName'],
            );
          }).toList();
        }

        userBox.put("workoutOverviews", workoutOverviews);

        workoutOverviews = workoutOverviews.where((workoutOverview) => workoutOverview.workout.isArchived == event.isArchive).toList();

        emit(WorkoutLoaded(workoutOverviews: workoutOverviews));
      } else {
        emit(WorkoutError(error: response.error.toString()));
      }
    } else {
      workoutOverviews = userBox.get("workoutOverviews").cast<WorkoutOverview>() ?? [];
      workoutOverviews = workoutOverviews.where((workoutOverview) => workoutOverview.workout.isArchived == event.isArchive).toList();
      emit(WorkoutLoaded(workoutOverviews: workoutOverviews));
    }
  }

  void _onGetSearchWorkout(GetSearchWorkout event, Emitter<WorkoutState> emit) async {
    emit(WorkoutSearching());

    List<WorkoutOverview> workoutOverviews = [];
    List<WorkoutOverview> allWorkoutOvervies = userBox.get("workoutOverviews") ?? [];

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

  void _onPatchWorkout(PatchWorkout event, Emitter<WorkoutState> emit) async {
    switch (event.name) {
      case "isArchived":
        bool isArchived = event.value;
        List<WorkoutOverview> workoutOverviews = userBox.get("workoutOverviews").cast<WorkoutOverview>() ?? [];

        if (AppSettings.hasConnection) {
          final response = await _workoutService.patchWorkout(userBox.get("flexusjwt"), event.workoutID, {"isArchived": isArchived});

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
        } else {
          int index = workoutOverviews.indexWhere((workoutOverview) => workoutOverview.workout.id == event.workoutID);
          if (index != -1) {
            WorkoutOverview workoutOverview = workoutOverviews.elementAt(index);
            workoutOverview.workout.isArchived = event.value;
            workoutOverviews[index] = workoutOverview;

            userBox.put("workoutOverviews", workoutOverviews);
          }

          workoutOverviews = workoutOverviews.where((workoutOverview) => workoutOverview.workout.isArchived == event.isArchive).toList();
        }

        emit(WorkoutLoaded(workoutOverviews: workoutOverviews));
        break;

      case "isStared":
        bool isStared = event.value;
        List<WorkoutOverview> workoutOverviews = userBox.get("workoutOverviews").cast<WorkoutOverview>() ?? [];

        if (AppSettings.hasConnection) {
          final response = await _workoutService.patchWorkout(userBox.get("flexusjwt"), event.workoutID, {"isStared": isStared});

          if (response.isSuccessful) {
            int index = workoutOverviews.indexWhere((workoutOverview) => workoutOverview.workout.id == event.workoutID);
            if (index != -1) {
              WorkoutOverview workoutOverview = workoutOverviews.elementAt(index);
              workoutOverview.workout.isStared = event.value;
              workoutOverviews[index] = workoutOverview;

              userBox.put("workoutOverviews", workoutOverviews);
            }
          }

          workoutOverviews = workoutOverviews.where((workoutOverview) => workoutOverview.workout.isArchived == event.isArchive).toList();
        } else {
          int index = workoutOverviews.indexWhere((workoutOverview) => workoutOverview.workout.id == event.workoutID);
          if (index != -1) {
            WorkoutOverview workoutOverview = workoutOverviews.elementAt(index);
            workoutOverview.workout.isStared = event.value;
            workoutOverviews[index] = workoutOverview;

            userBox.put("workoutOverviews", workoutOverviews);
          }

          workoutOverviews = workoutOverviews.where((workoutOverview) => workoutOverview.workout.isArchived == event.isArchive).toList();
        }
        emit(WorkoutLoaded(workoutOverviews: workoutOverviews));
        break;

      case "isPinned":
        bool isPinned = event.value;
        List<WorkoutOverview> workoutOverviews = userBox.get("workoutOverviews").cast<WorkoutOverview>() ?? [];

        if (AppSettings.hasConnection) {
          final response = await _workoutService.patchWorkout(userBox.get("flexusjwt"), event.workoutID, {"isPinned": isPinned});

          if (response.isSuccessful) {
            int index = workoutOverviews.indexWhere((workoutOverview) => workoutOverview.workout.id == event.workoutID);
            if (index != -1) {
              WorkoutOverview workoutOverview = workoutOverviews.elementAt(index);
              workoutOverview.workout.isPinned = event.value;
              workoutOverviews[index] = workoutOverview;

              userBox.put("workoutOverviews", workoutOverviews);
            }
          }

          workoutOverviews.sort((a, b) {
            if (a.workout.isPinned && !b.workout.isPinned) {
              return -1;
            } else if (!a.workout.isPinned && b.workout.isPinned) {
              return 1;
            } else {
              return b.workout.starttime.compareTo(a.workout.starttime);
            }
          });

          workoutOverviews = workoutOverviews.where((workoutOverview) => workoutOverview.workout.isArchived == event.isArchive).toList();
        } else {
          int index = workoutOverviews.indexWhere((workoutOverview) => workoutOverview.workout.id == event.workoutID);
          if (index != -1) {
            WorkoutOverview workoutOverview = workoutOverviews.elementAt(index);
            workoutOverview.workout.isPinned = event.value;
            workoutOverviews[index] = workoutOverview;

            userBox.put("workoutOverviews", workoutOverviews);
          }

          workoutOverviews.sort((a, b) {
            if (a.workout.isPinned && !b.workout.isPinned) {
              return -1;
            } else if (!a.workout.isPinned && b.workout.isPinned) {
              return 1;
            } else {
              return b.workout.starttime.compareTo(a.workout.starttime);
            }
          });

          workoutOverviews = workoutOverviews.where((workoutOverview) => workoutOverview.workout.isArchived == event.isArchive).toList();
        }

        emit(WorkoutLoaded(workoutOverviews: workoutOverviews));
        break;

      default:
        emit(WorkoutError(error: "Patch not implemented yet"));
        break;
    }
  }

  void _onDeleteWorkout(DeleteWorkout event, Emitter<WorkoutState> emit) async {
    emit(WorkoutDeleting());

    if (AppSettings.hasConnection) {
      final response = await _workoutService.deleteWorkout(userBox.get("flexusjwt"), event.workoutID);

      if (response.isSuccessful) {
        List<WorkoutOverview> workoutOverviews = userBox.get("workoutOverviews");

        workoutOverviews.removeWhere((overview) => overview.workout.id == event.workoutID);

        userBox.put("workoutOverviews", workoutOverviews);
        workoutOverviews = workoutOverviews.where((workoutOverview) => workoutOverview.workout.isArchived == event.isArchive).toList();

        emit(WorkoutLoaded(workoutOverviews: workoutOverviews));
      } else {
        emit(WorkoutError(error: response.error.toString()));
      }
    } else {
      List<WorkoutOverview> workoutOverviews = userBox.get("workoutOverviews").cast<WorkoutOverview>() ?? [];

      workoutOverviews.removeWhere((overview) => overview.workout.id == event.workoutID);

      userBox.put("workoutOverviews", workoutOverviews);
      workoutOverviews = workoutOverviews.where((workoutOverview) => workoutOverview.workout.isArchived == event.isArchive).toList();

      emit(WorkoutLoaded(workoutOverviews: workoutOverviews));
    }
  }
}

import 'package:app/api/workout/workout_service.dart';
import 'package:app/hive/workout/current_workout.dart';
import 'package:app/hive/workout/workout.dart';
import 'package:app/hive/workout/workout_details.dart';
import 'package:app/hive/workout/workout_overview.dart';
import 'package:app/resources/app_settings.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

part 'workout_event.dart';
part 'workout_state.dart';

class WorkoutBloc extends Bloc<WorkoutEvent, WorkoutState> {
  final WorkoutService _workoutService = WorkoutService.create();
  final userBox = Hive.box('userBox');

  WorkoutBloc() : super(WorkoutInitial()) {
    on<PostWorkout>(_onPostWorkout);
    on<GetWorkoutFromID>(_onGetWorkoutFromID);
    on<GetWorkouts>(_onGetWorkouts);
    on<GetSearchWorkout>(_onGetSearchWorkout);
    on<GetWorkoutDetails>(_onGetWorkoutDetails);
    on<PatchWorkout>(_onPatchWorkout);
    on<DeleteWorkout>(_onDeleteWorkout);
  }

  void _onPostWorkout(PostWorkout event, Emitter<WorkoutState> emit) async {
    emit(WorkoutCreating());

    if (!AppSettings.hasConnection) {
      emit(WorkoutError(error: "No internet connection!"));
      return;
    }

    final DateFormat formatter = DateFormat('yyyy-MM-ddTHH:mm:ss');
    final String formattedStartTime = "${formatter.format(event.startTime.subtract(AppSettings.timeZoneOffset))}Z";

    final response = await _workoutService.postWorkout(userBox.get("flexusjwt"), {
      "gymID": event.gymID,
      "splitID": event.splitID,
      "starttime": formattedStartTime,
      "isActive": event.isActive,
    });

    if (!response.isSuccessful) {
      emit(WorkoutError(error: response.error.toString()));
      return;
    }

    emit(WorkoutCreated());
  }

  void _onGetWorkoutFromID(GetWorkoutFromID event, Emitter<WorkoutState> emit) async {
    emit(WorkoutsLoading());

    if (!AppSettings.hasConnection) {
      emit(WorkoutError(error: "No internet connection!"));
      return;
    }

    final response = await _workoutService.getWorkoutOverviews(userBox.get("flexusjwt"));

    if (!response.isSuccessful) {
      emit(WorkoutError(error: response.error.toString()));
      return;
    }

    Workout? workout;
    if (response.body != "null") {
      workout = Workout.fromJson(response.body);
    }

    emit(WorkoutLoaded(workout: workout));
  }

  void _onGetWorkouts(GetWorkouts event, Emitter<WorkoutState> emit) async {
    emit(WorkoutsLoading());

    List<WorkoutOverview> workoutOverviews = userBox.get("workoutOverviews")?.cast<WorkoutOverview>() ?? [];

    if (!AppSettings.hasConnection) {
      workoutOverviews = workoutOverviews.where((workoutOverview) => workoutOverview.workout.isArchived == event.isArchive).toList();
      emit(WorkoutsLoaded(workoutOverviews: workoutOverviews));
      return;
    }

    final response = await _workoutService.getWorkoutOverviews(userBox.get("flexusjwt"));

    if (!response.isSuccessful) {
      emit(WorkoutError(error: response.error.toString()));
      return;
    }

    if (response.body != "null") {
      workoutOverviews = List<WorkoutOverview>.from(response.body.map((json) {
        return WorkoutOverview.fromJson(json);
      }));
    }

    userBox.put("workoutOverviews", workoutOverviews);

    workoutOverviews = workoutOverviews.where((workoutOverview) => workoutOverview.workout.isArchived == event.isArchive).toList();

    emit(WorkoutsLoaded(workoutOverviews: workoutOverviews));
  }

  void _onGetSearchWorkout(GetSearchWorkout event, Emitter<WorkoutState> emit) async {
    emit(WorkoutSearching());

    List<WorkoutOverview> workoutOverviews = userBox.get("workoutOverviews")?.cast<WorkoutOverview>() ?? [];

    if (!AppSettings.hasConnection) {
      workoutOverviews = workoutOverviews.where((workoutOverview) => workoutOverview.workout.isArchived == event.isArchive).toList();
      emit(WorkoutsLoaded(workoutOverviews: workoutOverviews));
      return;
    }

    if (workoutOverviews.isNotEmpty && event.keyWord.isNotEmpty) {
      workoutOverviews = workoutOverviews
          .where((workoutOverview) =>
              workoutOverview.splitName != null && workoutOverview.splitName!.toLowerCase().contains(event.keyWord.toLowerCase()))
          .toList();
    }

    workoutOverviews = workoutOverviews.where((workoutOverview) => workoutOverview.workout.isArchived == event.isArchive).toList();
    emit(WorkoutsLoaded(workoutOverviews: workoutOverviews));
  }

  void _onGetWorkoutDetails(GetWorkoutDetails event, Emitter<WorkoutState> emit) async {
    emit(WorkoutDetailsLoading());

    WorkoutDetails? workoutDetails;

    if (!AppSettings.hasConnection) {
      workoutDetails = userBox.get("workoutDetails${event.workoutID}");
      workoutDetails != null ? emit(WorkoutDetailsLoaded(workoutDetails: workoutDetails)) : emit(WorkoutError(error: "No workout details found"));
      return;
    }

    final response = await _workoutService.getWorkoutDetailsFromWorkoutID(userBox.get("flexusjwt"), event.workoutID);

    if (!response.isSuccessful) {
      emit(WorkoutError(error: response.error.toString()));
      return;
    }

    if (response.body == "null") {
      emit(WorkoutError(error: "No workout details found"));
      return;
    }

    workoutDetails = WorkoutDetails.fromJson(response.body);
    userBox.put("workoutDetails${event.workoutID}", workoutDetails);
    emit(WorkoutDetailsLoaded(workoutDetails: workoutDetails));
  }

  void _onPatchWorkout(PatchWorkout event, Emitter<WorkoutState> emit) async {
    emit(WorkoutUpdating());

    switch (event.name) {
      case "isArchived":
        bool isArchived = event.value;
        List<WorkoutOverview> workoutOverviews = userBox.get("workoutOverviews") ?? [];
        workoutOverviews = workoutOverviews.cast<WorkoutOverview>();

        if (AppSettings.hasConnection) {
          final response = await _workoutService.patchWorkout(userBox.get("flexusjwt"), event.workoutID, {"isArchived": isArchived});

          if (response.isSuccessful) {
            workoutOverviews = archiveWorkout(event, workoutOverviews);
          }
        } else {
          workoutOverviews = archiveWorkout(event, workoutOverviews);
        }
        workoutOverviews = workoutOverviews.where((workoutOverview) => workoutOverview.workout.isArchived == event.isArchive).toList();

        emit(WorkoutsLoaded(workoutOverviews: workoutOverviews));
        break;

      case "isStared":
        bool isStared = event.value;
        List<WorkoutOverview> workoutOverviews = userBox.get("workoutOverviews") ?? [];
        workoutOverviews = workoutOverviews.cast<WorkoutOverview>();

        if (AppSettings.hasConnection) {
          final response = await _workoutService.patchWorkout(userBox.get("flexusjwt"), event.workoutID, {"isStared": isStared});

          if (response.isSuccessful) {
            workoutOverviews = starWorkout(event, workoutOverviews);
          }
        } else {
          workoutOverviews = starWorkout(event, workoutOverviews);
        }
        workoutOverviews = workoutOverviews.where((workoutOverview) => workoutOverview.workout.isArchived == event.isArchive).toList();

        emit(WorkoutsLoaded(workoutOverviews: workoutOverviews));
        break;

      case "isPinned":
        bool isPinned = event.value;
        List<WorkoutOverview> workoutOverviews = userBox.get("workoutOverviews") ?? [];
        workoutOverviews = workoutOverviews.cast<WorkoutOverview>();

        if (AppSettings.hasConnection) {
          final response = await _workoutService.patchWorkout(userBox.get("flexusjwt"), event.workoutID, {"isPinned": isPinned});

          if (response.isSuccessful) {
            workoutOverviews = pinWorkout(event, workoutOverviews);
          }
        } else {
          workoutOverviews = pinWorkout(event, workoutOverviews);
        }
        workoutOverviews = workoutOverviews.where((workoutOverview) => workoutOverview.workout.isArchived == event.isArchive).toList();

        emit(WorkoutsLoaded(workoutOverviews: workoutOverviews));
        break;

      case "startWorkout":
        final response = await _workoutService.patchStartWorkout(userBox.get("flexusjwt"), event.workoutID, {
          "gymID": event.gymID,
          "splitID": event.splitID,
        });

        if (response.isSuccessful) {
          emit(WorkoutsLoaded(workoutOverviews: const []));
        } else {
          emit(WorkoutError(error: response.error.toString()));
        }
        break;

      case "finishWorkout":
        List<Map<String, dynamic>> exercises = [];
        for (final ex in event.currentWorkout!.exercises) {
          exercises.add(ex.toJson());
        }

        final response = await _workoutService.patchFinishWorkout(
          userBox.get("flexusjwt"),
          {
            "workoutID": event.currentWorkout?.plan?.id,
            "splitID": event.currentWorkout?.split?.id,
            "gymID": event.currentWorkout?.gym?.id,
            "exercises": exercises,
          },
        );

        if (response.isSuccessful) {
          emit(WorkoutsLoaded(workoutOverviews: const []));
        } else {
          emit(WorkoutError(error: response.error.toString()));
        }
        break;

      default:
        emit(WorkoutError(error: "Patch not implemented yet"));
        break;
    }
  }

  void _onDeleteWorkout(DeleteWorkout event, Emitter<WorkoutState> emit) async {
    emit(WorkoutDeleting());

    List<WorkoutOverview> workoutOverviews = userBox.get("workoutOverviews") ?? [];
    workoutOverviews = workoutOverviews.cast<WorkoutOverview>();

    if (!AppSettings.hasConnection) {
      WorkoutOverview workoutOverview = workoutOverviews.firstWhere((overview) => overview.workout.id == event.workoutID);
      if (workoutOverview.workout.endtime == null) {
        userBox.delete("currentWorkout");
      }

      workoutOverviews.remove(workoutOverview);

      userBox.put("workoutOverviews", workoutOverviews);
      workoutOverviews = workoutOverviews.where((workoutOverview) => workoutOverview.workout.isArchived == event.isArchive).toList();

      emit(WorkoutsLoaded(workoutOverviews: workoutOverviews));
      return;
    }

    final response = await _workoutService.deleteWorkout(userBox.get("flexusjwt"), event.workoutID);

    if (!response.isSuccessful) {
      emit(WorkoutError(error: response.error.toString()));
      return;
    }

    WorkoutOverview workoutOverview = workoutOverviews.firstWhere((overview) => overview.workout.id == event.workoutID);
    if (workoutOverview.workout.endtime == null) {
      userBox.delete("currentWorkout");
    }

    workoutOverviews.remove(workoutOverview);

    userBox.put("workoutOverviews", workoutOverviews);
    workoutOverviews = workoutOverviews.where((workoutOverview) => workoutOverview.workout.isArchived == event.isArchive).toList();

    emit(WorkoutsLoaded(workoutOverviews: workoutOverviews));
  }

  List<WorkoutOverview> archiveWorkout(PatchWorkout event, List<WorkoutOverview> workoutOverviews) {
    int index = workoutOverviews.indexWhere((workoutOverview) => workoutOverview.workout.id == event.workoutID);
    if (index != -1) {
      WorkoutOverview workoutOverview = workoutOverviews.elementAt(index);
      workoutOverview.workout.isArchived = event.value;
      workoutOverviews[index] = workoutOverview;

      userBox.put("workoutOverviews", workoutOverviews);
    }
    return workoutOverviews;
  }

  List<WorkoutOverview> starWorkout(PatchWorkout event, List<WorkoutOverview> workoutOverviews) {
    int index = workoutOverviews.indexWhere((workoutOverview) => workoutOverview.workout.id == event.workoutID);
    if (index != -1) {
      WorkoutOverview workoutOverview = workoutOverviews.elementAt(index);
      workoutOverview.workout.isStared = event.value;
      workoutOverviews[index] = workoutOverview;

      userBox.put("workoutOverviews", workoutOverviews);
    }
    return workoutOverviews;
  }

  List<WorkoutOverview> pinWorkout(PatchWorkout event, List<WorkoutOverview> workoutOverviews) {
    int index = workoutOverviews.indexWhere((workoutOverview) => workoutOverview.workout.id == event.workoutID);
    if (index != -1) {
      WorkoutOverview workoutOverview = workoutOverviews.elementAt(index);
      workoutOverview.workout.isPinned = event.value;
      workoutOverviews[index] = workoutOverview;

      userBox.put("workoutOverviews", workoutOverviews);
    }

    workoutOverviews.sort((a, b) {
      if (a.workout.isActive != b.workout.isActive) {
        return b.workout.isActive ? 1 : -1;
      } else if (a.workout.endtime != null && b.workout.endtime == null) {
        return 1;
      } else if (a.workout.endtime == null && b.workout.endtime != null) {
        return -1;
      } else if (a.workout.isPinned && !b.workout.isPinned) {
        return -1;
      } else if (!a.workout.isPinned && b.workout.isPinned) {
        return 1;
      } else {
        return b.workout.starttime.compareTo(a.workout.starttime);
      }
    });

    return workoutOverviews;
  }
}

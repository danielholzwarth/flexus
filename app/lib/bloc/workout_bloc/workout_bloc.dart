import 'package:app/api/workout/workout_service.dart';
import 'package:app/hive/exercise/exercise.dart';
import 'package:app/hive/gym/gym.dart';
import 'package:app/hive/set/workout_set.dart';
import 'package:app/hive/split/split.dart';
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
      final Map<String, dynamic> json = response.body;
      workout = Workout(
        id: json['id'],
        userAccountID: json['workout']['userAccountID'],
        splitID: json['workout']['splitID'],
        createdAt: DateTime.parse(json['workout']['createdAt']).add(AppSettings.timeZoneOffset),
        starttime: DateTime.parse(json['workout']['starttime']).add(AppSettings.timeZoneOffset),
        endtime: json['workout']['endtime'] != null ? DateTime.parse(json['workout']['endtime']).add(AppSettings.timeZoneOffset) : null,
        isActive: json['workout']['isActive'],
        isArchived: json['workout']['isArchived'],
        isStared: json['workout']['isStared'],
        isPinned: json['workout']['isPinned'],
      );
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
      final List<dynamic> jsonList = response.body;
      workoutOverviews = jsonList.map((json) {
        return WorkoutOverview(
          workout: Workout(
            id: json['workout']['id'],
            userAccountID: json['workout']['userAccountID'],
            splitID: json['workout']['splitID'],
            createdAt: DateTime.parse(json['workout']['createdAt']).add(AppSettings.timeZoneOffset),
            starttime: DateTime.parse(json['workout']['starttime']).add(AppSettings.timeZoneOffset),
            endtime: json['workout']['endtime'] != null ? DateTime.parse(json['workout']['endtime']).add(AppSettings.timeZoneOffset) : null,
            isActive: json['workout']['isActive'],
            isArchived: json['workout']['isArchived'],
            isStared: json['workout']['isStared'],
            isPinned: json['workout']['isPinned'],
          ),
          planName: json['planName'],
          splitName: json['splitName'],
          bestLiftCount: json['pbCount'],
        );
      }).toList();
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

    WorkoutDetails? workoutDetails = userBox.get("workoutDetails${event.workoutID}");

    if (!AppSettings.hasConnection) {
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

    Map<String, dynamic> json = response.body;

    Gym? gym;

    if (json['gym'] != null) {
      Map<String, dynamic> gymJson = json['gym'];
      gym = Gym(
        id: gymJson['id'],
        name: gymJson['name'],
        streetName: gymJson['streetName'],
        houseNumber: gymJson['houseNumber'],
        zipCode: gymJson['zipCode'],
        cityName: gymJson['cityName'],
        latitude: gymJson['latitude'],
        longitude: gymJson['longitude'],
      );
    }

    List<Exercise> exercises = [];

    if (json['exercises'] != null) {
      List<dynamic> exercisesJson = json['exercises'];
      exercises = exercisesJson.map((exerciseJson) {
        return Exercise(
          id: exerciseJson['id'],
          name: exerciseJson['name'],
          creatorID: exerciseJson['creatorID'],
          typeID: exerciseJson['typeID'],
        );
      }).toList();
    }

    List<List<WorkoutSet>> sets = [];
    if (json['sets'] != null) {
      List<dynamic> measurementsJson = json['sets'];
      sets = measurementsJson.map<List<WorkoutSet>>((measurementListJson) {
        return List<Map<String, dynamic>>.from(measurementListJson).map((measurementMap) {
          return WorkoutSet(
            id: measurementMap['id'],
            workoutID: measurementMap['workoutID'],
            exerciseID: measurementMap['exerciseID'],
            orderNumber: measurementMap['orderNumber'],
            repetitions: measurementMap['repetitions'],
            workload: double.parse(measurementMap['workload'].toString()),
          );
        }).toList();
      }).toList();
    }

    List<int> pbSetIDs = [];
    if (json['pbSetIDs'] != null) {
      pbSetIDs = List<int>.from(json['pbSetIDs']);
    }

    workoutDetails = WorkoutDetails(
      workoutID: json['workoutID'],
      startTime: DateTime.parse(json['starttime']),
      endtime: json['endtime'] != null ? DateTime.parse(json['endtime']) : null,
      gym: gym,
      split: json['split'] != null
          ? Split(
              id: json['split']['id'],
              planID: json['split']['planID'],
              name: json['split']['name'],
              orderInPlan: json['split']['orderInPlan'],
            )
          : null,
      exercises: exercises,
      sets: sets,
      pbSetIDs: pbSetIDs,
    );

    userBox.put("workoutDetails${event.workoutID}", workoutDetails);

    emit(WorkoutDetailsLoaded(workoutDetails: workoutDetails));
  }

  void _onPatchWorkout(PatchWorkout event, Emitter<WorkoutState> emit) async {
    emit(WorkoutUpdating());

    if (!AppSettings.hasConnection) {
      emit(WorkoutError(error: "No workout details found"));
      return;
    }

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

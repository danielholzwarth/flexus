import 'package:app/api/exercise/exercise_service.dart';
import 'package:app/hive/exercise/current_exercise.dart';
import 'package:app/hive/exercise/exercise.dart';
import 'package:app/hive/plan/current_plan.dart';
import 'package:app/hive/split/split_overview.dart';
import 'package:app/resources/app_settings.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

part 'exercise_event.dart';
part 'exercise_state.dart';

class ExerciseBloc extends Bloc<ExerciseEvent, ExerciseState> {
  final ExerciseService exerciseService = ExerciseService.create();
  final userBox = Hive.box('userBox');

  ExerciseBloc() : super(ExerciseInitial()) {
    on<PostExercise>(_onPostExercise);
    on<GetExercises>(_onGetExercises);
    on<GetCurrentExerciseFromExerciseID>(_onGetCurrentExerciseFromExerciseID);
    on<GetCurrentExercisesFromSplitID>(_onGetCurrentExercisesFromSplitID);
    on<RefreshGetExercisesState>(_onRefreshGetExercisesState);
    on<RefreshGetCurrentExercisesState>(_onRefreshGetCurrentExercisesState);
  }

  void _onPostExercise(PostExercise event, Emitter<ExerciseState> emit) async {
    List<Exercise> exercises = [];

    if (!AppSettings.hasConnection) {
      emit(ExerciseError(error: "Internet Connection required!"));
      return;
    }

    final response = await exerciseService.postExercise(userBox.get("flexusjwt"), {
      "name": event.name,
      "typeID": event.isRepetition ? 1 : 2,
    });

    if (!response.isSuccessful) {
      userBox.get("exercises")?.cast<Exercise>() ?? [];
      emit(ExerciseError(error: response.error.toString()));
      emit(ExercisesLoaded(exercises: exercises));
      return;
    }

    if (response.body != null) {
      Exercise newExercise = Exercise.fromJson(response.body);
      exercises.add(newExercise);

      userBox.put("exercises", exercises);
      userBox.put("createdExercise", newExercise);

      emit(ExerciseCreated());
    }

    emit(ExercisesLoaded(exercises: exercises));
  }

  void _onGetExercises(GetExercises event, Emitter<ExerciseState> emit) async {
    List<Exercise> exercises = [];

    if (!AppSettings.hasConnection) {
      exercises = userBox.get("exercises")?.cast<Exercise>() ?? [];

      exercises.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

      emit(ExercisesLoaded(exercises: exercises));
      return;
    }

    final response = await exerciseService.getExercises(userBox.get("flexusjwt"));

    if (!response.isSuccessful) {
      userBox.get("exercises")?.cast<Exercise>() ?? [];
      emit(ExerciseError(error: response.error.toString()));
      emit(ExercisesLoaded(exercises: exercises));
      return;
    }

    if (response.body != "null") {
      exercises = List<Exercise>.from(response.body.map((json) {
        return Exercise.fromJson(json);
      }));

      userBox.put("exercises", exercises);
    }

    emit(ExercisesLoaded(exercises: exercises));
  }

  void _onGetCurrentExerciseFromExerciseID(GetCurrentExerciseFromExerciseID event, Emitter<ExerciseState> emit) async {
    CurrentExercise? currentExercise;

    if (!AppSettings.hasConnection) {
      List<Exercise> exercises = userBox.get("exercises")?.cast<Exercise>() ?? [];

      if (exercises.isNotEmpty) {
        Exercise? ex = exercises.firstWhereOrNull((element) => element.id == event.exerciseID);
        if (ex != null) {
          currentExercise = CurrentExercise(exercise: ex, oldMeasurements: [], measurements: []);
        }
      }

      emit(CurrentExerciseFromExerciseIDLoaded(currentExercise: currentExercise));
      return;
    }

    final response = await exerciseService.getExerciseFromExerciseID(userBox.get("flexusjwt"), event.exerciseID);

    if (!response.isSuccessful) {
      emit(ExerciseError(error: response.error.toString()));
      return;
    }

    if (response.body != null) {
      currentExercise = CurrentExercise.fromJson(response.body);
    }

    emit(CurrentExerciseFromExerciseIDLoaded(currentExercise: currentExercise));
  }

  void _onGetCurrentExercisesFromSplitID(GetCurrentExercisesFromSplitID event, Emitter<ExerciseState> emit) async {
    List<CurrentExercise> currentExercises = [];

    if (!AppSettings.hasConnection) {
      List<SplitOverview> splitOverviews = userBox.get("splitOverviews${event.currentPlan.plan.id}")?.cast<SplitOverview>() ?? [];

      SplitOverview? splitOverview = splitOverviews.firstWhereOrNull((element) => element.split.id == event.splitID);
      if (splitOverview != null) {
        List<Exercise> exercises = splitOverview.exercises;
        for (var ex in exercises) {
          currentExercises.add(CurrentExercise(exercise: ex, oldMeasurements: [], measurements: []));
        }
      }

      emit(CurrentExercisesFromSplitIDLoaded(currentExercises: currentExercises));
      return;
    }

    final response = await exerciseService.getExercisesFromSplitID(userBox.get("flexusjwt"), event.splitID);

    if (!response.isSuccessful) {
      emit(ExerciseError(error: response.error.toString()));
      return;
    }

    if (response.body != "null") {
      final List<dynamic> jsonList = response.body;
      currentExercises = List<CurrentExercise>.from(jsonList.map((json) {
        return CurrentExercise.fromJson(json);
      }));
    }

    emit(CurrentExercisesFromSplitIDLoaded(currentExercises: currentExercises));
  }

  void _onRefreshGetExercisesState(RefreshGetExercisesState event, Emitter<ExerciseState> emit) async {
    emit(ExercisesLoaded(exercises: event.exercises));
  }

  void _onRefreshGetCurrentExercisesState(RefreshGetCurrentExercisesState event, Emitter<ExerciseState> emit) async {
    emit(CurrentExercisesLoaded(currentExercises: event.currentExercises));
  }
}

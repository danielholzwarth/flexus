import 'package:app/api/exercise/exercise_service.dart';
import 'package:app/hive/exercise/exercise.dart';
import 'package:app/resources/app_settings.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'exercise_event.dart';
part 'exercise_state.dart';

class ExerciseBloc extends Bloc<ExerciseEvent, ExerciseState> {
  final ExerciseService exerciseService = ExerciseService.create();
  final userBox = Hive.box('userBox');

  ExerciseBloc() : super(ExerciseInitial()) {
    on<PostExercise>(_onPostExercise);
    on<GetExercises>(_onGetExercises);
    on<GetExercisesFromSplitID>(_onGetExercisesFromSplitID);
    on<RefreshGetExercisesState>(_onRefreshGetExercisesState);
  }

  void _onPostExercise(PostExercise event, Emitter<ExerciseState> emit) async {
    emit(ExerciseCreating());

    final response = await exerciseService.postExercise(userBox.get("flexusjwt"), {
      "name": event.name,
      "typeID": event.isRepetition ? 1 : 2,
    });

    if (response.isSuccessful) {
      emit(ExerciseCreated());
    } else {
      emit(ExerciseError(error: response.error.toString()));
    }
  }

  void _onGetExercises(GetExercises event, Emitter<ExerciseState> emit) async {
    emit(ExercisesLoading());

    List<Exercise> exercises = [];

    if (AppSettings.hasConnection) {
      final response = await exerciseService.getExercises(userBox.get("flexusjwt"));

      if (response.isSuccessful) {
        if (response.body != "null") {
          final List<dynamic> jsonList = response.body;
          exercises = jsonList.map((json) {
            return Exercise(
              id: json['id'],
              creatorID: json['creatorID'],
              name: json['name'],
              typeID: json['typeID'],
            );
          }).toList();

          emit(ExercisesLoaded(exercises: exercises));
        } else {
          emit(ExercisesLoaded(exercises: exercises));
        }
      } else {
        emit(ExerciseError(error: response.error.toString()));
      }
    } else {
      emit(ExercisesLoaded(exercises: exercises));
    }
  }

  void _onGetExercisesFromSplitID(GetExercisesFromSplitID event, Emitter<ExerciseState> emit) async {
    emit(ExercisesLoading());

    List<Exercise> exercises = [];

    if (AppSettings.hasConnection) {
      final response = await exerciseService.getExercisesFromSplitID(userBox.get("flexusjwt"), event.splitID);

      print(response.bodyString);

      if (response.isSuccessful) {
        if (response.body != "null") {
          final List<dynamic> jsonList = response.body;
          exercises = jsonList.map((json) {
            return Exercise(
              id: json['id'],
              creatorID: json['creatorID'],
              name: json['name'],
              typeID: json['typeID'],
            );
          }).toList();

          emit(ExercisesFromSplitIDLoaded(exercises: exercises));
        } else {
          emit(ExercisesFromSplitIDLoaded(exercises: exercises));
        }
      } else {
        emit(ExerciseError(error: response.error.toString()));
      }
    } else {
      emit(ExercisesLoaded(exercises: exercises));
    }
  }

  void _onRefreshGetExercisesState(RefreshGetExercisesState event, Emitter<ExerciseState> emit) async {
    emit(ExercisesLoaded(exercises: event.exercises));
  }
}

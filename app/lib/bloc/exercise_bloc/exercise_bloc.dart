import 'package:app/api/exercise/exercise_service.dart';
import 'package:app/hive/exercise.dart';
import 'package:app/resources/app_settings.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'exercise_event.dart';
part 'exercise_state.dart';

class ExerciseBloc extends Bloc<ExerciseEvent, ExerciseState> {
  final ExerciseService _friendshipService = ExerciseService.create();
  final userBox = Hive.box('userBox');

  ExerciseBloc() : super(ExerciseInitial()) {
    // on<PostExercise>(_onPostExercise);
    on<GetExercises>(_onGetExercises);
    on<RefreshGetExercisesState>(_onRefreshGetExercisesState);
  }

  // void _onPostExercise(PostExercise event, Emitter<ExerciseState> emit) async {
  //   Response<dynamic> response;
  //   response = await _friendshipService.postFriendship(userBox.get("flexusjwt"));

  //   if (response.isSuccessful) {

  //     emit(ExerciseCreated());
  //   } else {
  //     emit(ExerciseError(error: response.error.toString()));
  //   }
  // }

  void _onGetExercises(GetExercises event, Emitter<ExerciseState> emit) async {
    emit(ExercisesLoading());

    List<Exercise> exercises = [];

    if (AppSettings.hasConnection) {
      final response = await _friendshipService.getExercises(userBox.get("flexusjwt"));

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

  void _onRefreshGetExercisesState(RefreshGetExercisesState event, Emitter<ExerciseState> emit) async {
    emit(ExercisesLoaded(exercises: event.exercises));
  }
}

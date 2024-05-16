import 'package:app/api/statistic/statistic_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'statistic_event.dart';
part 'statistic_state.dart';

class StatisticBloc extends Bloc<StatisticEvent, StatisticState> {
  final StatisticService _bestLiftsService = StatisticService.create();
  final userBox = Hive.box('userBox');

  StatisticBloc() : super(StatisticInitial()) {
    on<GetStatistic>(_onGetStatistic);
  }

  void _onGetStatistic(GetStatistic event, Emitter<StatisticState> emit) async {
    emit(StatisticLoading());

    switch (event.title) {
      case "Total Moved Weight":
        final response = await _bestLiftsService.getTotalMovedWeight(userBox.get("flexusjwt"), event.period);
        if (response.isSuccessful) {
          if (response.body != "null" && response.body.isNotEmpty) {
            emit(StatisticLoaded());
          } else {
            emit(StatisticError(error: response.error.toString()));
          }
        }
        break;

      case "Total Reps":
        final response = await _bestLiftsService.getTotalReps(userBox.get("flexusjwt"), event.period);
        if (response.isSuccessful) {
          if (response.body != "null" && response.body.isNotEmpty) {
            emit(StatisticLoaded());
          } else {
            emit(StatisticError(error: response.error.toString()));
          }
        }
        break;

      case "Workout Days":
        final response = await _bestLiftsService.getWorkoutDays(userBox.get("flexusjwt"), event.period);
        if (response.isSuccessful) {
          if (response.body != "null" && response.body.isNotEmpty) {
            emit(StatisticLoaded());
          } else {
            emit(StatisticError(error: response.error.toString()));
          }
        }
        break;

      case "Workout Duration":
        final response = await _bestLiftsService.getWorkoutDuration(userBox.get("flexusjwt"), event.period);
        if (response.isSuccessful) {
          if (response.body != "null" && response.body.isNotEmpty) {
            emit(StatisticLoaded());
          } else {
            emit(StatisticError(error: response.error.toString()));
          }
        }
        break;

      default:
        emit(StatisticError(error: "Not implemented yet"));
        break;
    }
  }
}

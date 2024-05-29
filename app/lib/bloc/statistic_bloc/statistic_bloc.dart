import 'package:app/api/statistic/statistic_service.dart';
import 'package:app/resources/app_settings.dart';
import 'package:app/resources/jwt_helper.dart';
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
    if (!AppSettings.hasConnection) {
      emit(StatisticError(error: "No internet connection!"));
      return;
    }

    switch (event.title) {
      case "Total Moved Weight":
        final flexusjwt = JWTHelper.getActiveJWT();
        if (flexusjwt == null) {
          //NO-VALID-JWT-ERROR
          return;
        }

        final response = await _bestLiftsService.getTotalMovedWeight(flexusjwt, event.period);
        if (!response.isSuccessful) {
          emit(StatisticError(error: response.error.toString()));
          break;
        }

        JWTHelper.saveJWTsFromResponse(response);

        List<Map<String, dynamic>> values = [];
        if (response.body != null && response.body.isNotEmpty) {
          Map<String, dynamic> jsonMap = response.body;
          values.add(jsonMap.map((key, value) => MapEntry(key, value / 1000)));
        }
        emit(StatisticLoaded(values: values));

        break;

      case "Total Reps":
        final flexusjwt = JWTHelper.getActiveJWT();
        if (flexusjwt == null) {
          //NO-VALID-JWT-ERROR
          return;
        }

        final response = await _bestLiftsService.getTotalReps(flexusjwt, event.period);
        if (!response.isSuccessful) {
          emit(StatisticError(error: response.error.toString()));
          break;
        }

        JWTHelper.saveJWTsFromResponse(response);

        List<Map<String, dynamic>> values = [];
        if (response.body != null && response.body.isNotEmpty) {
          Map<String, dynamic> jsonMap = response.body;
          values.add(jsonMap.map((key, value) => MapEntry(key, value)));
        }
        emit(StatisticLoaded(values: values));

        break;

      case "Workout Days":
        final flexusjwt = JWTHelper.getActiveJWT();
        if (flexusjwt == null) {
          //NO-VALID-JWT-ERROR
          return;
        }

        final response = await _bestLiftsService.getWorkoutDays(flexusjwt, event.period);
        if (!response.isSuccessful) {
          emit(StatisticError(error: response.error.toString()));
        }

        JWTHelper.saveJWTsFromResponse(response);

        List<Map<String, dynamic>> values = [];
        if (response.body != null && response.body.isNotEmpty) {
          Map<String, dynamic> jsonMap = response.body;
          values.add(jsonMap.map((key, value) => MapEntry(key, value)));
        }
        emit(StatisticLoaded(values: values));

        break;

      case "Workout Duration":
        final flexusjwt = JWTHelper.getActiveJWT();
        if (flexusjwt == null) {
          //NO-VALID-JWT-ERROR
          return;
        }

        final response = await _bestLiftsService.getWorkoutDuration(flexusjwt, event.period);
        if (!response.isSuccessful) {
          emit(StatisticError(error: response.error.toString()));
        }

        JWTHelper.saveJWTsFromResponse(response);

        List<Map<String, dynamic>> values = [];
        if (response.body != null && response.body.isNotEmpty) {
          Map<String, dynamic> jsonMap = response.body;
          values.add(jsonMap.map((key, value) => MapEntry(key, (value / 60).roundToDouble())));
        }
        emit(StatisticLoaded(values: values));

        break;

      default:
        emit(StatisticError(error: "Not implemented yet"));
        break;
    }
  }
}

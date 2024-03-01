import 'dart:convert';

import 'package:app/api/best_lifts_service.dart';
import 'package:app/hive/best_lift_overview.dart';
import 'package:chopper/chopper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'best_lifts_event.dart';
part 'best_lifts_state.dart';

class BestLiftsBloc extends Bloc<BestLiftsEvent, BestLiftsState> {
  final BestLiftsService _bestLiftsService = BestLiftsService.create();
  final userBox = Hive.box('userBox');

  BestLiftsBloc() : super(BestLiftsInitial()) {
    on<LoadBestLifts>(_onLoadBestLifts);
  }

  void _onLoadBestLifts(LoadBestLifts event, Emitter<BestLiftsState> emit) async {
    emit(BestLiftsLoading());

    //simulate backend request delay
    // await Future.delayed(const Duration(seconds: 1));

    Response<dynamic> response;
    response = await _bestLiftsService.getBestLifts(userBox.get("flexusjwt"), event.userAccountID);

    if (response.isSuccessful) {
      if (response.body != "null" && response.bodyString.isNotEmpty) {
        List<dynamic> jsonList = jsonDecode(response.bodyString);

        List<BestLiftOverview> bestLiftOverviews = jsonList.map((jsonMap) {
          return BestLiftOverview(
            exerciseName: jsonMap['exerciseName'],
            repetitions: jsonMap['repetitions'],
            weight: jsonMap['weight'],
            duration: jsonMap['duration'],
          );
        }).toList();

        userBox.put("bestLiftOverview", bestLiftOverviews);
      }
      emit(BestLiftsLoaded());
    } else {
      emit(BestLiftsError());
    }
  }
}

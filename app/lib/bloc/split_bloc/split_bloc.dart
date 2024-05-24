import 'package:app/api/split/split_service.dart';
import 'package:app/hive/split/split.dart';
import 'package:app/resources/app_settings.dart';
import 'package:chopper/chopper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'split_event.dart';
part 'split_state.dart';

class SplitBloc extends Bloc<SplitEvent, SplitState> {
  final SplitService splitService = SplitService.create();

  final userBox = Hive.box('userBox');

  SplitBloc() : super(SplitInitial()) {
    on<GetSplits>(_onGetSplits);
  }

  void _onGetSplits(GetSplits event, Emitter<SplitState> emit) async {
    emit(SplitsLoading());

    if (!AppSettings.hasConnection) {
      emit(SplitError(error: "No internet connection!"));
      return;
    }

    Response<dynamic> response = await splitService.getSplitsFromPlanID(userBox.get("flexusjwt"), event.planID);

    if (!response.isSuccessful) {
      emit(SplitError(error: response.error.toString()));
    }

    List<Split> splits = [];

    if (response.body != "null") {
      final List<dynamic> jsonList = response.body;

      for (final gymData in jsonList) {
        final Split split = Split(
          id: gymData['id'],
          planID: gymData['planID'],
          name: gymData['name'],
          orderInPlan: gymData['orderInPlan'],
        );
        splits.add(split);
      }
    }

    emit(SplitsLoaded(splits: splits));
  }
}

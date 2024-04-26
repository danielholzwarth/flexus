import 'package:app/api/split/split_service.dart';
import 'package:app/hive/split/split.dart';
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

    Response<dynamic> response = await splitService.getSplits(userBox.get("flexusjwt"), event.planID);

    if (response.isSuccessful) {
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

        emit(SplitsLoaded(splits: splits));
      } else {
        emit(SplitsLoaded(splits: const []));
      }
    } else {
      emit(SplitError(error: response.error.toString()));
    }
  }
}

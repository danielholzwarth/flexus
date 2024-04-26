import 'package:app/hive/split/split.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'split_event.dart';
part 'split_state.dart';

class SplitBloc extends Bloc<SplitEvent, SplitState> {
  final userBox = Hive.box('userBox');

  SplitBloc() : super(SplitInitial()) {
    on<GetSplits>(_onGetSplits);
  }

  void _onGetSplits(GetSplits event, Emitter<SplitState> emit) async {
    emit(SplitsLoading());

    List<Split> splits = [
      Split(id: 1, planID: 1, name: "name1", orderInPlan: 1),
      Split(id: 2, planID: 2, name: "name2", orderInPlan: 2),
      Split(id: 3, planID: 3, name: "name3", orderInPlan: 3),
    ];

    emit(SplitsLoaded(splits: splits));
  }
}

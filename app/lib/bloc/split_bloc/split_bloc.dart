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

    emit(SplitsLoading());
  }
}

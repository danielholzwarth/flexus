import 'package:app/api/split/split_service.dart';
import 'package:app/hive/split/split.dart';
import 'package:app/hive/split/split_overview.dart';
import 'package:app/resources/app_settings.dart';
import 'package:app/resources/jwt_helper.dart';
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

    List<Split> splits = [];

    if (!AppSettings.hasConnection) {
      List<SplitOverview> splitOverviews = userBox.get("splitOverviews${event.planID}")?.cast<SplitOverview>() ?? [];
      for (var splitOverview in splitOverviews) {
        splits.add(splitOverview.split);
      }

      emit(SplitsLoaded(splits: splits));
      return;
    }

    final flexusjwt = JWTHelper.getActiveJWT();
    if (flexusjwt == null) {
      //NO-VALID-JWT-ERROR
      return;
    }

    Response<dynamic> response = await splitService.getSplitsFromPlanID(flexusjwt, event.planID);

    if (!response.isSuccessful) {
      emit(SplitError(error: response.error.toString()));
    }

    JWTHelper.saveJWTsFromResponse(response);

    if (response.body != "null") {
      final List<dynamic> jsonList = response.body;
      for (final json in jsonList) {
        Split split = Split.fromJson(json);
        splits.add(split);
      }
    }

    emit(SplitsLoaded(splits: splits));
  }
}

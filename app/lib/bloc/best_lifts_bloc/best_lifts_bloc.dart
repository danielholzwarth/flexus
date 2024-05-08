import 'package:app/api/best_lifts/best_lifts_service.dart';
import 'package:app/hive/best_lift/best_lift_overview.dart';
import 'package:app/resources/app_settings.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'best_lifts_event.dart';
part 'best_lifts_state.dart';

class BestLiftsBloc extends Bloc<BestLiftsEvent, BestLiftsState> {
  final BestLiftsService _bestLiftsService = BestLiftsService.create();
  final userBox = Hive.box('userBox');

  BestLiftsBloc() : super(BestLiftsInitial()) {
    on<PostBestLift>(_onPostBestLift);
    on<PatchBestLift>(_onPatchBestLift);
    on<GetBestLifts>(_onGetBestLifts);
  }

  void _onPostBestLift(PostBestLift event, Emitter<BestLiftsState> emit) async {
    print("post");
    emit(BestLiftPosting());

    List<BestLiftOverview> bestLiftOverviews = [];

    final response = await _bestLiftsService.postBestLift(userBox.get("flexusjwt"), {"exerciseID": event.exerciseID, "position": event.position});

    if (response.isSuccessful) {
      emit(BestLiftsLoaded(bestLiftOverviews: bestLiftOverviews));
    } else {
      emit(BestLiftsError(error: response.error.toString()));
    }
  }

  void _onPatchBestLift(PatchBestLift event, Emitter<BestLiftsState> emit) async {
    print("patch");
    emit(BestLiftPatching());

    List<BestLiftOverview> bestLiftOverviews = [];

    final response = await _bestLiftsService.patchBestLift(userBox.get("flexusjwt"), {"exerciseID": event.exerciseID, "position": event.position});

    if (response.isSuccessful) {
      emit(BestLiftsLoaded(bestLiftOverviews: bestLiftOverviews));
    } else {
      emit(BestLiftsError(error: response.error.toString()));
    }
  }

  void _onGetBestLifts(GetBestLifts event, Emitter<BestLiftsState> emit) async {
    emit(BestLiftsLoading());

    List<BestLiftOverview> bestLiftOverviews = [];

    if (AppSettings.hasConnection) {
      final response = await _bestLiftsService.getBestLiftsFromUserID(userBox.get("flexusjwt"), event.userAccountID);
      if (response.isSuccessful) {
        if (response.body != "null" && response.body.isNotEmpty) {
          List<dynamic> jsonList = response.body;
          bestLiftOverviews = jsonList.map((jsonMap) {
            return BestLiftOverview(
              exerciseName: jsonMap['exerciseName'],
              repetitions: jsonMap['repetitions'],
              workload: double.parse(jsonMap['workload'].toString()),
              isRepetition: jsonMap['isRepetition'],
            );
          }).toList();

          userBox.put("bestLiftOverview", bestLiftOverviews);
        }
        emit(BestLiftsLoaded(bestLiftOverviews: bestLiftOverviews));
      } else {
        emit(BestLiftsError(error: response.error.toString()));
      }
    } else {
      bestLiftOverviews = userBox.get("bestLiftOverview") ?? [];
      bestLiftOverviews = bestLiftOverviews.cast<BestLiftOverview>();
      emit(BestLiftsLoaded(bestLiftOverviews: bestLiftOverviews));
    }
  }
}

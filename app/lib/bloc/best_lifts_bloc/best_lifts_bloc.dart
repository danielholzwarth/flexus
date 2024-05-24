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
    List<BestLiftOverview> bestLiftOverviews = userBox.get("bestLiftOverview")?.cast<BestLiftOverview>() ?? [];

    if (!AppSettings.hasConnection) {
      emit(BestLiftsError(error: "No internet connection!"));
      emit(BestLiftsLoaded(bestLiftOverviews: bestLiftOverviews));
      return;
    }

    final response = await _bestLiftsService.postBestLift(userBox.get("flexusjwt"), {"exerciseID": event.exerciseID, "position": event.position});

    if (!response.isSuccessful) {
      emit(BestLiftsError(error: response.error.toString()));
      emit(BestLiftsLoaded(bestLiftOverviews: bestLiftOverviews));
      return;
    }

    if (response.body != "null" && response.body.isNotEmpty) {
      List<dynamic> jsonList = response.body;
      bestLiftOverviews = jsonList.map((jsonMap) {
        return BestLiftOverview(
          exerciseName: jsonMap['exerciseName'] ?? "",
          repetitions: jsonMap['repetitions'] ?? "",
          workload: jsonMap['workload'] != null ? double.tryParse(jsonMap['workload'].toString()) ?? 0.0 : 0.0,
          isRepetition: jsonMap['isRepetition'] ?? false,
          position: jsonMap['position'] ?? 0,
        );
      }).toList();

      userBox.put("bestLiftOverview", bestLiftOverviews);
    }

    emit(BestLiftsLoaded(bestLiftOverviews: bestLiftOverviews));
  }

  void _onPatchBestLift(PatchBestLift event, Emitter<BestLiftsState> emit) async {
    List<BestLiftOverview> bestLiftOverviews = userBox.get("bestLiftOverview")?.cast<BestLiftOverview>() ?? [];

    if (!AppSettings.hasConnection) {
      emit(BestLiftsError(error: "No internet connection!"));
      emit(BestLiftsLoaded(bestLiftOverviews: bestLiftOverviews));
      return;
    }

    final response = await _bestLiftsService.patchBestLift(userBox.get("flexusjwt"), {"exerciseID": event.exerciseID, "position": event.position});

    if (!response.isSuccessful) {
      emit(BestLiftsError(error: response.error.toString()));
      emit(BestLiftsLoaded(bestLiftOverviews: bestLiftOverviews));
      return;
    }

    if (response.body != "null" && response.body.isNotEmpty) {
      List<dynamic> jsonList = response.body;
      bestLiftOverviews = jsonList.map((jsonMap) {
        return BestLiftOverview(
          exerciseName: jsonMap['exerciseName'],
          repetitions: jsonMap['repetitions'],
          workload: double.parse(jsonMap['workload'].toString()),
          isRepetition: jsonMap['isRepetition'],
          position: jsonMap['position'],
        );
      }).toList();

      userBox.put("bestLiftOverview", bestLiftOverviews);
    }

    emit(BestLiftsLoaded(bestLiftOverviews: bestLiftOverviews));
  }

  void _onGetBestLifts(GetBestLifts event, Emitter<BestLiftsState> emit) async {
    List<BestLiftOverview> bestLiftOverviews = userBox.get("bestLiftOverview")?.cast<BestLiftOverview>() ?? [];

    if (!AppSettings.hasConnection) {
      emit(BestLiftsLoaded(bestLiftOverviews: bestLiftOverviews));
      return;
    }

    final response = await _bestLiftsService.getBestLiftsFromUserID(userBox.get("flexusjwt"), event.userAccountID);

    if (!response.isSuccessful) {
      emit(BestLiftsError(error: response.error.toString()));
      emit(BestLiftsLoaded(bestLiftOverviews: bestLiftOverviews));
      return;
    }

    if (response.body != "null" && response.body.isNotEmpty) {
      List<dynamic> jsonList = response.body;
      bestLiftOverviews = jsonList.map((jsonMap) {
        return BestLiftOverview(
          exerciseName: jsonMap['exerciseName'],
          repetitions: jsonMap['repetitions'],
          workload: double.parse(jsonMap['workload'].toString()),
          isRepetition: jsonMap['isRepetition'],
          position: jsonMap['position'],
        );
      }).toList();

      userBox.put("bestLiftOverview", bestLiftOverviews);
    }

    emit(BestLiftsLoaded(bestLiftOverviews: bestLiftOverviews));
  }
}

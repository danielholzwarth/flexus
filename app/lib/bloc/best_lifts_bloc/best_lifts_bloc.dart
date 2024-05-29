import 'package:app/api/best_lifts/best_lifts_service.dart';
import 'package:app/hive/best_lift/best_lift_overview.dart';
import 'package:app/resources/app_settings.dart';
import 'package:app/resources/jwt_helper.dart';
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
    List<BestLiftOverview> bestLiftOverviews = [];

    if (!AppSettings.hasConnection) {
      bestLiftOverviews = userBox.get("bestLiftOverview")?.cast<BestLiftOverview>() ?? [];
      emit(BestLiftsError(error: "No internet connection!"));
      emit(BestLiftsLoaded(bestLiftOverviews: bestLiftOverviews));
      return;
    }

    final flexusjwt = JWTHelper.getActiveJWT();
    if (flexusjwt == null) {
      //NO-VALID-JWT-ERROR
      return;
    }

    final response = await _bestLiftsService.postBestLift(flexusjwt, {"exerciseID": event.exerciseID, "position": event.position});

    if (!response.isSuccessful) {
      bestLiftOverviews = userBox.get("bestLiftOverview")?.cast<BestLiftOverview>() ?? [];
      emit(BestLiftsError(error: response.error.toString()));
      emit(BestLiftsLoaded(bestLiftOverviews: bestLiftOverviews));
      return;
    }

    JWTHelper.saveJWTsFromResponse(response);

    if (response.body != "null" && response.body.isNotEmpty) {
      bestLiftOverviews = List<BestLiftOverview>.from(response.body.map((jsonMap) {
        return BestLiftOverview.fromJson(jsonMap);
      }));

      userBox.put("bestLiftOverview", bestLiftOverviews);
    }

    emit(BestLiftsLoaded(bestLiftOverviews: bestLiftOverviews));
  }

  void _onPatchBestLift(PatchBestLift event, Emitter<BestLiftsState> emit) async {
    List<BestLiftOverview> bestLiftOverviews = [];

    if (!AppSettings.hasConnection) {
      bestLiftOverviews = userBox.get("bestLiftOverview")?.cast<BestLiftOverview>() ?? [];
      emit(BestLiftsError(error: "No internet connection!"));
      emit(BestLiftsLoaded(bestLiftOverviews: bestLiftOverviews));
      return;
    }

    final flexusjwt = JWTHelper.getActiveJWT();
    if (flexusjwt == null) {
      //NO-VALID-JWT-ERROR
      return;
    }

    final response = await _bestLiftsService.patchBestLift(flexusjwt, {"exerciseID": event.exerciseID, "position": event.position});

    if (!response.isSuccessful) {
      bestLiftOverviews = userBox.get("bestLiftOverview")?.cast<BestLiftOverview>() ?? [];
      emit(BestLiftsError(error: response.error.toString()));
      emit(BestLiftsLoaded(bestLiftOverviews: bestLiftOverviews));
      return;
    }

    JWTHelper.saveJWTsFromResponse(response);

    if (response.body != "null" && response.body.isNotEmpty) {
      bestLiftOverviews = List<BestLiftOverview>.from(response.body.map((jsonMap) {
        return BestLiftOverview.fromJson(jsonMap);
      }));

      userBox.put("bestLiftOverview", bestLiftOverviews);
    }

    emit(BestLiftsLoaded(bestLiftOverviews: bestLiftOverviews));
  }

  void _onGetBestLifts(GetBestLifts event, Emitter<BestLiftsState> emit) async {
    List<BestLiftOverview> bestLiftOverviews = [];

    if (!AppSettings.hasConnection) {
      bestLiftOverviews = userBox.get("bestLiftOverview")?.cast<BestLiftOverview>() ?? [];
      emit(BestLiftsLoaded(bestLiftOverviews: bestLiftOverviews));
      return;
    }

    final flexusjwt = JWTHelper.getActiveJWT();
    if (flexusjwt == null) {
      //NO-VALID-JWT-ERROR
      return;
    }

    final response = await _bestLiftsService.getBestLiftsFromUserID(flexusjwt, event.userAccountID);

    if (!response.isSuccessful) {
      bestLiftOverviews = userBox.get("bestLiftOverview")?.cast<BestLiftOverview>() ?? [];
      emit(BestLiftsError(error: response.error.toString()));
      emit(BestLiftsLoaded(bestLiftOverviews: bestLiftOverviews));
      return;
    }

    JWTHelper.saveJWTsFromResponse(response);

    if (response.bodyBytes.isNotEmpty) {
      bestLiftOverviews = List<BestLiftOverview>.from(response.body.map((jsonMap) {
        return BestLiftOverview.fromJson(jsonMap);
      }));

      userBox.put("bestLiftOverview", bestLiftOverviews);
    }

    if (response.bodyBytes.isEmpty) {
      userBox.put("bestLiftOverview", []);
    }

    emit(BestLiftsLoaded(bestLiftOverviews: bestLiftOverviews));
  }
}

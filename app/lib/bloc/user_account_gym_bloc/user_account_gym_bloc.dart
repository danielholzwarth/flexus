import 'package:app/api/user_account_gym/user_account_gym_service.dart';
import 'package:app/resources/app_settings.dart';
import 'package:app/resources/jwt_helper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'user_account_gym_event.dart';
part 'user_account_gym_state.dart';

class UserAccountGymBloc extends Bloc<UserAccountGymEvent, UserAccountGymState> {
  final UserAccountGymService userAccountGymService = UserAccountGymService.create();
  final userBox = Hive.box('userBox');

  UserAccountGymBloc() : super(UserAccountGymInitial()) {
    on<PostUserAccountGym>(_onPostUserAccountGym);
    on<GetUserAccountGym>(_onGetUserAccountGym);
    on<DeleteUserAccountGym>(_onDeleteUserAccountGym);
  }

  void _onPostUserAccountGym(PostUserAccountGym event, Emitter<UserAccountGymState> emit) async {
    if (!AppSettings.hasConnection) {
      emit(UserAccountGymError(error: "No internet connection!"));
      return;
    }

    final flexusjwt = JWTHelper.getActiveJWT();
    if (flexusjwt == null) {
      //NO-VALID-JWT-ERROR
      return;
    }

    final response = await userAccountGymService.postUserAccountGym(flexusjwt, {"gymID": event.gymID});

    if (!response.isSuccessful) {
      emit(UserAccountGymError(error: response.error.toString()));
      return;
    }

    JWTHelper.saveJWTsFromResponse(response);

    emit(UserAccountGymCreated());
  }

  void _onGetUserAccountGym(GetUserAccountGym event, Emitter<UserAccountGymState> emit) async {
    emit(UserAccountGymLoading());

    if (!AppSettings.hasConnection) {
      emit(UserAccountGymError(error: "No internet connection!"));
      return;
    }

    final flexusjwt = JWTHelper.getActiveJWT();
    if (flexusjwt == null) {
      //NO-VALID-JWT-ERROR
      return;
    }

    final response = await userAccountGymService.getUserAccountGym(flexusjwt, gymID: event.gymID);

    if (!response.isSuccessful) {
      emit(UserAccountGymError(error: response.error.toString()));
      return;
    }

    JWTHelper.saveJWTsFromResponse(response);

    if (response.body == null) {
      emit(UserAccountGymLoaded(isExisting: false));
      return;
    }

    if (response.body == true) {
      emit(UserAccountGymLoaded(isExisting: true));
      return;
    }

    if (response.body == false) {
      emit(UserAccountGymLoaded(isExisting: false));
      return;
    }

    emit(UserAccountGymError(error: "User Account Gym Forbidden Value"));
  }

  void _onDeleteUserAccountGym(DeleteUserAccountGym event, Emitter<UserAccountGymState> emit) async {
    if (!AppSettings.hasConnection) {
      emit(UserAccountGymError(error: "No internet connection!"));
      return;
    }

    final flexusjwt = JWTHelper.getActiveJWT();
    if (flexusjwt == null) {
      //NO-VALID-JWT-ERROR
      return;
    }

    final response = await userAccountGymService.deleteUserAccountGym(flexusjwt, event.gymID);

    if (!response.isSuccessful) {
      emit(UserAccountGymError(error: response.error.toString()));
      return;
    }

    JWTHelper.saveJWTsFromResponse(response);

    emit(UserAccountGymDeleted());
  }
}

import 'dart:convert';

import 'package:app/api/user_account/user_account_service.dart';
import 'package:app/hive/user_account/user_account.dart';
import 'package:app/hive/user_account_gym/user_account_gym_overview.dart';
import 'package:app/resources/app_settings.dart';
import 'package:chopper/chopper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'user_account_event.dart';
part 'user_account_state.dart';

class UserAccountBloc extends Bloc<UserAccountEvent, UserAccountState> {
  final UserAccountService _userAccountService = UserAccountService.create();
  final userBox = Hive.box('userBox');

  UserAccountBloc() : super(UserAccountInitial()) {
    on<GetUserAccount>(_onGetUserAccount);
    on<PatchUserAccount>(_onPatchUserAccount);
    on<GetUserAccounts>(_onGetUserAccounts);
    on<GetUserAccountsGym>(_onGetUserAccountsGym);
  }

  void _onGetUserAccount(GetUserAccount event, Emitter<UserAccountState> emit) async {
    emit(UserAccountLoading());

    if (AppSettings.hasConnection) {
      UserAccount storedUserAccount = userBox.get("userAccount");
      emit(UserAccountLoaded(userAccount: storedUserAccount));
      return;
    }

    Response<dynamic> response = await _userAccountService.getUserAccountFromUserID(userBox.get("flexusjwt"), event.userAccountID);

    if (!response.isSuccessful) {
      emit(UserAccountError(error: response.error.toString()));
      return;
    }

    if (response.body != "null") {
      final Map<String, dynamic> jsonMap = response.body;

      final userAccount = UserAccount(
        id: jsonMap['userAccountID'],
        username: jsonMap['username'],
        name: jsonMap['name'],
        createdAt: DateTime.parse(jsonMap['createdAt']).add(AppSettings.timeZoneOffset),
        level: jsonMap['level'],
        profilePicture: jsonMap['profilePicture'] != null ? base64Decode(jsonMap['profilePicture']) : null,
      );

      UserAccount storedUserAccount = userBox.get("userAccount");
      if (event.userAccountID == storedUserAccount.id) {
        userBox.put("userAccount", userAccount);
      }

      emit(UserAccountLoaded(userAccount: userAccount));
    } else {
      emit(UserAccountError(error: response.error.toString()));
    }
  }

  void _onPatchUserAccount(PatchUserAccount event, Emitter<UserAccountState> emit) async {
    UserAccount userAccount = userBox.get("userAccount");

    switch (event.name) {
      case "username":
        if (!AppSettings.hasConnection) {
          userAccount.username = event.value;
          userBox.put("userAccount", userAccount);
          break;
        }

        final response = await _userAccountService.patchUserAccount(userBox.get("flexusjwt"), {"username": event.value});
        if (response.isSuccessful) {
          userAccount.username = event.value;
          userBox.put("userAccount", userAccount);
        } else {
          emit(UserAccountError(error: response.error.toString()));
        }

        break;

      case "name":
        if (!AppSettings.hasConnection) {
          userAccount.name = event.value;
          userBox.put("userAccount", userAccount);
          break;
        }

        final response = await _userAccountService.patchUserAccount(userBox.get("flexusjwt"), {"name": event.value});
        if (response.isSuccessful) {
          userAccount.name = event.value;
          userBox.put("userAccount", userAccount);
        } else {
          emit(UserAccountError(error: response.error.toString()));
        }

        break;

      case "password":
        await _userAccountService.patchUserAccount(userBox.get("flexusjwt"), {"new_password": event.value, "old_password": event.value2});

        break;

      case "profilePicture":
        String profilePictureString = "";
        if (event.value != null) {
          profilePictureString = base64Encode(event.value);
        }

        if (!AppSettings.hasConnection) {
          userAccount.profilePicture = event.value;
          userBox.put("userAccount", userAccount);
          break;
        }

        Response<dynamic> response;

        if (event.value != null) {
          response = await _userAccountService.patchUserAccount(userBox.get("flexusjwt"), {"profile_picture": profilePictureString});
        } else {
          response = await _userAccountService.patchUserAccount(userBox.get("flexusjwt"), {"profile_picture": ""});
        }
        if (response.isSuccessful) {
          userAccount.profilePicture = event.value;
          userBox.put("userAccount", userAccount);
        } else {
          emit(UserAccountError(error: response.error.toString()));
        }

        break;
      default:
        emit(UserAccountError(error: "Patch not implemented yet!"));
    }

    emit(UserAccountLoaded(userAccount: userAccount));
  }

  void _onGetUserAccounts(GetUserAccounts event, Emitter<UserAccountState> emit) async {
    emit(UserAccountsLoading());

    if (!AppSettings.hasConnection) {
      emit(UserAccountError(error: "No internet connection!"));
      return;
    }

    Response<dynamic> response = await _userAccountService.getUserAccounts(
      userBox.get("flexusjwt"),
      keyword: event.keyword,
      isFriend: event.isFriend,
      hasRequest: event.hasRequest,
    );

    if (!response.isSuccessful) {
      emit(UserAccountsError(error: response.error.toString()));
      return;
    }

    List<UserAccount> userAccounts = [];
    if (response.body != "null") {
      final List<dynamic> userAccountsJson = response.body;
      final UserAccount userAccount = userBox.get("userAccount");

      for (final userData in userAccountsJson) {
        if (userData['userAccountID'] != userAccount.id) {
          final loadedUserAccount = UserAccount(
            id: userData['userAccountID'],
            username: userData['username'],
            name: userData['name'],
            createdAt: DateTime.parse(userData['createdAt']).add(AppSettings.timeZoneOffset),
            level: userData['level'],
            profilePicture: userData['profilePicture'] != null ? base64Decode(userData['profilePicture']) : null,
          );
          userAccounts.add(loadedUserAccount);
        }
      }
    }

    emit(UserAccountsLoaded(userAccounts: userAccounts));
  }

  void _onGetUserAccountsGym(GetUserAccountsGym event, Emitter<UserAccountState> emit) async {
    emit(UserAccountsLoading());

    if (!AppSettings.hasConnection) {
      emit(UserAccountError(error: "No internet connection!"));
      return;
    }

    Response<dynamic> response = await _userAccountService.getUserAccountsFromGymID(
      userBox.get("flexusjwt"),
      event.gymID,
      isWorkingOut: event.isWorkingOut,
    );

    if (!response.isSuccessful) {
      emit(UserAccountsError(error: response.error.toString()));
      return;
    }

    List<UserAccountGymOverview> userAccountGymOverviews = [];
    if (response.body != "null") {
      final List<dynamic> userAccountsJson = response.body;

      for (final userData in userAccountsJson) {
        final userAccountGymOverview = UserAccountGymOverview(
          id: userData['userAccountID'],
          username: userData['username'],
          name: userData['name'],
          profilePicture: userData['profilePicture'] != null ? base64Decode(userData['profilePicture']) : null,
          workoutStartTime: DateTime.parse(userData['workoutStartTime']).add(AppSettings.timeZoneOffset),
          averageWorkoutDuration: Duration(seconds: userData['averageWorkoutDuration'] != null ? userData['averageWorkoutDuration']?.toInt() : 0),
        );
        userAccountGymOverviews.add(userAccountGymOverview);
      }
    }

    emit(UserAccountGymOverviewsLoaded(userAccountGymOverviews: userAccountGymOverviews));
  }
}

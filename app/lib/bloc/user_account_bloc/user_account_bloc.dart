import 'dart:convert';

import 'package:app/api/user_account_service.dart';
import 'package:app/hive/user_account.dart';
import 'package:app/hive/user_account_gym_overview.dart';
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
    on<GetUserAccountsFriendsSearch>(_onGetUserAccountsFriendsSearch);
    on<GetUserAccountsFriendsGym>(_onGetUserAccountsFriendsGym);
  }

  void _onGetUserAccount(GetUserAccount event, Emitter<UserAccountState> emit) async {
    emit(UserAccountLoading());

    Response<dynamic> response;
    response = await _userAccountService.getUserAccount(userBox.get("flexusjwt"), event.userAccountID);

    if (response.isSuccessful) {
      if (response.bodyString != "null") {
        final Map<String, dynamic> jsonMap = jsonDecode(response.bodyString);

        final userAccount = UserAccount(
          id: jsonMap['userAccountID'],
          username: jsonMap['username'],
          name: jsonMap['name'],
          createdAt: DateTime.parse(jsonMap['createdAt']),
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
    } else {
      emit(UserAccountError(error: response.error.toString()));
    }
  }

  void _onPatchUserAccount(PatchUserAccount event, Emitter<UserAccountState> emit) async {
    emit(UserAccountUpdating());

    UserAccount userAccount = userBox.get("userAccount");

    switch (event.name) {
      case "username":
        final response = await _userAccountService.patchUserAccount(userBox.get("flexusjwt"), {"username": event.value});
        if (response.isSuccessful) {
          userAccount.username = event.value;
          userBox.put("userAccount", userAccount);
        }
        break;

      case "name":
        final response = await _userAccountService.patchUserAccount(userBox.get("flexusjwt"), {"name": event.value});
        if (response.isSuccessful) {
          userAccount.name = event.value;
          userBox.put("userAccount", userAccount);
        }
        break;

      case "password":
        await _userAccountService.patchUserAccount(userBox.get("flexusjwt"), {"new_password": event.value, "old_password": event.value2});
        break;

      case "profilePicture":
        Response<dynamic> response;

        if (event.value != null) {
          final profilePictureString = base64Encode(event.value);
          response = await _userAccountService.patchUserAccount(userBox.get("flexusjwt"), {"profile_picture": profilePictureString});
        } else {
          response = await _userAccountService.patchUserAccount(userBox.get("flexusjwt"), {"profile_picture": ""});
        }
        if (response.isSuccessful) {
          userAccount.profilePicture = event.value;
          userBox.put("userAccount", userAccount);
        }
        break;
      default:
        emit(UserAccountsError(error: "Patch not implemented yet!"));
    }

    emit(UserAccountLoaded(userAccount: userAccount));
  }

  void _onGetUserAccountsFriendsSearch(GetUserAccountsFriendsSearch event, Emitter<UserAccountState> emit) async {
    emit(UserAccountsLoading());

    Response<dynamic> response = await _userAccountService.getUserAccounts(
      userBox.get("flexusjwt"),
      isFriend: event.isFriend,
      hasRequest: event.hasRequest,
      keyword: event.keyword,
    );

    if (response.isSuccessful) {
      List<UserAccount> userAccounts = [];
      if (response.bodyString != "null") {
        final List<dynamic> userAccountsJson = jsonDecode(response.bodyString);
        final UserAccount userAccount = userBox.get("userAccount");

        for (final userData in userAccountsJson) {
          if (userData['userAccountID'] != userAccount.id) {
            final loadedUserAccount = UserAccount(
              id: userData['userAccountID'],
              username: userData['username'],
              name: userData['name'],
              createdAt: DateTime.parse(userData['createdAt']),
              level: userData['level'],
              profilePicture: userData['profilePicture'] != null ? base64Decode(userData['profilePicture']) : null,
            );
            userAccounts.add(loadedUserAccount);
          }
        }

        emit(UserAccountsLoaded(userAccounts: userAccounts));
      } else {
        emit(UserAccountsLoaded(userAccounts: userAccounts));
      }
    } else {
      emit(UserAccountsError(error: response.error.toString()));
    }
  }

  void _onGetUserAccountsFriendsGym(GetUserAccountsFriendsGym event, Emitter<UserAccountState> emit) async {
    emit(UserAccountsLoading());

    Response<dynamic> response = await _userAccountService.getUserAccounts(
      userBox.get("flexusjwt"),
      isFriend: event.isFriend,
      gymID: event.gymID,
      isWorkingOut: event.isWorkingOut,
    );

    if (response.isSuccessful) {
      List<UserAccountGymOverview> userAccountGymOverviews = [];
      if (response.bodyString != "null") {
        final List<dynamic> userAccountsJson = jsonDecode(response.bodyString);
        final UserAccount userAccount = userBox.get("userAccount");

        for (final userData in userAccountsJson) {
          if (userData['userAccountID'] != userAccount.id) {
            final userAccountGymOverview = UserAccountGymOverview(
              id: userData['userAccountID'],
              username: userData['username'],
              name: userData['name'],
              profilePicture: userData['profilePicture'] != null ? base64Decode(userData['profilePicture']) : null,
              workoutStartTime: DateTime.parse(userData['workoutStartTime']),
              averageWorkoutDuration: Duration(seconds: userData['averageWorkoutDuration'].toInt()),
            );
            userAccountGymOverviews.add(userAccountGymOverview);
          }
        }

        emit(UserAccountGymOverviewsLoaded(userAccountGymOverviews: userAccountGymOverviews));
      } else {
        emit(UserAccountGymOverviewsLoaded(userAccountGymOverviews: userAccountGymOverviews));
      }
    } else {
      emit(UserAccountsError(error: response.error.toString()));
    }
  }
}

import 'dart:convert';

import 'package:app/api/user_account/user_account_service.dart';
import 'package:app/hive/user_account/user_account.dart';
import 'package:app/hive/user_account_gym/user_account_gym_overview.dart';
import 'package:app/resources/app_settings.dart';
import 'package:app/resources/jwt_helper.dart';
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

    if (!AppSettings.hasConnection) {
      UserAccount storedUserAccount = userBox.get("userAccount");
      if (storedUserAccount.id == event.userAccountID) {
        emit(UserAccountLoaded(userAccount: storedUserAccount));
      } else {
        emit(UserAccountError(error: "Internet connection required!"));
      }
      return;
    }

    final flexusjwt = JWTHelper.getActiveJWT();
    if (flexusjwt == null) {
      //NO-VALID-JWT-ERROR
      return;
    }

    Response<dynamic> response = await _userAccountService.getUserAccountFromUserID(flexusjwt, event.userAccountID);

    if (!response.isSuccessful) {
      emit(UserAccountError(error: response.error.toString()));
      return;
    }

    JWTHelper.saveJWTsFromResponse(response);

    if (response.body != "null") {
      final userAccount = UserAccount.fromJson(response.body);

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

        final flexusjwt = JWTHelper.getActiveJWT();
        if (flexusjwt == null) {
          //NO-VALID-JWT-ERROR
          return;
        }

        final response = await _userAccountService.patchUserAccount(flexusjwt, {"username": event.value});
        if (response.isSuccessful) {
          JWTHelper.saveJWTsFromResponse(response);

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

        final flexusjwt = JWTHelper.getActiveJWT();
        if (flexusjwt == null) {
          //NO-VALID-JWT-ERROR
          return;
        }

        final response = await _userAccountService.patchUserAccount(flexusjwt, {"name": event.value});
        if (response.isSuccessful) {
          JWTHelper.saveJWTsFromResponse(response);

          userAccount.name = event.value;
          userBox.put("userAccount", userAccount);
        } else {
          emit(UserAccountError(error: response.error.toString()));
        }

        break;

      case "password":
        final flexusjwt = JWTHelper.getActiveJWT();
        if (flexusjwt == null) {
          //NO-VALID-JWT-ERROR
          return;
        }

        await _userAccountService.patchUserAccount(flexusjwt, {"new_password": event.value, "old_password": event.value2});

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

        final flexusjwt = JWTHelper.getActiveJWT();
        if (flexusjwt == null) {
          //NO-VALID-JWT-ERROR
          return;
        }

        if (event.value != null) {
          response = await _userAccountService.patchUserAccount(flexusjwt, {"profile_picture": profilePictureString});
        } else {
          response = await _userAccountService.patchUserAccount(flexusjwt, {"profile_picture": ""});
        }
        if (response.isSuccessful) {
          JWTHelper.saveJWTsFromResponse(response);

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

    final flexusjwt = JWTHelper.getActiveJWT();
    if (flexusjwt == null) {
      //NO-VALID-JWT-ERROR
      return;
    }

    Response<dynamic> response = await _userAccountService.getUserAccounts(
      flexusjwt,
      keyword: event.keyword,
      isFriend: event.isFriend,
      hasRequest: event.hasRequest,
    );

    if (!response.isSuccessful) {
      emit(UserAccountsError(error: response.error.toString()));
      return;
    }

    JWTHelper.saveJWTsFromResponse(response);

    List<UserAccount> userAccounts = [];
    if (response.body != "null") {
      final List<dynamic> userAccountsJson = response.body;
      final UserAccount userAccount = userBox.get("userAccount");

      for (final userData in userAccountsJson) {
        if (userData['userAccountID'] != userAccount.id) {
          final loadedUserAccount = UserAccount.fromJson(userData);
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

    final flexusjwt = JWTHelper.getActiveJWT();
    if (flexusjwt == null) {
      //NO-VALID-JWT-ERROR
      return;
    }

    Response<dynamic> response = await _userAccountService.getUserAccountsFromGymID(
      flexusjwt,
      event.gymID,
      isWorkingOut: event.isWorkingOut,
    );

    if (!response.isSuccessful) {
      emit(UserAccountsError(error: response.error.toString()));
      return;
    }

    JWTHelper.saveJWTsFromResponse(response);

    List<UserAccountGymOverview> userAccountGymOverviews = [];
    if (response.body != "null") {
      final List<dynamic> userAccountsJson = response.body;

      for (final userData in userAccountsJson) {
        final userAccountGymOverview = UserAccountGymOverview.fromJson(userData);
        userAccountGymOverviews.add(userAccountGymOverview);
      }
    }

    emit(UserAccountGymOverviewsLoaded(userAccountGymOverviews: userAccountGymOverviews));
  }
}

import 'dart:convert';

import 'package:app/api/user_account_service.dart';
import 'package:app/hive/user_account.dart';
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
    on<LoadUserAccount>(_onLoadUserAccount);
    on<PatchUserAccount>(_onPatchUserAccount);
  }

  void _onLoadUserAccount(LoadUserAccount event, Emitter<UserAccountState> emit) async {
    emit(UserAccountLoading());

    //simulate backend request delay
    // await Future.delayed(const Duration(seconds: 1));

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
        emit(UserAccountError());
      }
    } else {
      emit(UserAccountError());
    }
  }

  void _onPatchUserAccount(PatchUserAccount event, Emitter<UserAccountState> emit) async {
    emit(UserAccountUpdating());

    //simulate backend request delay
    // await Future.delayed(const Duration(seconds: 1));

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

      // case "level":
      //   final response = await _userAccountService.patchUserAccount(userBox.get("flexusjwt"), {"level": event.value});
      //   if (response.isSuccessful) {
      //     userAccount.level = event.value;
      //     userBox.put("userAccount", userAccount);
      //   }
      //   break;

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
    }

    emit(UserAccountLoaded(userAccount: userAccount));
  }
}

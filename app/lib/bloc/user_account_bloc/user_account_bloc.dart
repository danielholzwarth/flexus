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
    on<PutUserAccount>(_onPutUserAccount);
  }

  void _onLoadUserAccount(LoadUserAccount event, Emitter<UserAccountState> emit) async {
    emit(UserAccountLoading());

    //simulate backend request delay
    //await Future.delayed(const Duration(seconds: 1));

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

        userBox.put("userAccount", userAccount);

        emit(UserAccountLoaded(userAccount: userAccount));
      } else {
        emit(UserAccountError());
      }
    } else {
      emit(UserAccountError());
    }
  }

  void _onPutUserAccount(PutUserAccount event, Emitter<UserAccountState> emit) async {
    emit(UserAccountUpdating());

    //simulate backend request delay
    //await Future.delayed(const Duration(seconds: 1));

    Response<dynamic> response;
    response = await _userAccountService.putUserAccount(userBox.get("flexusjwt"), {
      "userAccountID": event.userAccount.id,
      "username": event.userAccount.username,
      "name": event.userAccount.name,
      "level": event.userAccount.level,
      "profilePicture": event.userAccount.profilePicture,
    });

    if (response.isSuccessful) {
      userBox.put("userAccount", event.userAccount);
      emit(UserAccountUpdated());
    } else {
      emit(UserAccountError());
    }
  }
}

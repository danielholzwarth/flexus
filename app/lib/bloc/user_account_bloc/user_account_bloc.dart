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

    //on<ChangeUserAccount>(_onChangeUserAccount);
  }

  void _onLoadUserAccount(LoadUserAccount event, Emitter<UserAccountState> emit) async {
    emit(UserAccountLoading());

    //simulate backend request delay
    await Future.delayed(const Duration(seconds: 1));

    Response<dynamic> response;
    response = await _userAccountService.getUserAccount(userBox.get("flexusjwt"), event.userAccountID);

    if (response.isSuccessful) {
      if (response.bodyString != "null") {
        final Map<String, dynamic> jsonMap = jsonDecode(response.bodyString);

        final userAccount = UserAccount(
          id: jsonMap['id'],
          username: jsonMap['username'],
          name: jsonMap['name'],
          createdAt: DateTime.parse(jsonMap['createdAt']),
          level: jsonMap['level'],
          profilePicture: jsonMap['profilePicture'],
          bodyweight: jsonMap['bodyweight'],
        );

        emit(UserAccountLoaded(userAccount: userAccount));
      } else {
        emit(UserAccountError());
      }
    } else {
      emit(UserAccountError());
    }
  }
}

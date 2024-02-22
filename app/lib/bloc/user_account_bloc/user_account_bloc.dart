import 'dart:convert';

import 'package:app/api/user_account_service.dart';
import 'package:app/hive/best_lift.dart';
import 'package:app/hive/best_lift_overview.dart';
import 'package:app/hive/user_account.dart';
import 'package:app/hive/user_account_overview.dart';
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
    response = await _userAccountService.getUserAccountOverview(userBox.get("flexusjwt"), event.userAccountID);

    if (response.isSuccessful) {
      if (response.bodyString != "null") {
        final Map<String, dynamic> jsonMap = jsonDecode(response.bodyString);

        final userAccountOverview = UserAccountOverview(
          userAccount: UserAccount(
              id: jsonMap['userAccount']['id'],
              username: jsonMap['userAccount']['username'],
              name: jsonMap['userAccount']['name'],
              createdAt: jsonMap['userAccount']['createdAt'],
              level: jsonMap['userAccount']['level']),
          bestLiftOverview: List.generate(jsonMap['bestLift'].length, (index) {
            return BestLiftOverview(
              bestLift: BestLift(
                id: jsonMap['bestLift'][index]['id'],
                userID: jsonMap['bestLift'][index]['userID'],
                setID: jsonMap['bestLift'][index]['setID'],
                positionID: jsonMap['bestLift'][index]['positionID'],
              ),
              exerciseName: jsonMap['exerciseName'],
              repetitions: jsonMap['repetitions'],
              weight: jsonMap['weight'],
              duration: jsonMap['duration'],
            );
          }),
        );

        emit(UserAccountLoaded(userAccountOverview: userAccountOverview));
      }
    } else {
      emit(UserAccountError());
    }
  }
}

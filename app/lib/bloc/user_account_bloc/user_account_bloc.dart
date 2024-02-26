import 'dart:convert';

import 'package:app/api/user_account_service.dart';
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

        print(response.bodyString);

        final userAccountOverview = UserAccountOverview(
          userAccount: UserAccount(
            id: jsonMap['userAccountInformation']['userAccountID'],
            username: jsonMap['userAccountInformation']['username'],
            name: jsonMap['userAccountInformation']['name'],
            createdAt: DateTime.parse(jsonMap['userAccountInformation']['createdAt']),
            level: jsonMap['userAccountInformation']['level'],
            profilePicture: jsonMap['userAccountInformation']['profilePicture'],
            bodyweight: jsonMap['userAccountInformation']['bodyweight'],
          ),
          gender: jsonMap['userAccountInformation']['gender'],
          bestLiftOverview: List.generate(
            jsonMap['bestLiftOverview'].length,
            (index) {
              final liftOverview = jsonMap['bestLiftOverview'][index];

              return BestLiftOverview(
                exerciseName: liftOverview['exerciseName'],
                repetitions: liftOverview['repetitions'],
                weight: liftOverview['weight'],
                duration: liftOverview['duration'],
              );
            },
          ),
        );

        emit(UserAccountLoaded(userAccountOverview: userAccountOverview));
      } else {
        emit(UserAccountError());
      }
    } else {
      emit(UserAccountError());
    }
  }
}

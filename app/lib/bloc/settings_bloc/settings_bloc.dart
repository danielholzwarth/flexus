import 'dart:convert';

import 'package:app/api/user_settings_service.dart';
import 'package:app/hive/user_settings.dart';
import 'package:chopper/chopper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final UserSettingsService _settingsService = UserSettingsService.create();
  final userBox = Hive.box('userBox');

  SettingsBloc() : super(SettingsInitial()) {
    on<LoadSettings>(_onLoadSettings);
  }

  void _onLoadSettings(LoadSettings event, Emitter<SettingsState> emit) async {
    emit(SettingsLoading());

    //simulate backend request delay
    await Future.delayed(const Duration(seconds: 1));

    Response<dynamic> response;
    response = await _settingsService.getUserSettings(userBox.get("flexusjwt"));

    if (response.isSuccessful) {
      if (response.bodyString != "null") {
        final Map<String, dynamic> jsonMap = jsonDecode(response.bodyString);

        final userSettings = UserSettings(
          id: jsonMap['id'],
          userAccountID: jsonMap['userAccountID'],
          fontSize: double.parse(jsonMap['fontSize'].toString()),
          isDarkMode: jsonMap['isDarkMode'],
          languageID: jsonMap['languageID'],
          isUnlisted: jsonMap['isUnlisted'],
          isPullFromEveryone: jsonMap['isPullFromEveryone'],
          pullUserListID: jsonMap['pullUserListID'],
          isNotifyEveryone: jsonMap['isNotifyEveryone'],
          notifyUserListID: jsonMap['notifyUserListID'],
        );

        userBox.put("userSettings", userSettings);

        emit(SettingsLoaded(userSettings: userSettings));
      } else {
        emit(SettingsError());
      }
    } else {
      emit(SettingsError());
    }
  }
}

import 'dart:convert';

import 'package:app/api/user_account_service.dart';
import 'package:app/api/user_settings_service.dart';
import 'package:app/hive/user_account.dart';
import 'package:app/hive/user_settings.dart';
import 'package:chopper/chopper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final UserSettingsService _settingsService = UserSettingsService.create();
  final UserAccountService _userAccountService = UserAccountService.create();

  final userBox = Hive.box('userBox');

  SettingsBloc() : super(SettingsInitial()) {
    on<LoadSettings>(_onLoadSettings);

    on<UpdateSettings>(_onUpdateSettings);
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

        emit(SettingsLoaded());
      } else {
        emit(SettingsError());
      }
    } else {
      emit(SettingsError());
    }
  }

  void _onUpdateSettings(UpdateSettings event, Emitter<SettingsState> emit) async {
    emit(SettingsUpdating());

    //simulate backend request delay
    await Future.delayed(const Duration(seconds: 1));

    UserAccount userAccount = userBox.get("userAccount");
    UserSettings userSettings = userBox.get("userSettings");

    switch (event.name) {
      //My Account
      case "name":
        print(event.value);
        final response = await _userAccountService.patchUserAccount(userBox.get("flexusjwt"), {"name": event.value});
        if (response.isSuccessful) {
          userAccount.name = event.value;
          userBox.put("userAccount", userAccount);
        }
        break;

      case "username":
        final response = await _userAccountService.patchUserAccount(userBox.get("flexusjwt"), {"username": event.value});
        if (response.isSuccessful) {
          userAccount.username = event.value;
          userBox.put("userAccount", userAccount);
        }
        break;

      case "password":
        await _userAccountService.patchUserAccount(userBox.get("flexusjwt"), {"password": event.value});
        break;

      //Appearance
      case "font_size":
        final response = await _settingsService.patchUserSettings(userBox.get("flexusjwt"), {"fontSize": event.value});
        if (response.isSuccessful) {
          userSettings.fontSize = event.value;
          userBox.put("userSettings", userSettings);
        }
        break;

      case "dark_mode":
        final response = await _settingsService.patchUserSettings(userBox.get("flexusjwt"), {"isDarkMode": event.value});
        if (response.isSuccessful) {
          userSettings.isDarkMode = event.value;
          userBox.put("userSettings", userSettings);
        }
        break;

      //Status

      //Data Storage

      default:
        emit(SettingsLoaded());
    }

    emit(SettingsLoaded());
  }
}

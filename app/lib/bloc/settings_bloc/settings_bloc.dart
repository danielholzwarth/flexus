import 'dart:convert';

import 'package:app/api/user_account_service.dart';
import 'package:app/api/user_settings_service.dart';
import 'package:app/hive/user_account.dart';
import 'package:app/hive/user_settings.dart';
import 'package:app/resources/app_settings.dart';
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
    on<GetSettings>(_onGetSettings);
    on<PatchSettings>(_onPatchSettings);
  }

  void _onGetSettings(GetSettings event, Emitter<SettingsState> emit) async {
    emit(SettingsLoading());

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
        emit(SettingsError(error: "No Settings found!"));
      }
    } else {
      emit(SettingsError(error: response.error.toString()));
    }
  }

  void _onPatchSettings(PatchSettings event, Emitter<SettingsState> emit) async {
    emit(SettingsUpdating());

    UserAccount userAccount = userBox.get("userAccount");
    UserSettings userSettings = userBox.get("userSettings");

    switch (event.name) {
      //My Account
      case "name":
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
        await _userAccountService.patchUserAccount(userBox.get("flexusjwt"), {"new_password": event.value, "old_password": event.value2});
        break;

      //Appearance
      case "fontSize":
        final response = await _settingsService.patchUserSettings(userBox.get("flexusjwt"), {"font_size": event.value});
        if (response.isSuccessful) {
          userSettings.fontSize = event.value;
          userBox.put("userSettings", userSettings);
          AppSettings.fontSize = event.value;
        }
        break;

      case "isDarkMode":
        final response = await _settingsService.patchUserSettings(userBox.get("flexusjwt"), {"is_dark_mode": event.value});
        if (response.isSuccessful) {
          userSettings.isDarkMode = event.value;
          userBox.put("userSettings", userSettings);
          AppSettings.isDarkMode = event.value;
        }
        break;

      //Status
      case "isUnlisted":
        final response = await _settingsService.patchUserSettings(userBox.get("flexusjwt"), {"is_unlisted": event.value});
        if (response.isSuccessful) {
          userSettings.isUnlisted = event.value;
          userBox.put("userSettings", userSettings);
        }
        break;

      case "isPullFromEveryone":
        final response = await _settingsService.patchUserSettings(userBox.get("flexusjwt"), {"is_pull_from_everyone": event.value});
        if (response.isSuccessful) {
          userSettings.isPullFromEveryone = event.value;
          userBox.put("userSettings", userSettings);
        }
        break;

      case "isNotifyEveryone":
        final response = await _settingsService.patchUserSettings(userBox.get("flexusjwt"), {"is_notify_everyone": event.value});
        if (response.isSuccessful) {
          userSettings.isNotifyEveryone = event.value;
          userBox.put("userSettings", userSettings);
        }
        break;

      default:
        emit(SettingsLoaded());
    }

    emit(SettingsLoaded());
  }
}

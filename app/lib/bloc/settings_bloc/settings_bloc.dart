import 'package:app/api/user_account/user_account_service.dart';
import 'package:app/api/user_settings/user_settings_service.dart';
import 'package:app/hive/user_account/user_account.dart';
import 'package:app/hive/user_settings/user_settings.dart';
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
    if (!AppSettings.hasConnection) {
      UserSettings userSettings = userBox.get("userSettings");
      emit(SettingsLoaded(userSettings: userSettings));
      return;
    }

    Response<dynamic> response = await _settingsService.getUserSettings(userBox.get("flexusjwt"));

    if (!response.isSuccessful) {
      emit(SettingsError(error: response.error.toString()));
      return;
    }

    if (response.body == "null") {
      emit(SettingsError(error: "No Settings found!"));
      return;
    }

    final Map<String, dynamic> jsonMap = response.body;
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
      isQuickAccess: jsonMap['isQuickAccess'],
    );

    userBox.put("userSettings", userSettings);

    emit(SettingsLoaded(userSettings: userSettings));
  }

  void _onPatchSettings(PatchSettings event, Emitter<SettingsState> emit) async {
    UserAccount userAccount = userBox.get("userAccount");
    UserSettings userSettings = userBox.get("userSettings");

    switch (event.name) {
      //My Account
      case "name":
        if (!AppSettings.hasConnection) {
          final response = await _userAccountService.patchUserAccount(userBox.get("flexusjwt"), {"name": event.value});
          if (response.isSuccessful) {
            userAccount.name = event.value;
            userBox.put("userAccount", userAccount);
          } else {
            emit(SettingsError(error: response.error.toString()));
          }
        } else {
          userAccount.name = event.value;
          userBox.put("userAccount", userAccount);
        }
        break;

      case "username":
        if (AppSettings.hasConnection) {
          final response = await _userAccountService.patchUserAccount(userBox.get("flexusjwt"), {"username": event.value});
          if (response.isSuccessful) {
            userAccount.username = event.value;
            userBox.put("userAccount", userAccount);
          } else {
            emit(SettingsError(error: response.error.toString()));
          }
        } else {
          userAccount.username = event.value;
          userBox.put("userAccount", userAccount);
        }

        break;

      case "password":
        final response =
            await _userAccountService.patchUserAccount(userBox.get("flexusjwt"), {"new_password": event.value, "old_password": event.value2});
        if (!response.isSuccessful) {
          emit(SettingsError(error: response.error.toString()));
        }
        break;

      //Appearance
      case "fontSize":
        if (AppSettings.hasConnection) {
          final response = await _settingsService.patchUserSettings(userBox.get("flexusjwt"), {"font_size": event.value});
          if (response.isSuccessful) {
            userSettings.fontSize = event.value;
            userBox.put("userSettings", userSettings);
            updateAppSettingsFontSizes(event.value);
          } else {
            emit(SettingsError(error: response.error.toString()));
          }
        } else {
          userSettings.fontSize = event.value;
          userBox.put("userSettings", userSettings);
          updateAppSettingsFontSizes(event.value);
        }

        break;

      case "isDarkMode":
        if (AppSettings.hasConnection) {
          final response = await _settingsService.patchUserSettings(userBox.get("flexusjwt"), {"is_dark_mode": event.value});
          if (response.isSuccessful) {
            userSettings.isDarkMode = event.value;
            userBox.put("userSettings", userSettings);
            AppSettings.isDarkMode = event.value;
          } else {
            emit(SettingsError(error: response.error.toString()));
          }
        } else {
          userSettings.isDarkMode = event.value;
          userBox.put("userSettings", userSettings);
          AppSettings.isDarkMode = event.value;
        }

        break;

      case "isUnlisted":
        if (AppSettings.hasConnection) {
          final response = await _settingsService.patchUserSettings(userBox.get("flexusjwt"), {"is_unlisted": event.value});
          if (response.isSuccessful) {
            userSettings.isUnlisted = event.value;
            userBox.put("userSettings", userSettings);
          } else {
            emit(SettingsError(error: response.error.toString()));
          }
        } else {
          userSettings.isUnlisted = event.value;
          userBox.put("userSettings", userSettings);
        }

        break;

      case "isPullFromEveryone":
        if (AppSettings.hasConnection) {
          final response = await _settingsService.patchUserSettings(userBox.get("flexusjwt"), {"is_pull_from_everyone": event.value});
          if (response.isSuccessful) {
            userSettings.isPullFromEveryone = event.value;
            userBox.put("userSettings", userSettings);
          } else {
            emit(SettingsError(error: response.error.toString()));
          }
        } else {
          userSettings.isPullFromEveryone = event.value;
          userBox.put("userSettings", userSettings);
        }

        break;

      case "isNotifyEveryone":
        if (AppSettings.hasConnection) {
          final response = await _settingsService.patchUserSettings(userBox.get("flexusjwt"), {"is_notify_everyone": event.value});
          if (response.isSuccessful) {
            userSettings.isNotifyEveryone = event.value;
            userBox.put("userSettings", userSettings);
          } else {
            emit(SettingsError(error: response.error.toString()));
          }
        } else {
          userSettings.isNotifyEveryone = event.value;
          userBox.put("userSettings", userSettings);
        }

        break;

      case "isQuickAccess":
        if (AppSettings.hasConnection) {
          final response = await _settingsService.patchUserSettings(userBox.get("flexusjwt"), {"is_quick_access": event.value});
          if (response.isSuccessful) {
            userSettings.isQuickAccess = event.value;
            userBox.put("userSettings", userSettings);
          } else {
            emit(SettingsError(error: response.error.toString()));
          }
        } else {
          userSettings.isQuickAccess = event.value;
          userBox.put("userSettings", userSettings);
        }

        break;

      default:
        emit(SettingsLoaded(userSettings: userSettings));
    }

    emit(SettingsLoaded(userSettings: userSettings));
  }
}

void updateAppSettingsFontSizes(double newSize) {
  double oldFontSize = AppSettings.fontSize;
  AppSettings.fontSize = newSize;
  AppSettings.fontSizeBig = AppSettings.fontSizeBig / oldFontSize * newSize;
  AppSettings.fontSizeH1 = AppSettings.fontSizeH1 / oldFontSize * newSize;
  AppSettings.fontSizeH2 = AppSettings.fontSizeH2 / oldFontSize * newSize;
  AppSettings.fontSizeH3 = AppSettings.fontSizeH3 / oldFontSize * newSize;
  AppSettings.fontSizeH4 = AppSettings.fontSizeH4 / oldFontSize * newSize;
  AppSettings.fontSizeT2 = AppSettings.fontSizeT2 / oldFontSize * newSize;
  AppSettings.fontSizeT3 = AppSettings.fontSizeT3 / oldFontSize * newSize;
  AppSettings.fontSizeT4 = AppSettings.fontSizeT4 / oldFontSize * newSize;
}

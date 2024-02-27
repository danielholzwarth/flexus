part of 'settings_bloc.dart';

@immutable
abstract class SettingsState {}

class SettingsInitial extends SettingsState {}

class SettingsLoading extends SettingsState {}

class SettingsLoaded extends SettingsState {
  final UserSettings userSettings;

  SettingsLoaded({
    required this.userSettings,
  });
}

class SettingsError extends SettingsState {}

part of 'settings_bloc.dart';

@immutable
abstract class SettingsEvent {}

class LoadSettings extends SettingsEvent {}

class ChangeSettings extends SettingsEvent {
  final UserSettings userSettings;

  ChangeSettings({
    required this.userSettings,
  });
}

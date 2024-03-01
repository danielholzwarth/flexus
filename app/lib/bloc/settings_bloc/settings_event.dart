part of 'settings_bloc.dart';

@immutable
abstract class SettingsEvent {}

class LoadSettings extends SettingsEvent {}

class UpdateSettings extends SettingsEvent {
  final String name;
  final dynamic value;

  UpdateSettings({
    required this.name,
    required this.value,
  });
}

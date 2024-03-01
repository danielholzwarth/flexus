part of 'settings_bloc.dart';

@immutable
abstract class SettingsEvent {}

class LoadSettings extends SettingsEvent {}

class UpdateSettings extends SettingsEvent {
  final String name;
  final dynamic value;
  final dynamic value2;

  UpdateSettings({
    required this.name,
    required this.value,
    this.value2,
  });
}

part of 'settings_bloc.dart';

@immutable
abstract class SettingsEvent {}

class LoadSettings extends SettingsEvent {}

class PatchSettings extends SettingsEvent {
  final String name;
  final dynamic value;
  final dynamic value2;

  PatchSettings({
    required this.name,
    required this.value,
    this.value2,
  });
}

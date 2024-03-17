part of 'settings_bloc.dart';

@immutable
abstract class SettingsState {}

class SettingsInitial extends SettingsState {}

class SettingsLoading extends SettingsState {}

class SettingsLoaded extends SettingsState {}

class SettingsUpdated extends SettingsState {}

class SettingsError extends SettingsState {
  final String error;

  SettingsError({
    required this.error,
  });
}

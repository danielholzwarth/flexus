part of 'user_account_gym_bloc.dart';

@immutable
abstract class UserAccountGymState {}

class UserAccountGymInitial extends UserAccountGymState {}

class UserAccountGymCreating extends UserAccountGymState {}

class UserAccountGymCreated extends UserAccountGymState {}

class UserAccountGymDeleting extends UserAccountGymState {}

class UserAccountGymDeleted extends UserAccountGymState {}

class UserAccountGymError extends UserAccountGymState {
  final String error;

  UserAccountGymError({
    required this.error,
  });
}

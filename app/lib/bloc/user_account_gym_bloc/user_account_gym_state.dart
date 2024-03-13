part of 'user_account_gym_bloc.dart';

@immutable
abstract class UserAccountGymState {}

class UserAccountGymInitial extends UserAccountGymState {}

class UserAccountGymCreating extends UserAccountGymState {}

class UserAccountGymCreated extends UserAccountGymState {}

class UserAccountGymLoading extends UserAccountGymState {}

class UserAccountGymLoaded extends UserAccountGymState {
  final bool isExisting;

  UserAccountGymLoaded({
    required this.isExisting,
  });
}

class UserAccountGymDeleting extends UserAccountGymState {}

class UserAccountGymDeleted extends UserAccountGymState {}

class UserAccountGymError extends UserAccountGymState {
  final String error;

  UserAccountGymError({
    required this.error,
  });
}

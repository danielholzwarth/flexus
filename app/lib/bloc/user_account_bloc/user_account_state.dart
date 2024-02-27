part of 'user_account_bloc.dart';

@immutable
abstract class UserAccountState {}

class UserAccountInitial extends UserAccountState {}

class UserAccountLoading extends UserAccountState {}

class UserAccountLoaded extends UserAccountState {
  final UserAccount userAccount;

  UserAccountLoaded({
    required this.userAccount,
  });
}

class UserAccountUpdating extends UserAccountState {}

class UserAccountUpdated extends UserAccountState {}

class UserAccountError extends UserAccountState {}

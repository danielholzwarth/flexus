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

class UserAccountError extends UserAccountState {
  final String error;

  UserAccountError({
    required this.error,
  });
}

class UserAccountsLoading extends UserAccountState {}

class UserAccountsLoaded extends UserAccountState {
  final List<UserAccount> userAccounts;

  UserAccountsLoaded({
    required this.userAccounts,
  });
}

class UserAccountGymOverviewsLoaded extends UserAccountState {
  final List<UserAccountGymOverview> userAccountGymOverviews;

  UserAccountGymOverviewsLoaded({
    required this.userAccountGymOverviews,
  });
}

class UserAccountsError extends UserAccountState {
  final String error;

  UserAccountsError({
    required this.error,
  });
}

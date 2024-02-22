part of 'user_account_bloc.dart';

@immutable
abstract class UserAccountEvent {}

class LoadUserAccount extends UserAccountEvent {
  final int userAccountID;

  LoadUserAccount({
    required this.userAccountID,
  });
}

class ChangeUserAccount extends UserAccountEvent {
  final UserAccount userAccount;

  ChangeUserAccount({
    required this.userAccount,
  });
}

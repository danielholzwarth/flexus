part of 'user_account_bloc.dart';

@immutable
abstract class UserAccountEvent {}

class LoadUserAccount extends UserAccountEvent {
  final int userAccountID;

  LoadUserAccount({
    required this.userAccountID,
  });
}

class PutUserAccount extends UserAccountEvent {
  final UserAccount userAccount;

  PutUserAccount({
    required this.userAccount,
  });
}

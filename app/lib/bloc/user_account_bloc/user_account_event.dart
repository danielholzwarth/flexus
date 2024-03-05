part of 'user_account_bloc.dart';

@immutable
abstract class UserAccountEvent {}

class GetUserAccount extends UserAccountEvent {
  final int userAccountID;

  GetUserAccount({
    required this.userAccountID,
  });
}

class PatchUserAccount extends UserAccountEvent {
  final String name;
  final dynamic value;
  final dynamic value2;

  PatchUserAccount({
    required this.name,
    required this.value,
    this.value2,
  });
}

class GetUserAccounts extends UserAccountEvent {
  final String keyword;
  final bool isFriends;
  final int? gymID;

  GetUserAccounts({
    this.keyword = "",
    this.isFriends = false,
    this.gymID,
  });
}

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
  final bool? isFriend;
  final bool? hasRequest;
  final String? keyword;

  GetUserAccounts({
    this.isFriend,
    this.hasRequest,
    this.keyword,
  });
}

class GetUserAccountsGym extends UserAccountEvent {
  final int gymID;
  final bool? isWorkingOut;

  GetUserAccountsGym({
    required this.gymID,
    this.isWorkingOut,
  });
}

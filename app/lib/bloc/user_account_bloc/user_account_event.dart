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

class GetUserAccountsFriendsSearch extends UserAccountEvent {
  final bool? isFriend;
  final bool? hasRequest;
  final String? keyword;

  GetUserAccountsFriendsSearch({
    this.isFriend,
    this.hasRequest,
    this.keyword,
  });
}

class GetUserAccountsFriendsGym extends UserAccountEvent {
  final bool? isFriend;
  final int? gymID;
  final bool? isWorkingOut;

  GetUserAccountsFriendsGym({
    this.isFriend,
    this.gymID,
    this.isWorkingOut,
  });
}

part of 'user_account_bloc.dart';

@immutable
abstract class UserAccountEvent {}

class LoadUserAccount extends UserAccountEvent {
  final int userAccountID;

  LoadUserAccount({
    required this.userAccountID,
  });
}

class UpdateUserAccount extends UserAccountEvent {
  final String name;
  final dynamic value;
  final dynamic value2;

  UpdateUserAccount({
    required this.name,
    required this.value,
    this.value2,
  });
}

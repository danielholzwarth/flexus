part of 'user_list_bloc.dart';

@immutable
abstract class UserListState {}

class UserListInitial extends UserListState {}

class UserListCreating extends UserListState {}

class UserListCreated extends UserListState {
  final int listID;

  UserListCreated({
    required this.listID,
  });
}

class UserListLoading extends UserListState {}

class UserListLoaded extends UserListState {
  final bool isCreated;

  UserListLoaded({
    required this.isCreated,
  });
}

class UserListUpdating extends UserListState {}

class UserListUpdated extends UserListState {
  final bool isCreated;

  UserListUpdated({
    required this.isCreated,
  });
}

class UserListError extends UserListState {
  final String error;

  UserListError({
    required this.error,
  });
}

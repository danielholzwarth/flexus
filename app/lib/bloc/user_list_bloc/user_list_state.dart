part of 'user_list_bloc.dart';

@immutable
abstract class UserListState {}

class UserListInitial extends UserListState {}

class UserListCreated extends UserListState {
  final int listID;

  UserListCreated({
    required this.listID,
  });
}

class HasUserListLoading extends UserListState {}

class HasUserListLoaded extends UserListState {
  final bool isCreated;

  HasUserListLoaded({
    required this.isCreated,
  });
}

class UserListUpdated extends UserListState {
  final bool isCreated;

  UserListUpdated({
    required this.isCreated,
  });
}

class EntireUserListLoading extends UserListState {}

class EntireUserListLoaded extends UserListState {
  final List<int> userList;

  EntireUserListLoaded({
    required this.userList,
  });
}

class UserListError extends UserListState {
  final String error;

  UserListError({
    required this.error,
  });
}

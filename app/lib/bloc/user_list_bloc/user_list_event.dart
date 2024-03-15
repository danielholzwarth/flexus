part of 'user_list_bloc.dart';

@immutable
abstract class UserListEvent {}

class PostUserList extends UserListEvent {
  final String columnName;

  PostUserList({
    required this.columnName,
  });
}

class GetHasUserList extends UserListEvent {
  final int listID;
  final int userID;

  GetHasUserList({
    required this.listID,
    required this.userID,
  });
}

class PatchUserList extends UserListEvent {
  final bool isDeleting;
  final int listID;
  final int userID;

  PatchUserList({
    required this.isDeleting,
    required this.listID,
    required this.userID,
  });
}

class GetEntireUserList extends UserListEvent {
  final int listID;

  GetEntireUserList({
    required this.listID,
  });
}

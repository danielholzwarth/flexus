part of 'friendship_bloc.dart';

@immutable
abstract class FriendshipEvent {}

class PostFriendship extends FriendshipEvent {
  final int requestedID;

  PostFriendship({
    required this.requestedID,
  });
}

class GetFriendship extends FriendshipEvent {
  final int requestedID;

  GetFriendship({
    required this.requestedID,
  });
}

class PatchFriendship extends FriendshipEvent {
  final int requestedID;
  final String name;
  final dynamic value;

  PatchFriendship({
    required this.requestedID,
    required this.name,
    required this.value,
  });
}

class DeleteFriendship extends FriendshipEvent {
  final int requestedID;

  DeleteFriendship({
    required this.requestedID,
  });
}

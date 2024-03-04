part of 'friendship_bloc.dart';

@immutable
abstract class FriendshipEvent {}

class CreateFriendship extends FriendshipEvent {
  final int requestedID;

  CreateFriendship({
    required this.requestedID,
  });
}

class LoadFriendship extends FriendshipEvent {
  final int requestedID;

  LoadFriendship({
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

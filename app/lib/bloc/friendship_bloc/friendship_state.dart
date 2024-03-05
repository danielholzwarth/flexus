part of 'friendship_bloc.dart';

@immutable
abstract class FriendshipState {}

class FriendshipInitial extends FriendshipState {}

class FriendshipCreating extends FriendshipState {}

class FriendshipLoading extends FriendshipState {}

class FriendshipPatching extends FriendshipState {}

class FriendshipDeleting extends FriendshipState {}

class FriendshipLoaded extends FriendshipState {
  final Friendship? friendship;

  FriendshipLoaded({required this.friendship});
}

class FriendshipError extends FriendshipState {}

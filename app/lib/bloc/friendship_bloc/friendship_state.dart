part of 'friendship_bloc.dart';

@immutable
abstract class FriendshipState {}

class FriendshipInitial extends FriendshipState {}

class FriendshipLoading extends FriendshipState {}

class FriendshipLoaded extends FriendshipState {
  final Friendship? friendship;

  FriendshipLoaded({required this.friendship});
}

class FriendshipError extends FriendshipState {
  final String error;

  FriendshipError({
    required this.error,
  });
}

part of 'user_account_gym_bloc.dart';

@immutable
abstract class UserAccountGymEvent {}

class PostUserAccountGym extends UserAccountGymEvent {
  final int gymID;

  PostUserAccountGym({
    required this.gymID,
  });
}

class GetUserAccountGym extends UserAccountGymEvent {
  final int gymID;

  GetUserAccountGym({
    required this.gymID,
  });
}

class DeleteUserAccountGym extends UserAccountGymEvent {
  final int gymID;

  DeleteUserAccountGym({
    required this.gymID,
  });
}

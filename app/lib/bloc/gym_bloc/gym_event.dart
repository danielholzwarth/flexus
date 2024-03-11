part of 'gym_bloc.dart';

@immutable
abstract class GymEvent {}

class PostGym extends GymEvent {
  final Map<String, dynamic> locationData;

  PostGym({
    required this.locationData,
  });
}

class GetGymOverviews extends GymEvent {}

class DeleteGym extends GymEvent {
  final int gymID;

  DeleteGym({
    required this.gymID,
  });
}

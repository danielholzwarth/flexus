part of 'gym_bloc.dart';

@immutable
abstract class GymEvent {}

class PostGym extends GymEvent {
  final Map<String, dynamic> locationData;

  PostGym({
    required this.locationData,
  });
}

class GetGym extends GymEvent {
  final String name;
  final double lat;
  final double lon;

  GetGym({
    required this.name,
    required this.lat,
    required this.lon,
  });
}

class GetGymsSearch extends GymEvent {
  final String query;

  GetGymsSearch({
    required this.query,
  });
}

class GetGymOverviews extends GymEvent {}

class DeleteGym extends GymEvent {
  final int gymID;

  DeleteGym({
    required this.gymID,
  });
}

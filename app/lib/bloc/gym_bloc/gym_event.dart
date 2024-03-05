part of 'gym_bloc.dart';

@immutable
abstract class GymEvent {}

// class CreateGym extends GymEvent {
//   final String name;
//   final GeoPoint geoPoint;

//   CreateGym({
//     required this.name,
//     required this.geoPoint,
//   });
// }

// class GetGymOverview extends GymEvent {
//   final GeoPoint geoPoint;

//   GetGymOverview({
//     required this.geoPoint,
//   });
// }

// class DeleteGym extends GymEvent {
//   final GeoPoint geoPoint;

//   DeleteGym({
//     required this.geoPoint,
//   });
// }

class GetGymOverviews extends GymEvent {}

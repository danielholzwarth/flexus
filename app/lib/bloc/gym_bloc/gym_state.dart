part of 'gym_bloc.dart';

@immutable
abstract class GymState {}

class GymInitial extends GymState {}

class GymCreating extends GymState {}

class GymCreated extends GymState {
  final Gym gym;

  GymCreated({
    required this.gym,
  });
}

class GymsSearchLoading extends GymState {}

class GymsSearchLoaded extends GymState {
  final List<Gym> gyms;

  GymsSearchLoaded({
    required this.gyms,
  });
}

class GymOverviewsLoading extends GymState {}

class GymOverviewsLoaded extends GymState {
  final List<GymOverview> gymOverviews;

  GymOverviewsLoaded({
    required this.gymOverviews,
  });
}

class GymError extends GymState {
  final String error;

  GymError({
    required this.error,
  });
}

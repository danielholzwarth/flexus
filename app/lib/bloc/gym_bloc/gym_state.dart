part of 'gym_bloc.dart';

@immutable
abstract class GymState {}

class GymInitial extends GymState {}

class GymCreating extends GymState {}

class GymCreated extends GymState {}

class GymOverviewsLoading extends GymState {}

class GymOverviewsLoaded extends GymState {
  final List<GymOverview> gymOverviews;

  GymOverviewsLoaded({
    required this.gymOverviews,
  });
}

class GymError extends GymState {}

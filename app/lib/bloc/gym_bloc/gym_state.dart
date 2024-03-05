part of 'gym_bloc.dart';

@immutable
abstract class GymState {}

class GymInitial extends GymState {}

// class GymCreating extends GymState {}

// class GymCreated extends GymState {}

// class GymLoading extends GymState {}

// class GymLoaded extends GymState {}

// class GymDeleting extends GymState {}

// class GymDeleted extends GymState {}

// class GymOverviewLoaded extends GymState {
//   final GymOverview? gymOverview;

//   GymOverviewLoaded({
//     required this.gymOverview,
//   });
// }

class GymOverviewsLoading extends GymState {}

class GymOverviewsLoaded extends GymState {
  final List<GymOverview> gymOverviews;

  GymOverviewsLoaded({
    required this.gymOverviews,
  });
}

class GymError extends GymState {}

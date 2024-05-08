part of 'best_lifts_bloc.dart';

@immutable
abstract class BestLiftsState {}

class BestLiftsInitial extends BestLiftsState {}

class BestLiftPosting extends BestLiftsState {}

class BestLiftPosted extends BestLiftsState {
  final List<BestLiftOverview> bestLiftOverviews;

  BestLiftPosted({
    required this.bestLiftOverviews,
  });
}

class BestLiftPatching extends BestLiftsState {}

class BestLiftPatched extends BestLiftsState {
  final List<BestLiftOverview> bestLiftOverviews;

  BestLiftPatched({
    required this.bestLiftOverviews,
  });
}

class BestLiftsLoading extends BestLiftsState {}

class BestLiftsLoaded extends BestLiftsState {
  final List<BestLiftOverview> bestLiftOverviews;

  BestLiftsLoaded({
    required this.bestLiftOverviews,
  });
}

class BestLiftsError extends BestLiftsState {
  final String error;

  BestLiftsError({
    required this.error,
  });
}

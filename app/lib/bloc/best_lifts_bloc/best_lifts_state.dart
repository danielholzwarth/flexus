part of 'best_lifts_bloc.dart';

@immutable
abstract class BestLiftsState {}

class BestLiftsInitial extends BestLiftsState {}

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

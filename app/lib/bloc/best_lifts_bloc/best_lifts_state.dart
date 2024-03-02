part of 'best_lifts_bloc.dart';

@immutable
abstract class BestLiftsState {}

class BestLiftsInitial extends BestLiftsState {}

class BestLiftsLoading extends BestLiftsState {}

class BestLiftsLoaded extends BestLiftsState {
  final List<BestLiftOverview> bestLiftOverviews;

  BestLiftsLoaded({
    required this.bestLiftOverviews,
  });
}

class BestLiftsError extends BestLiftsState {}

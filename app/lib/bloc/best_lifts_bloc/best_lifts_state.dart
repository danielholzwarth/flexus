part of 'best_lifts_bloc.dart';

@immutable
abstract class BestLiftsState {}

class BestLiftsInitial extends BestLiftsState {}

class BestLiftsLoading extends BestLiftsState {}

class BestLiftsLoaded extends BestLiftsState {}

class BestLiftsError extends BestLiftsState {}

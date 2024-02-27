part of 'best_lifts_bloc.dart';

@immutable
abstract class BestLiftsEvent {}

class LoadBestLifts extends BestLiftsEvent {
  final int userAccountID;

  LoadBestLifts({
    required this.userAccountID,
  });
}

class ChangeBestLifts extends BestLiftsEvent {
  final BestLiftOverview bestLiftOverview;

  ChangeBestLifts({
    required this.bestLiftOverview,
  });
}

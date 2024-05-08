part of 'best_lifts_bloc.dart';

@immutable
abstract class BestLiftsEvent {}

class PostBestLift extends BestLiftsEvent {
  final int position;
  final int exerciseID;

  PostBestLift({
    required this.position,
    required this.exerciseID,
  });
}

class PatchBestLift extends BestLiftsEvent {
  final int position;
  final int exerciseID;

  PatchBestLift({
    required this.position,
    required this.exerciseID,
  });
}

class GetBestLifts extends BestLiftsEvent {
  final int userAccountID;

  GetBestLifts({
    required this.userAccountID,
  });
}

part of 'best_lifts_bloc.dart';

@immutable
abstract class BestLiftsEvent {}

class GetBestLifts extends BestLiftsEvent {
  final int userAccountID;

  GetBestLifts({
    required this.userAccountID,
  });
}

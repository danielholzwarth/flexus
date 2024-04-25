part of 'split_bloc.dart';

@immutable
abstract class SplitEvent {}

class GetSplits extends SplitEvent {
  final int planID;

  GetSplits({
    required this.planID,
  });
}

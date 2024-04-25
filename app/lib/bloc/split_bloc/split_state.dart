part of 'split_bloc.dart';

@immutable
abstract class SplitState {}

class SplitInitial extends SplitState {}

class SplitsLoading extends SplitState {}

class SplitsLoaded extends SplitState {
  final List<Split> splits;

  SplitsLoaded({
    required this.splits,
  });
}

class SplitError extends SplitState {
  final String error;

  SplitError({
    required this.error,
  });
}

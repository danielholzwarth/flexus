part of 'initialization_bloc.dart';

@immutable
abstract class InitializationState {}

class InitializationInitial extends InitializationState {}

class Initializing extends InitializationState {}

class Initialized extends InitializationState {}

class InitializingError extends InitializationState {
  final String error;

  InitializingError({
    required this.error,
  });
}

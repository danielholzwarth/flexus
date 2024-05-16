part of 'statistic_bloc.dart';

@immutable
abstract class StatisticState {}

class StatisticInitial extends StatisticState {}

class StatisticLoading extends StatisticState {}

class StatisticLoaded extends StatisticState {}

class StatisticError extends StatisticState {
  final String error;

  StatisticError({
    required this.error,
  });
}

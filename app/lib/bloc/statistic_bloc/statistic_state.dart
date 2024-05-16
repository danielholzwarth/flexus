part of 'statistic_bloc.dart';

@immutable
abstract class StatisticState {}

class StatisticInitial extends StatisticState {}

class StatisticLoading extends StatisticState {}

class StatisticLoaded extends StatisticState {
  final List<Map<String, dynamic>> values;

  StatisticLoaded({
    required this.values,
  });
}

class StatisticError extends StatisticState {
  final String error;

  StatisticError({
    required this.error,
  });
}

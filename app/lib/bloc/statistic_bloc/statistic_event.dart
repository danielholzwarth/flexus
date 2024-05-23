part of 'statistic_bloc.dart';

@immutable
abstract class StatisticEvent {}

class GetStatistic extends StatisticEvent {
  final String title;
  final int period;

  GetStatistic({
    required this.title,
    required this.period,
  });
}

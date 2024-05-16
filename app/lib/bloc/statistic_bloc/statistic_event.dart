part of 'statistic_bloc.dart';

@immutable
abstract class StatisticEvent {}

class GetStatistic extends StatisticEvent {
  final String title;
  final int diagramType;
  final int periodInDays;

  GetStatistic({
    required this.title,
    required this.diagramType,
    required this.periodInDays,
  });
}

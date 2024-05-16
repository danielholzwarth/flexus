import 'package:hive/hive.dart';

part 'statistic.g.dart';

@HiveType(typeId: 24)
class Statistic extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  String labelX;

  @HiveField(2)
  String labelY;

  //0 - Pie, 1 - Bar, 2 - Line, 3 - Radar
  @HiveField(3)
  int diagramType;

  Statistic({
    required this.title,
    required this.labelX,
    required this.labelY,
    required this.diagramType,
  });
}

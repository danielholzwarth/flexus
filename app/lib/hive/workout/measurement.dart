import 'package:hive/hive.dart';

part 'measurement.g.dart';

@HiveType(typeId: 18)
class Measurement extends HiveObject {
  @HiveField(0)
  int repetitions;

  @HiveField(1)
  double workload;

  Measurement({
    required this.repetitions,
    required this.workload,
  });
}

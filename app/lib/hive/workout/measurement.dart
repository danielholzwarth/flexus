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

  Map<String, dynamic> toJson() {
    return {
      'repetitions': repetitions,
      'workload': workload,
    };
  }

  Measurement.fromJson(Map<String, dynamic> json)
      : repetitions = json['repetitions'] as int,
        workload = double.parse(json['workload'].toString());
}

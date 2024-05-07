import 'package:hive/hive.dart';

part 'timer_value.g.dart';

@HiveType(typeId: 23)
class TimerValue extends HiveObject {
  @HiveField(0)
  bool isRunning;

  @HiveField(1)
  int milliseconds;

  TimerValue({
    required this.isRunning,
    required this.milliseconds,
  });
}

import 'package:hive/hive.dart';

part 'plan.g.dart';

@HiveType(typeId: 12)
class Plan extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  int userID;

  @HiveField(2)
  int splitCount;

  @HiveField(3)
  String name;

  @HiveField(4)
  DateTime startDate;

  @HiveField(5)
  bool isWeekly;

  @HiveField(6)
  bool isMondayRest;

  @HiveField(7)
  bool isTuesdayRest;

  @HiveField(8)
  bool isWednesdayRest;

  @HiveField(9)
  bool isThursdayRest;

  @HiveField(10)
  bool isFridayRest;

  @HiveField(11)
  bool isSaturdayRest;

  @HiveField(12)
  bool isSundayRest;

  Plan({
    required this.id,
    required this.userID,
    required this.splitCount,
    required this.name,
    required this.startDate,
    required this.isWeekly,
    required this.isMondayRest,
    required this.isTuesdayRest,
    required this.isWednesdayRest,
    required this.isThursdayRest,
    required this.isFridayRest,
    required this.isSaturdayRest,
    required this.isSundayRest,
  });
}

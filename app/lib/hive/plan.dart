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
  DateTime createdAt;

  @HiveField(5)
  bool isActive;

  @HiveField(6)
  bool isWeekly;

  @HiveField(7)
  List<bool>? restList;

  Plan({
    required this.id,
    required this.userID,
    required this.splitCount,
    required this.name,
    required this.createdAt,
    required this.isActive,
    required this.isWeekly,
    this.restList,
  });
}

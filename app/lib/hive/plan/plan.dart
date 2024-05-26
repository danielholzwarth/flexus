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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userID': userID,
      'splitCount': splitCount,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive,
      'isWeekly': isWeekly,
      'restList': restList ?? [],
    };
  }

  Plan.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int,
        userID = json['userAccountID'] as int,
        splitCount = json['splitCount'] as int,
        name = json['name'] as String,
        createdAt = DateTime.parse(json['createdAt']),
        isActive = json['isActive'] as bool,
        isWeekly = json['isWeekly'] as bool,
        restList = [
          json['isMondayRest'],
          json['isTuesdayRest'],
          json['isWednesdayRest'],
          json['isThursdayRest'],
          json['isFridayRest'],
          json['isSaturdayRest'],
          json['isSundayRest'],
        ];
}

import 'package:hive/hive.dart';

part 'split.g.dart';

@HiveType(typeId: 15)
class Split extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  int planID;

  @HiveField(2)
  String name;

  @HiveField(3)
  int orderInPlan;

  Split({
    required this.id,
    required this.planID,
    required this.name,
    required this.orderInPlan,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'planID': planID,
      'name': name,
      'orderInPlan': orderInPlan,
    };
  }
}

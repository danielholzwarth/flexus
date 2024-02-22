import 'package:hive/hive.dart';

part 'best_lift.g.dart';

@HiveType(typeId: 5)
class BestLift extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  int userID;

  @HiveField(2)
  int setID;

  @HiveField(3)
  int positionID;

  BestLift({
    required this.id,
    required this.userID,
    required this.setID,
    required this.positionID,
  });
}

import 'package:hive/hive.dart';

part 'exercise.g.dart';

@HiveType(typeId: 10)
class Exercise extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  int? creatorID;

  @HiveField(2)
  String name;

  @HiveField(3)
  int typeID;

  Exercise({
    required this.id,
    this.creatorID,
    required this.name,
    required this.typeID,
  });
}

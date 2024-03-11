import 'package:hive/hive.dart';

part 'gym.g.dart';

@HiveType(typeId: 7)
class Gym extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String displayName;

  @HiveField(3)
  double latitude;

  @HiveField(4)
  double longitude;

  Gym({
    required this.id,
    required this.name,
    required this.displayName,
    required this.latitude,
    required this.longitude,
  });
}

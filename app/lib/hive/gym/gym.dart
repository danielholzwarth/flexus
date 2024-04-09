import 'package:hive/hive.dart';

part 'gym.g.dart';

@HiveType(typeId: 7)
class Gym extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String streetName;

  @HiveField(3)
  String houseNumber;

  @HiveField(4)
  String zipCode;

  @HiveField(5)
  String cityName;

  @HiveField(6)
  double latitude;

  @HiveField(7)
  double longitude;

  Gym({
    required this.id,
    required this.name,
    required this.streetName,
    required this.houseNumber,
    required this.zipCode,
    required this.cityName,
    required this.latitude,
    required this.longitude,
  });
}

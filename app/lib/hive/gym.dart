import 'package:hive/hive.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

part 'gym.g.dart';

@HiveType(typeId: 7)
class Gym extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String country;

  @HiveField(3)
  String cityName;

  @HiveField(4)
  String zipCode;

  @HiveField(5)
  String streetName;

  @HiveField(6)
  String houseNumber;

  @HiveField(7)
  double latitude;

  @HiveField(8)
  double longitude;

  Gym({
    required this.id,
    required this.name,
    required this.country,
    required this.cityName,
    required this.zipCode,
    required this.streetName,
    required this.houseNumber,
    required this.latitude,
    required this.longitude,
  });
}

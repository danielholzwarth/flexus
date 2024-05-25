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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'streetName': streetName,
      'houseNumber': houseNumber,
      'zipCode': zipCode,
      'cityName': cityName,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  Gym.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int,
        name = json['name'] as String,
        streetName = json['streetName'] as String,
        houseNumber = json['houseNumber'] as String,
        zipCode = json['zipCode'] as String,
        cityName = json['cityName'] as String,
        latitude = double.parse(json['latitude'].toString()),
        longitude = double.parse(json['longitude'].toString());
}

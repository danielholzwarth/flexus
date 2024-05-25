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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'creatorID': creatorID,
      'name': name,
      'typeID': typeID,
    };
  }

  Exercise.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int,
        creatorID = json['creatorID'] as int?,
        name = json['name'] as String,
        typeID = json['typeID'] as int;
}

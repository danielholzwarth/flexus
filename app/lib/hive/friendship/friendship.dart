import 'package:hive/hive.dart';

part 'friendship.g.dart';

@HiveType(typeId: 4)
class Friendship extends HiveObject {
  @HiveField(0)
  int requestorID;

  @HiveField(1)
  int requestedID;

  @HiveField(2)
  bool isAccepted;

  Friendship({
    required this.requestorID,
    required this.requestedID,
    required this.isAccepted,
  });

  Friendship.fromJson(Map<String, dynamic> json)
      : requestorID = json['requestorID'] as int,
        requestedID = json['requestedID'] as int,
        isAccepted = json['isAccepted'] as bool;
}

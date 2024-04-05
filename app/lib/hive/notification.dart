import 'package:hive/hive.dart';

part 'notification.g.dart';

@HiveType(typeId: 13)
class Notification extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  String body;

  @HiveField(2)
  String payload;

  Notification({
    required this.title,
    required this.body,
    required this.payload,
  });
}

import 'package:hive/hive.dart';

part 'user_list.g.dart';

@HiveType(typeId: 11)
class UserList extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  int listID;

  @HiveField(2)
  List<int> memberIDs;

  UserList({
    required this.id,
    required this.listID,
    required this.memberIDs,
  });
}

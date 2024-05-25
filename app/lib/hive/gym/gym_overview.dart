import 'package:app/hive/gym/gym.dart';
import 'package:app/hive/user_account/user_account.dart';
import 'package:hive/hive.dart';

part 'gym_overview.g.dart';

@HiveType(typeId: 8)
class GymOverview extends HiveObject {
  @HiveField(0)
  Gym gym;

  @HiveField(1)
  List<UserAccount> userAccounts;

  @HiveField(2)
  int totalFriends;

  GymOverview({
    required this.gym,
    required this.userAccounts,
    required this.totalFriends,
  });

  GymOverview.fromJson(Map<String, dynamic> json)
      : gym = Gym.fromJson(json['gym']),
        userAccounts = json['currentUserAccounts'] != null
            ? List<UserAccount>.from(json['currentUserAccounts'].map((userAccountsJson) {
                return UserAccount.fromJson(userAccountsJson);
              }))
            : [],
        totalFriends = json['totalFriends'] as int;
}

import 'package:app/hive/best_lift_overview.dart';
import 'package:app/hive/user_account.dart';
import 'package:hive/hive.dart';

part 'user_account_overview.g.dart';

@HiveType(typeId: 4)
class UserAccountOverview extends HiveObject {
  @HiveField(0)
  UserAccount userAccount;

  @HiveField(1)
  String? gender;

  @HiveField(2)
  List<BestLiftOverview>? bestLiftOverview;

  UserAccountOverview({
    required this.userAccount,
    this.gender,
    this.bestLiftOverview,
  });
}

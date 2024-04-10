import 'package:app/hive/user_account_gym/user_account_gym_overview.dart';
import 'package:app/pages/profile/profile.dart';
import 'package:app/resources/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';

class FlexusUserAccountGymListTile extends StatelessWidget {
  final UserAccountGymOverview userAccountGymOverview;

  const FlexusUserAccountGymListTile({
    super.key,
    required this.userAccountGymOverview,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageTransition(
            type: PageTransitionType.fade,
            child: ProfilePage(userID: userAccountGymOverview.id),
          ),
        );
      },
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: AppSettings.fontSize),
        tileColor: AppSettings.background,
        leading: buildPicture(context),
        title: Text(userAccountGymOverview.name),
        trailing: buildTrailing(context),
        subtitle: Text("@${userAccountGymOverview.username}"),
      ),
    );
  }

  Widget buildTrailing(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          "Start: ${DateFormat('hh:mm').format(userAccountGymOverview.workoutStartTime)}",
          style: TextStyle(
            fontSize: AppSettings.fontSize,
            color: AppSettings.font,
          ),
        ),
        Text(
          "Avg: ${userAccountGymOverview.averageWorkoutDuration!.inMinutes.toString()} min",
          style: TextStyle(
            fontSize: AppSettings.fontSizeT2,
            color: AppSettings.font,
          ),
        ),
      ],
    );
  }

  Widget buildPicture(BuildContext context) {
    return userAccountGymOverview.profilePicture != null
        ? CircleAvatar(
            radius: AppSettings.fontSizeH3,
            backgroundColor: AppSettings.primaryShade48,
            backgroundImage: MemoryImage(userAccountGymOverview.profilePicture!),
          )
        : Icon(
            Icons.person,
            size: AppSettings.fontSizeH3,
          );
  }
}

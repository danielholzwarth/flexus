import 'package:app/hive/user_account_gym/user_account_gym_overview.dart';
import 'package:app/pages/profile/profile.dart';
import 'package:app/resources/app_settings.dart';
import 'package:app/widgets/style/flexus_default_icon.dart';
import 'package:app/widgets/style/flexus_default_text_style.dart';
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
        title: CustomDefaultTextStyle(text: userAccountGymOverview.name),
        trailing: buildTrailing(context),
        subtitle: CustomDefaultTextStyle(text: "@${userAccountGymOverview.username}"),
      ),
    );
  }

  Widget buildTrailing(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        CustomDefaultTextStyle(
          text: "Start: ${DateFormat('hh:mm').format(userAccountGymOverview.workoutStartTime)}",
        ),
        CustomDefaultTextStyle(
          text: "Avg: ${userAccountGymOverview.averageWorkoutDuration!.inMinutes.toString()} min",
          fontSize: AppSettings.fontSizeT2,
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
        : const FlexusDefaultIcon(iconData: Icons.person);
  }
}

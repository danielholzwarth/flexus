import 'package:app/hive/gym_overview.dart';
import 'package:app/hive/user_account.dart';
import 'package:app/pages/home/profile.dart';
import 'package:app/resources/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

class FlexusGymOverviewListTile extends StatefulWidget {
  final GymOverview gymOverview;

  const FlexusGymOverviewListTile({
    super.key,
    required this.gymOverview,
  });

  @override
  State<FlexusGymOverviewListTile> createState() => _FlexusGymOverviewListTileState();
}

class _FlexusGymOverviewListTileState extends State<FlexusGymOverviewListTile> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: AppSettings.fontSize),
      tileColor: AppSettings.background,
      leading: buildLeading(context),
      title: Text(widget.gymOverview.gym.name),
      trailing: GestureDetector(
          onTap: () {
            debugPrint("asd");
          },
          child: Container(
            child: buildTrailing(context),
          )),
      subtitle: buildSubTitle(),
    );
  }

  Text buildSubTitle() {
    return Text(
      "${widget.gymOverview.gym.streetName} ${widget.gymOverview.gym.houseNumber}, ${widget.gymOverview.gym.cityName}\n${widget.gymOverview.gym.country}",
      style: TextStyle(fontSize: AppSettings.fontSizeDescription),
    );
  }

  Widget buildTrailing(BuildContext context) {
    if (widget.gymOverview.userAccounts.isNotEmpty) {
      List<UserAccount> userAccounts = widget.gymOverview.userAccounts;
      switch (userAccounts.length) {
        case 1:
          return SizedBox(
            width: 100,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(right: 0, child: buildCorrectUserPicture(userAccounts[0], 0)),
              ],
            ),
          );

        case 2:
          return SizedBox(
            width: 100,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(right: 20, child: buildCorrectUserPicture(userAccounts[0], 0)),
                Positioned(right: 0, child: buildCorrectUserPicture(userAccounts[1], 1)),
              ],
            ),
          );

        case 3:
          return SizedBox(
            width: 100,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(right: 40, child: buildCorrectUserPicture(userAccounts[0], 0)),
                Positioned(right: 20, child: buildCorrectUserPicture(userAccounts[1], 1)),
                Positioned(right: 0, child: buildCorrectUserPicture(userAccounts[2], 2)),
              ],
            ),
          );

        case 4:
          return SizedBox(
            width: 100,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(right: 60, child: buildCorrectUserPicture(userAccounts[0], 0)),
                Positioned(right: 40, child: buildCorrectUserPicture(userAccounts[1], 1)),
                Positioned(right: 20, child: buildCorrectUserPicture(userAccounts[2], 2)),
                Positioned(right: 0, child: buildCorrectUserPicture(userAccounts[3], 3)),
              ],
            ),
          );

        case > 4:
          return SizedBox(
            width: 100,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(right: 60, child: buildCorrectUserPicture(userAccounts[0], 0)),
                Positioned(right: 40, child: buildCorrectUserPicture(userAccounts[1], 1)),
                Positioned(right: 20, child: buildCorrectUserPicture(userAccounts[2], 2)),
                Positioned(
                  right: 0,
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.grey.shade100,
                    child: Text("+${userAccounts.length - 3}"),
                  ),
                ),
              ],
            ),
          );

        default:
          return Text("error ${userAccounts.length}");
      }
    } else {
      return const SizedBox(width: 100);
    }
  }

  Widget buildCorrectUserPicture(UserAccount userAccount, int element) {
    return userAccount.profilePicture != null
        ? GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                PageTransition(
                  type: PageTransitionType.fade,
                  child: ProfilePage(userID: userAccount.id),
                ),
              );
            },
            child: CircleAvatar(
              radius: AppSettings.fontSizeTitle,
              backgroundColor: AppSettings.primaryShade48,
              backgroundImage: MemoryImage(userAccount.profilePicture!),
            ),
          )
        : Container(
            width: 40,
            decoration: BoxDecoration(
              color: getCorrectShade(element),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                Icons.person,
                size: AppSettings.fontSizeTitle,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  PageTransition(
                    type: PageTransitionType.fade,
                    child: ProfilePage(userID: userAccount.id),
                  ),
                );
              },
            ),
          );
  }

  Color getCorrectShade(int element) {
    if (element == 0) {
      return Colors.grey.shade400;
    } else if (element == 1) {
      return Colors.grey.shade300;
    } else {
      return Colors.grey.shade200;
    }
  }

  Widget buildLeading(BuildContext context) {
    return CircleAvatar(
      radius: AppSettings.fontSizeTitle,
      backgroundColor: AppSettings.primaryShade48,
      child: Text(
        widget.gymOverview.gym.name.substring(0, 2).toUpperCase(),
        style: TextStyle(
          fontSize: AppSettings.fontSizeTitleSmall,
          color: AppSettings.font,
        ),
      ),
    );
  }
}

import 'package:app/bloc/user_account_bloc/user_account_bloc.dart';
import 'package:app/hive/gym_overview.dart';
import 'package:app/hive/user_account.dart';
import 'package:app/resources/app_settings.dart';
import 'package:app/widgets/list_tiles/flexus_user_account_gym_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
  final UserAccountBloc userAccountBloc = UserAccountBloc();

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        showPopUp();
      },
      contentPadding: EdgeInsets.symmetric(horizontal: AppSettings.fontSize),
      tileColor: AppSettings.background,
      leading: buildLeading(context),
      title: Text(widget.gymOverview.gym.name),
      trailing: GestureDetector(
        child: Container(
          child: buildTrailing(context),
        ),
      ),
      subtitle: buildSubTitle(),
    );
  }

  void showPopUp() {
    userAccountBloc.add(GetUserAccountsFriendsGym(isFriend: true, gymID: widget.gymOverview.gym.id, isWorkingOut: true));
    showModalBottomSheet(
      backgroundColor: AppSettings.background,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(40.0),
                child: Column(
                  children: [
                    Text(
                      widget.gymOverview.totalFriends > 0
                          ? "${widget.gymOverview.gym.name} ${widget.gymOverview.userAccounts.length}/${widget.gymOverview.totalFriends}"
                          : widget.gymOverview.gym.name,
                      style: TextStyle(
                        fontSize: AppSettings.fontSizeTitleSmall,
                        color: AppSettings.font,
                      ),
                    ),
                    BlocBuilder(
                      bloc: userAccountBloc,
                      builder: (context, state) {
                        if (state is UserAccountsLoading) {
                          return Expanded(child: Center(child: CircularProgressIndicator(color: AppSettings.primary)));
                        } else if (state is UserAccountGymOverviewsLoaded) {
                          if (state.userAccountGymOverviews.isNotEmpty) {
                            return Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 20),
                                child: ListView(
                                  children: [
                                    ...state.userAccountGymOverviews.map(
                                      (userAccountGymOverview) => FlexusUserAccountGymListTile(
                                        userAccountGymOverview: userAccountGymOverview,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          } else {
                            return Expanded(
                              child: Center(
                                child: Text(
                                  'No users training right now',
                                  style: TextStyle(fontSize: AppSettings.fontSize),
                                ),
                              ),
                            );
                          }
                        } else if (state is UserAccountsError) {
                          return Center(
                            child: Text(
                              'Error loading workouts',
                              style: TextStyle(fontSize: AppSettings.fontSize),
                            ),
                          );
                        } else {
                          return Center(
                            child: Text(
                              'Error XYZ',
                              style: TextStyle(fontSize: AppSettings.fontSize),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
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
            width: 125,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(right: 0, child: buildCorrectUserPicture(userAccounts[0], 0)),
              ],
            ),
          );

        case 2:
          return SizedBox(
            width: 125,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(right: 25, child: buildCorrectUserPicture(userAccounts[0], 0)),
                Positioned(right: 0, child: buildCorrectUserPicture(userAccounts[1], 1)),
              ],
            ),
          );

        case 3:
          return SizedBox(
            width: 125,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(right: 50, child: buildCorrectUserPicture(userAccounts[0], 0)),
                Positioned(right: 25, child: buildCorrectUserPicture(userAccounts[1], 1)),
                Positioned(right: 0, child: buildCorrectUserPicture(userAccounts[2], 2)),
              ],
            ),
          );

        case 4:
          return SizedBox(
            width: 125,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(right: 75, child: buildCorrectUserPicture(userAccounts[0], 0)),
                Positioned(right: 50, child: buildCorrectUserPicture(userAccounts[1], 1)),
                Positioned(right: 25, child: buildCorrectUserPicture(userAccounts[2], 2)),
                Positioned(right: 0, child: buildCorrectUserPicture(userAccounts[3], 3)),
              ],
            ),
          );

        case > 4:
          return SizedBox(
            width: 125,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(right: 75, child: buildCorrectUserPicture(userAccounts[0], 0)),
                Positioned(right: 50, child: buildCorrectUserPicture(userAccounts[1], 1)),
                Positioned(right: 25, child: buildCorrectUserPicture(userAccounts[2], 2)),
                Positioned(
                  right: 0,
                  child: CircleAvatar(
                    radius: AppSettings.fontSizeTitle,
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
      return const SizedBox(width: 120);
    }
  }

  Widget buildCorrectUserPicture(UserAccount userAccount, int element) {
    return userAccount.profilePicture != null
        ? CircleAvatar(
            radius: AppSettings.fontSizeTitle,
            backgroundColor: AppSettings.primaryShade48,
            backgroundImage: MemoryImage(userAccount.profilePicture!),
          )
        : Container(
            padding: EdgeInsets.all(AppSettings.fontSizeTitle / 2),
            width: AppSettings.fontSizeTitle * 2,
            decoration: BoxDecoration(
              color: getCorrectShade(element),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person,
              size: AppSettings.fontSizeTitle,
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

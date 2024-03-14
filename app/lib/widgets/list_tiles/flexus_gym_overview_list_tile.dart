import 'package:app/bloc/user_account_bloc/user_account_bloc.dart';
import 'package:app/bloc/user_account_gym_bloc/user_account_gym_bloc.dart';
import 'package:app/hive/gym_overview.dart';
import 'package:app/hive/user_account.dart';
import 'package:app/resources/app_settings.dart';
import 'package:app/widgets/flexus_scrollbar.dart';
import 'package:app/widgets/list_tiles/flexus_user_account_gym_list_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hive/hive.dart';
import 'package:url_launcher/url_launcher.dart';

class FlexusGymOverviewListTile extends StatefulWidget {
  final GymOverview gymOverview;
  final Function func;

  const FlexusGymOverviewListTile({
    super.key,
    required this.gymOverview,
    required this.func,
  });

  @override
  State<FlexusGymOverviewListTile> createState() => _FlexusGymOverviewListTileState();
}

class _FlexusGymOverviewListTileState extends State<FlexusGymOverviewListTile> {
  final UserAccountBloc userAccountBloc = UserAccountBloc();
  final userBox = Hive.box("userBox");
  bool refresh = false;

  @override
  Widget build(BuildContext context) {
    String name = userBox.get("customGymName${widget.gymOverview.gym.id}") ?? widget.gymOverview.gym.name;

    return Slidable(
      endActionPane: ActionPane(
        motion: const StretchMotion(),
        extentRatio: 0.25,
        children: [
          SlidableAction(
            backgroundColor: AppSettings.primary,
            icon: Icons.edit,
            label: "Edit",
            foregroundColor: AppSettings.fontV1,
            onPressed: (context) async {
              await showCupertinoDialog(
                context: context,
                builder: (context) {
                  return StatefulBuilder(
                    builder: (BuildContext context, StateSetter setState) {
                      TextEditingController textEditingController = TextEditingController();
                      return AlertDialog(
                        backgroundColor: AppSettings.background,
                        surfaceTintColor: AppSettings.background,
                        content: TextField(
                          controller: textEditingController,
                          autofocus: true,
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            hintText: widget.gymOverview.gym.name,
                            border: InputBorder.none,
                            hintStyle: TextStyle(color: AppSettings.font),
                          ),
                        ),
                        actions: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ElevatedButton(
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(AppSettings.background),
                                  surfaceTintColor: MaterialStateProperty.all(AppSettings.background),
                                  overlayColor: MaterialStateProperty.all(AppSettings.error.withOpacity(0.2)),
                                  foregroundColor: MaterialStateProperty.all(AppSettings.error),
                                  fixedSize: MaterialStateProperty.all(Size.fromWidth(AppSettings.screenWidth * 0.25)),
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(AppSettings.background),
                                  surfaceTintColor: MaterialStateProperty.all(AppSettings.background),
                                  overlayColor: MaterialStateProperty.all(AppSettings.primaryShade48),
                                  foregroundColor: MaterialStateProperty.all(AppSettings.primary),
                                  fixedSize: MaterialStateProperty.all(Size.fromWidth(AppSettings.screenWidth * 0.25)),
                                ),
                                onPressed: () {
                                  if (textEditingController.text.isNotEmpty) {
                                    userBox.put("customGymName${widget.gymOverview.gym.id}", textEditingController.text);
                                  } else {
                                    userBox.delete("customGymName${widget.gymOverview.gym.id}");
                                  }

                                  Navigator.pop(context);
                                },
                                child: const Text('Confirm'),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  );
                },
              );
              setState(() {});
            },
          ),
        ],
      ),
      child: ListTile(
        onTap: () {
          showPopUp(name);
        },
        contentPadding: EdgeInsets.symmetric(horizontal: AppSettings.fontSize),
        tileColor: AppSettings.background,
        leading: buildLeading(context),
        title: Text(name),
        trailing: GestureDetector(
          child: Container(
            child: buildTrailing(context),
          ),
        ),
        subtitle: buildSubTitle(),
      ),
    );
  }

  void showPopUp(String name) {
    userAccountBloc.add(GetUserAccountsFriendsGym(isFriend: true, gymID: widget.gymOverview.gym.id, isWorkingOut: true));
    UserAccountGymBloc userAccountGymBloc = UserAccountGymBloc();

    showModalBottomSheet(
      backgroundColor: AppSettings.background,
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
              child: Container(
                color: AppSettings.background,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40.0),
                    child: Column(
                      children: [
                        Text(
                          widget.gymOverview.totalFriends > 0
                              ? "$name ${widget.gymOverview.userAccounts.length}/${widget.gymOverview.totalFriends}"
                              : name,
                          style: TextStyle(
                            fontSize: AppSettings.fontSizeTitle,
                            color: AppSettings.font,
                          ),
                        ),
                        BlocBuilder(
                          bloc: userAccountBloc,
                          builder: (context, state) {
                            if (state is UserAccountGymOverviewsLoaded) {
                              if (state.userAccountGymOverviews.isNotEmpty) {
                                ScrollController scrollController = ScrollController();
                                return Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey.shade300, width: 2),
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                                      child: FlexusScrollBar(
                                        scrollController: scrollController,
                                        child: ListView(
                                          controller: scrollController,
                                          children: [
                                            ...state.userAccountGymOverviews.map(
                                              (userAccountGymOverview) => FlexusUserAccountGymListTile(
                                                userAccountGymOverview: userAccountGymOverview,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
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
                                  'Error: ${state.error}',
                                  style: TextStyle(fontSize: AppSettings.fontSize),
                                ),
                              );
                            } else {
                              return Center(child: CircularProgressIndicator(color: AppSettings.primary));
                            }
                          },
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            BlocBuilder(
                              bloc: userAccountGymBloc,
                              builder: (context, state) {
                                if (state is UserAccountGymDeleting) {
                                  return ElevatedButton(
                                    style: ButtonStyle(
                                      backgroundColor: MaterialStateProperty.all(AppSettings.background),
                                      surfaceTintColor: MaterialStateProperty.all(AppSettings.background),
                                      overlayColor: MaterialStateProperty.all(AppSettings.error.withOpacity(0.2)),
                                      foregroundColor: MaterialStateProperty.all(AppSettings.error),
                                      fixedSize: MaterialStateProperty.all(Size.fromWidth(AppSettings.screenWidth * 0.4)),
                                    ),
                                    onPressed: () {},
                                    child: Center(child: CircularProgressIndicator(color: AppSettings.error)),
                                  );
                                } else if (state is UserAccountGymDeleted) {
                                  widget.func();

                                  return ElevatedButton(
                                    style: ButtonStyle(
                                      backgroundColor: MaterialStateProperty.all(AppSettings.background),
                                      surfaceTintColor: MaterialStateProperty.all(AppSettings.background),
                                      overlayColor: MaterialStateProperty.all(AppSettings.error.withOpacity(0.2)),
                                      foregroundColor: MaterialStateProperty.all(AppSettings.error),
                                      fixedSize: MaterialStateProperty.all(Size.fromWidth(AppSettings.screenWidth * 0.4)),
                                    ),
                                    onPressed: () {
                                      userAccountGymBloc.add(PostUserAccountGym(gymID: widget.gymOverview.gym.id));
                                    },
                                    child: Icon(Icons.check, color: AppSettings.error, size: AppSettings.fontSize),
                                  );
                                } else {
                                  return ElevatedButton(
                                    style: ButtonStyle(
                                      backgroundColor: MaterialStateProperty.all(AppSettings.background),
                                      surfaceTintColor: MaterialStateProperty.all(AppSettings.background),
                                      overlayColor: MaterialStateProperty.all(AppSettings.error.withOpacity(0.2)),
                                      foregroundColor: MaterialStateProperty.all(AppSettings.error),
                                      fixedSize: MaterialStateProperty.all(Size.fromWidth(AppSettings.screenWidth * 0.4)),
                                    ),
                                    onPressed: () {
                                      userAccountGymBloc.add(DeleteUserAccountGym(gymID: widget.gymOverview.gym.id));
                                    },
                                    child: const Text('Remove Gym'),
                                  );
                                }
                              },
                            ),
                            ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(AppSettings.background),
                                surfaceTintColor: MaterialStateProperty.all(AppSettings.background),
                                overlayColor: MaterialStateProperty.all(AppSettings.primaryShade48),
                                foregroundColor: MaterialStateProperty.all(AppSettings.primary),
                                fixedSize: MaterialStateProperty.all(Size.fromWidth(AppSettings.screenWidth * 0.4)),
                              ),
                              onPressed: () {
                                openMaps(widget.gymOverview.gym.latitude, widget.gymOverview.gym.longitude);
                              },
                              child: const Text('Open in Maps'),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> openMaps(double latitude, double longitude) async {
    Uri uri = Uri.parse('https://www.google.com/maps?q=$latitude,$longitude');
    await launchUrl(uri);
  }

  Widget buildSubTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${widget.gymOverview.gym.streetName} ${widget.gymOverview.gym.houseNumber}',
          style: TextStyle(fontSize: AppSettings.fontSizeDescription),
        ),
        Text(
          '${widget.gymOverview.gym.zipCode} ${widget.gymOverview.gym.cityName}',
          style: TextStyle(fontSize: AppSettings.fontSizeDescription),
        ),
      ],
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
        widget.gymOverview.gym.name.length > 2 ? widget.gymOverview.gym.name.substring(0, 2).toUpperCase() : widget.gymOverview.gym.name,
        style: TextStyle(
          fontSize: AppSettings.fontSizeTitleSmall,
          color: AppSettings.font,
        ),
      ),
    );
  }
}

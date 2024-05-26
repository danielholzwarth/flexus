import 'package:app/bloc/user_account_bloc/user_account_bloc.dart';
import 'package:app/bloc/user_account_gym_bloc/user_account_gym_bloc.dart';
import 'package:app/hive/gym/gym_overview.dart';
import 'package:app/hive/user_account/user_account.dart';
import 'package:app/resources/app_settings.dart';
import 'package:app/widgets/error/flexus_error.dart';
import 'package:app/widgets/flexus_scrollbar.dart';
import 'package:app/widgets/list_tiles/flexus_user_account_gym_list_tile.dart';
import 'package:app/widgets/style/flexus_default_icon.dart';
import 'package:app/widgets/style/flexus_default_text_style.dart';
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
  TextEditingController textEditingController = TextEditingController();
  ScrollController scrollController = ScrollController();

  @override
  void dispose() {
    textEditingController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size deviceSize = MediaQuery.of(context).size;
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
              await showDialog(context, deviceSize);
              setState(() {});
            },
          ),
        ],
      ),
      child: ListTile(
        onTap: () {
          showPopUp(name, deviceSize);
        },
        contentPadding: EdgeInsets.symmetric(horizontal: AppSettings.fontSize),
        tileColor: AppSettings.background,
        leading: buildLeading(context),
        title: CustomDefaultTextStyle(text: name),
        trailing: GestureDetector(
          child: Container(
            child: buildTrailing(context),
          ),
        ),
        subtitle: buildSubTitle(),
      ),
    );
  }

  Future<dynamic> showDialog(BuildContext context, Size deviceSize) {
    return showCupertinoDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
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
                        fixedSize: MaterialStateProperty.all(Size.fromWidth(deviceSize.width * 0.25)),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const CustomDefaultTextStyle(text: 'Cancel'),
                    ),
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(AppSettings.background),
                        surfaceTintColor: MaterialStateProperty.all(AppSettings.background),
                        overlayColor: MaterialStateProperty.all(AppSettings.primaryShade48),
                        foregroundColor: MaterialStateProperty.all(AppSettings.primary),
                        fixedSize: MaterialStateProperty.all(Size.fromWidth(deviceSize.width * 0.25)),
                      ),
                      onPressed: () {
                        String recentName = userBox.get("recentGymName") ?? "";
                        String customGymName = userBox.get("customGymName${widget.gymOverview.gym.id}") ?? "";

                        if (textEditingController.text.isNotEmpty) {
                          userBox.put("customGymName${widget.gymOverview.gym.id}", textEditingController.text);

                          if (recentName == customGymName && recentName.isNotEmpty) {
                            userBox.put("recentGymName", textEditingController.text);
                          }
                        } else {
                          if (recentName == customGymName && recentName.isNotEmpty) {
                            userBox.put("recentGymName", widget.gymOverview.gym.name);
                          }

                          userBox.delete("customGymName${widget.gymOverview.gym.id}");
                        }

                        Navigator.pop(context);
                      },
                      child: const CustomDefaultTextStyle(text: 'Confirm'),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  void showPopUp(String name, Size deviceSize) {
    userAccountBloc.add(GetUserAccountsGym(gymID: widget.gymOverview.gym.id, isWorkingOut: true));
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
                        CustomDefaultTextStyle(
                          text: name,
                          fontSize: AppSettings.fontSizeH3,
                        ),
                        Visibility(
                          visible: widget.gymOverview.totalFriends > 0,
                          child: CustomDefaultTextStyle(
                            text: "${widget.gymOverview.userAccounts.length}/${widget.gymOverview.totalFriends} friends active",
                            fontSize: AppSettings.fontSize,
                            color: AppSettings.font.withOpacity(0.5),
                          ),
                        ),
                        SizedBox(height: deviceSize.height * 0.01),
                        Container(
                          width: deviceSize.width * 0.8,
                          color: AppSettings.font.withOpacity(0.15),
                          height: 1,
                        ),
                        BlocBuilder(
                          bloc: userAccountBloc,
                          builder: (context, state) {
                            if (state is UserAccountGymOverviewsLoaded) {
                              if (state.userAccountGymOverviews.isNotEmpty) {
                                return Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(horizontal: deviceSize.width * 0.05),
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
                                );
                              } else {
                                return const Expanded(
                                  child: Center(
                                    child: CustomDefaultTextStyle(
                                      text: 'No users training right now',
                                    ),
                                  ),
                                );
                              }
                            } else if (state is UserAccountsError) {
                              return FlexusError(text: state.error, func: loadData);
                            } else {
                              return Center(child: CircularProgressIndicator(color: AppSettings.primary));
                            }
                          },
                        ),
                        Container(
                          width: deviceSize.width * 0.8,
                          color: AppSettings.font.withOpacity(0.15),
                          height: 1,
                        ),
                        SizedBox(height: deviceSize.height * 0.02),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            BlocBuilder(
                              bloc: userAccountGymBloc,
                              builder: (context, state) {
                                if (state is UserAccountGymDeleted) {
                                  widget.func();

                                  return ElevatedButton(
                                    style: ButtonStyle(
                                      backgroundColor: MaterialStateProperty.all(AppSettings.background),
                                      surfaceTintColor: MaterialStateProperty.all(AppSettings.background),
                                      overlayColor: MaterialStateProperty.all(AppSettings.error.withOpacity(0.2)),
                                      foregroundColor: MaterialStateProperty.all(AppSettings.error),
                                      fixedSize: MaterialStateProperty.all(Size.fromWidth(deviceSize.width * 0.4)),
                                    ),
                                    onPressed: () {
                                      userAccountGymBloc.add(PostUserAccountGym(gymID: widget.gymOverview.gym.id));
                                    },
                                    child: FlexusDefaultIcon(
                                      iconData: Icons.check,
                                      iconColor: AppSettings.error,
                                      iconSize: AppSettings.fontSize,
                                    ),
                                  );
                                } else {
                                  return ElevatedButton(
                                    style: ButtonStyle(
                                      backgroundColor: MaterialStateProperty.all(AppSettings.background),
                                      surfaceTintColor: MaterialStateProperty.all(AppSettings.background),
                                      overlayColor: MaterialStateProperty.all(AppSettings.error.withOpacity(0.2)),
                                      foregroundColor: MaterialStateProperty.all(AppSettings.error),
                                      fixedSize: MaterialStateProperty.all(Size.fromWidth(deviceSize.width * 0.4)),
                                    ),
                                    onPressed: () {
                                      userAccountGymBloc.add(DeleteUserAccountGym(gymID: widget.gymOverview.gym.id));
                                    },
                                    child: CustomDefaultTextStyle(
                                      text: 'Remove Gym',
                                      color: AppSettings.error,
                                    ),
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
                                fixedSize: MaterialStateProperty.all(Size.fromWidth(deviceSize.width * 0.4)),
                              ),
                              onPressed: () {
                                openMaps(widget.gymOverview.gym.latitude, widget.gymOverview.gym.longitude);
                              },
                              child: const CustomDefaultTextStyle(text: 'Open in Maps'),
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

  void loadData() {
    userAccountBloc.add(GetUserAccountsGym(gymID: widget.gymOverview.gym.id, isWorkingOut: true));
  }

  Future<void> openMaps(double latitude, double longitude) async {
    Uri uri = Uri.parse('https://www.google.com/maps?q=$latitude,$longitude');
    await launchUrl(uri);
  }

  Widget buildSubTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomDefaultTextStyle(
          text: '${widget.gymOverview.gym.streetName} ${widget.gymOverview.gym.houseNumber}',
          fontSize: AppSettings.fontSizeT2,
        ),
        CustomDefaultTextStyle(
          text: '${widget.gymOverview.gym.zipCode} ${widget.gymOverview.gym.cityName}',
          fontSize: AppSettings.fontSizeT2,
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
                    radius: AppSettings.fontSizeH3,
                    backgroundColor: Colors.grey.shade100,
                    child: CustomDefaultTextStyle(text: "+${userAccounts.length - 3}"),
                  ),
                ),
              ],
            ),
          );

        default:
          return CustomDefaultTextStyle(text: "error ${userAccounts.length}");
      }
    } else {
      return const SizedBox(width: 120);
    }
  }

  Widget buildCorrectUserPicture(UserAccount userAccount, int element) {
    return userAccount.profilePicture != null
        ? CircleAvatar(
            radius: AppSettings.fontSizeH3,
            backgroundColor: AppSettings.primaryShade48,
            backgroundImage: MemoryImage(userAccount.profilePicture!),
          )
        : Container(
            padding: EdgeInsets.all(AppSettings.fontSizeH3 / 2),
            width: AppSettings.fontSizeH3 * 2,
            decoration: BoxDecoration(
              color: getCorrectShade(element),
              shape: BoxShape.circle,
            ),
            child: const FlexusDefaultIcon(iconData: Icons.person),
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
      radius: AppSettings.fontSizeH3,
      backgroundColor: AppSettings.primaryShade48,
      child: CustomDefaultTextStyle(
        text: widget.gymOverview.gym.name.length > 2 ? widget.gymOverview.gym.name.substring(0, 2).toUpperCase() : widget.gymOverview.gym.name,
        fontSize: AppSettings.fontSizeH4,
      ),
    );
  }
}

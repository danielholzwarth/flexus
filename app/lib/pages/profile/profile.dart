// ignore_for_file: use_build_context_synchronously

import 'package:app/api/report/report_service.dart';
import 'package:app/api/user_account/user_account_service.dart';
import 'package:app/bloc/best_lifts_bloc/best_lifts_bloc.dart';
import 'package:app/bloc/friendship_bloc/friendship_bloc.dart';
import 'package:app/bloc/user_account_bloc/user_account_bloc.dart';
import 'package:app/hive/best_lift/best_lift_overview.dart';
import 'package:app/hive/user_account/user_account.dart';
import 'package:app/pages/friends/my_friends.dart';
import 'package:app/pages/profile/leveling.dart';
import 'package:app/pages/profile/profile_picture.dart';
import 'package:app/pages/profile/settings.dart';
import 'package:app/resources/app_settings.dart';
import 'package:app/search_delegates/exercise_search_delegate.dart';
import 'package:app/widgets/style/flexus_default_icon.dart';
import 'package:app/widgets/style/flexus_default_text_style.dart';
import 'package:app/widgets/style/flexus_get_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:page_transition/page_transition.dart';

class ProfilePage extends StatefulWidget {
  final int userID;
  const ProfilePage({
    super.key,
    required this.userID,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final userAccountService = UserAccountService.create();
  final userBox = Hive.box('userBox');
  final BestLiftsBloc bestLiftsBloc = BestLiftsBloc();
  final TextEditingController reportTextController = TextEditingController();
  final UserAccountBloc userAccountBloc = UserAccountBloc();
  final FriendshipBloc friendshipBloc = FriendshipBloc();

  late bool isProfilePictureChecked;
  late bool isNameChecked;
  late bool isUsernameChecked;
  late bool isOtherChecked;

  @override
  void initState() {
    bestLiftsBloc.add(GetBestLifts(userAccountID: widget.userID));
    userAccountBloc.add(GetUserAccount(userAccountID: widget.userID));
    friendshipBloc.add(GetFriendship(requestedID: widget.userID));
    isProfilePictureChecked = false;
    isNameChecked = false;
    isUsernameChecked = false;
    isOtherChecked = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final UserAccount userAccount = userBox.get("userAccount");

    return Scaffold(
      backgroundColor: AppSettings.background,
      appBar: buildAppBar(context, userAccount),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              buildPictures(context, userAccount),
              SizedBox(height: AppSettings.screenHeight * 0.02),
              buildNames(userAccount),
              SizedBox(height: AppSettings.screenHeight * 0.1),
              buildBestLift(),
              SizedBox(height: AppSettings.screenHeight * 0.2)
            ],
          ),
        ),
      ),
    );
  }

  SizedBox buildNames(UserAccount userAccount) {
    return SizedBox(
      child: BlocBuilder(
        bloc: userAccountBloc,
        builder: (context, state) {
          if (state is UserAccountLoaded) {
            return Column(
              children: [
                CustomDefaultTextStyle(
                  text: state.userAccount.name,
                  fontSize: AppSettings.fontSizeH3,
                ),
                CustomDefaultTextStyle(
                  text: "@${state.userAccount.username}",
                ),
              ],
            );
          } else {
            return Center(child: CircularProgressIndicator(color: AppSettings.primary));
          }
        },
      ),
    );
  }

  SizedBox buildPictures(BuildContext context, UserAccount userAccount) {
    return SizedBox(
      width: AppSettings.screenWidth * 0.8,
      height: AppSettings.screenWidth * 0.8,
      child: BlocBuilder(
        bloc: userAccountBloc,
        builder: (context, state) {
          if (state is UserAccountLoaded) {
            return Stack(
              children: [
                Positioned(
                  left: AppSettings.screenWidth * 0.05,
                  top: AppSettings.screenWidth * 0.1,
                  child: buildCorrectLevelImage(state.userAccount.level),
                ),
                Positioned(
                  left: AppSettings.screenWidth * 0.25,
                  top: AppSettings.screenWidth * 0.12,
                  child: Hero(
                    tag: "profile_picture",
                    child: GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        PageTransition(
                          type: PageTransitionType.fade,
                          child: ProfilePicturePage(
                            userID: state.userAccount.id,
                            profilePicture: state.userAccount.profilePicture,
                          ),
                        ),
                      ).then((value) => userAccountBloc.add(GetUserAccount(userAccountID: widget.userID))),
                      child: state.userAccount.profilePicture != null
                          ? CircleAvatar(
                              radius: AppSettings.screenWidth * 0.15,
                              backgroundImage: MemoryImage(state.userAccount.profilePicture!),
                            )
                          : CircleAvatar(
                              radius: AppSettings.screenWidth * 0.15,
                              backgroundColor: Colors.transparent,
                            ),
                    ),
                  ),
                ),
                Positioned(
                  left: AppSettings.screenWidth * 0.28,
                  top: AppSettings.screenWidth * 0.5,
                  child: CustomDefaultTextStyle(
                    text: state.userAccount.level.toString(),
                    color: AppSettings.primary,
                    fontSize: AppSettings.fontSizeH3,
                  ),
                ),
              ],
            );
          } else {
            return Center(child: CircularProgressIndicator(color: AppSettings.primary));
          }
        },
      ),
    );
  }

  Widget buildCorrectLevelImage(int level) {
    switch (level) {
      case < 5:
        return Container(
          width: AppSettings.screenWidth * 0.7,
          height: AppSettings.screenWidth * 0.7,
          decoration: BoxDecoration(border: Border.all(color: Colors.green)),
        );

      case < 10:
        return Container(
          width: AppSettings.screenWidth * 0.7,
          height: AppSettings.screenWidth * 0.7,
          decoration: BoxDecoration(border: Border.all(color: Colors.yellow)),
        );

      case < 20:
        return Container(
          width: AppSettings.screenWidth * 0.7,
          height: AppSettings.screenWidth * 0.7,
          decoration: BoxDecoration(border: Border.all(color: Colors.orange)),
        );

      case < 30:
        return Container(
          width: AppSettings.screenWidth * 0.7,
          height: AppSettings.screenWidth * 0.7,
          decoration: BoxDecoration(border: Border.all(color: Colors.red)),
        );

      case < 40:
        return Container(
          width: AppSettings.screenWidth * 0.7,
          height: AppSettings.screenWidth * 0.7,
          decoration: BoxDecoration(border: Border.all(color: Colors.pink)),
        );

      case < 50:
        return Container(
          width: AppSettings.screenWidth * 0.7,
          height: AppSettings.screenWidth * 0.7,
          decoration: BoxDecoration(border: Border.all(color: Colors.purple)),
        );

      case < 100:
        return Container(
          width: AppSettings.screenWidth * 0.7,
          height: AppSettings.screenWidth * 0.7,
          decoration: BoxDecoration(border: Border.all(color: Colors.blue)),
        );

      case >= 100:
        return Container(
          width: AppSettings.screenWidth * 0.7,
          height: AppSettings.screenWidth * 0.7,
          decoration: BoxDecoration(border: Border.all(color: Colors.black)),
        );

      default:
        return Container(
          width: AppSettings.screenWidth * 0.7,
          height: AppSettings.screenWidth * 0.7,
          decoration: BoxDecoration(border: Border.all(color: Colors.green)),
        );
    }
  }

  Widget buildBestLift() {
    return BlocBuilder(
      bloc: bestLiftsBloc,
      builder: (context, state) {
        if (state is BestLiftsLoaded) {
          if (state.bestLiftOverviews.isNotEmpty) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildPedestal(
                    state.bestLiftOverviews.length >= 2 ? getCorrectPedestralText(state.bestLiftOverviews[1]) : "",
                    state.bestLiftOverviews.length >= 2 ? state.bestLiftOverviews[1].exerciseName : "Tap here",
                    AppSettings.screenHeight * 0.08,
                    AppSettings.screenWidth),
                _buildPedestal(
                    state.bestLiftOverviews.isNotEmpty ? getCorrectPedestralText(state.bestLiftOverviews[0]) : "",
                    state.bestLiftOverviews.isNotEmpty ? state.bestLiftOverviews[0].exerciseName : "Tap here",
                    AppSettings.screenHeight * 0.1,
                    AppSettings.screenWidth),
                _buildPedestal(
                    state.bestLiftOverviews.length >= 3 ? getCorrectPedestralText(state.bestLiftOverviews[2]) : "",
                    state.bestLiftOverviews.length >= 3 ? state.bestLiftOverviews[2].exerciseName : "Tap here",
                    AppSettings.screenHeight * 0.06,
                    AppSettings.screenWidth),
              ],
            );
          } else {
            UserAccount userAccount = userBox.get("userAccount");
            if (userAccount.id == widget.userID) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildPedestal("", "Tap here", AppSettings.screenHeight * 0.08, AppSettings.screenWidth),
                  _buildPedestal("", "Tap here", AppSettings.screenHeight * 0.1, AppSettings.screenWidth),
                  _buildPedestal("", "Tap here", AppSettings.screenHeight * 0.06, AppSettings.screenWidth),
                ],
              );
            } else {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildPedestal("", "None", AppSettings.screenHeight * 0.08, AppSettings.screenWidth),
                  _buildPedestal("", "None", AppSettings.screenHeight * 0.1, AppSettings.screenWidth),
                  _buildPedestal("", "None", AppSettings.screenHeight * 0.06, AppSettings.screenWidth),
                ],
              );
            }
          }
        } else {
          return Center(child: CircularProgressIndicator(color: AppSettings.primary));
        }
      },
    );
  }

  String getCorrectPedestralText(BestLiftOverview bestLiftOverview) {
    if (bestLiftOverview.measurement != null) {
      return bestLiftOverview.measurement!;
    } else {
      return "error loading";
    }
  }

  AppBar buildAppBar(BuildContext context, UserAccount userAccount) {
    return AppBar(
      backgroundColor: AppSettings.background,
      actions: [
        BlocBuilder(
          bloc: friendshipBloc,
          builder: (context, state) {
            if (state is FriendshipLoaded) {
              return PopupMenuButton<String>(
                color: AppSettings.background,
                icon: const FlexusDefaultIcon(iconData: Icons.menu),
                itemBuilder: (BuildContext context) {
                  if (widget.userID != userAccount.id) {
                    if (state.friendship != null) {
                      if (state.friendship!.isAccepted) {
                        return ['Remove Friend', 'Friends', 'Report'].map((String choice) {
                          return PopupMenuItem<String>(
                            value: choice,
                            child: CustomDefaultTextStyle(text: choice),
                          );
                        }).toList();
                      } else {
                        if (state.friendship!.requestorID == userAccount.id) {
                          return ['Friendrequest sent', 'Friends', 'Report'].map((String choice) {
                            return PopupMenuItem<String>(
                              value: choice,
                              child: CustomDefaultTextStyle(text: choice),
                            );
                          }).toList();
                        } else {
                          return ['Accept friendrequest', 'Friends', 'Report'].map((String choice) {
                            return PopupMenuItem<String>(
                              value: choice,
                              child: CustomDefaultTextStyle(text: choice),
                            );
                          }).toList();
                        }
                      }
                    } else {
                      return ['Add Friend', 'Friends', 'Report'].map((String choice) {
                        return PopupMenuItem<String>(
                          value: choice,
                          child: CustomDefaultTextStyle(text: choice),
                        );
                      }).toList();
                    }
                  } else {
                    return ['Settings', 'Friends', 'Leveling'].map((String choice) {
                      return PopupMenuItem<String>(
                        value: choice,
                        child: CustomDefaultTextStyle(text: choice),
                      );
                    }).toList();
                  }
                },
                onSelected: (String choice) async {
                  switch (choice) {
                    case "Settings":
                      Navigator.push(
                        context,
                        PageTransition(
                          type: PageTransitionType.rightToLeft,
                          child: const SettingsPage(),
                        ),
                      ).then((value) => setState(() {}));
                      break;

                    case "Leveling":
                      Navigator.push(
                        context,
                        PageTransition(
                          type: PageTransitionType.rightToLeft,
                          child: const LevelingPage(),
                        ),
                      );
                      break;

                    case "Add Friend":
                      friendshipBloc.add(PostFriendship(requestedID: widget.userID));
                      break;

                    case "Accept friendrequest":
                      friendshipBloc.add(PatchFriendship(
                        requestedID: widget.userID,
                        name: "isAccepted",
                        value: true,
                      ));
                      break;

                    case "Friends":
                      Navigator.push(
                        context,
                        PageTransition(
                          type: PageTransitionType.fade,
                          child: const MyFriendsPage(),
                        ),
                      );
                      break;

                    case "Friendrequest sent":
                    case "Remove Friend":
                      friendshipBloc.add(DeleteFriendship(requestedID: widget.userID));
                      break;

                    case "Report":
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return StatefulBuilder(
                            builder: (context, setState) {
                              return AlertDialog(
                                backgroundColor: AppSettings.background,
                                title: CustomDefaultTextStyle(
                                  text: "What is the reason of your report?",
                                  fontSize: AppSettings.fontSizeH3,
                                ),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const CustomDefaultTextStyle(
                                          text: "Offensive profile picture",
                                        ),
                                        Checkbox(
                                          value: isProfilePictureChecked,
                                          onChanged: (bool? value) {
                                            setState(() {
                                              isProfilePictureChecked = value!;
                                            });
                                          },
                                          activeColor: AppSettings.primary,
                                          checkColor: AppSettings.background,
                                          side: BorderSide(
                                            color: AppSettings.primary,
                                            width: 2,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const CustomDefaultTextStyle(
                                          text: "Offensive name",
                                        ),
                                        Checkbox(
                                          value: isNameChecked,
                                          onChanged: (bool? value) {
                                            setState(() {
                                              isNameChecked = value!;
                                            });
                                          },
                                          activeColor: AppSettings.primary,
                                          side: BorderSide(
                                            color: AppSettings.primary,
                                            width: 2,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const CustomDefaultTextStyle(
                                          text: "Offensive username",
                                        ),
                                        Checkbox(
                                          value: isUsernameChecked,
                                          onChanged: (bool? value) {
                                            setState(() {
                                              isUsernameChecked = value!;
                                            });
                                          },
                                          activeColor: AppSettings.primary,
                                          side: BorderSide(
                                            color: AppSettings.primary,
                                            width: 2,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const CustomDefaultTextStyle(
                                          text: "Other",
                                        ),
                                        Checkbox(
                                          value: isOtherChecked,
                                          onChanged: (bool? value) {
                                            if (value! == false) {
                                              reportTextController.clear();
                                            }
                                            setState(() {
                                              isOtherChecked = value;
                                            });
                                          },
                                          activeColor: AppSettings.primary,
                                          side: BorderSide(
                                            color: AppSettings.primary,
                                            width: 2,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Visibility(
                                      visible: isOtherChecked,
                                      child: TextField(
                                        controller: reportTextController,
                                        autofocus: true,
                                        cursorColor: AppSettings.font,
                                        decoration: InputDecoration(
                                          border: UnderlineInputBorder(borderSide: BorderSide(color: AppSettings.primary, width: 2)),
                                          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppSettings.primary, width: 2)),
                                          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppSettings.primary, width: 2)),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      isProfilePictureChecked = isNameChecked = isUsernameChecked = isOtherChecked = false;
                                      reportTextController.clear();
                                      Navigator.of(context).pop();
                                    },
                                    child: CustomDefaultTextStyle(
                                      text: 'Cancel',
                                      color: AppSettings.primary,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      ReportService reportService = ReportService.create();

                                      final response = await reportService.postReport(userBox.get("flexusjwt"), {
                                        "ReportedID": widget.userID,
                                        "isOffensiveProfilePicture": isProfilePictureChecked,
                                        "isOffensiveName": isNameChecked,
                                        "isOffensiveUsername": isUsernameChecked,
                                        "isOther": isOtherChecked,
                                        "message": reportTextController.text,
                                      });

                                      if (response.isSuccessful) {
                                        isProfilePictureChecked = isNameChecked = isUsernameChecked = isOtherChecked = false;
                                        reportTextController.clear();
                                      } else {
                                        await FlexusGet.showGetSnackbar(message: response.error.toString());
                                      }

                                      if (!Get.isSnackbarOpen) {
                                        Get.closeCurrentSnackbar();
                                      }

                                      Navigator.of(context).pop();
                                    },
                                    child: CustomDefaultTextStyle(
                                      text: 'Report',
                                      color: AppSettings.primary,
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      );
                      break;
                    default:
                      debugPrint("$choice not implemented yet");
                  }
                },
              );
            } else {
              return Center(child: CircularProgressIndicator(color: AppSettings.primary));
            }
          },
        ),
      ],
    );
  }

  Widget _buildPedestal(String text, String topText, double height, double screenwidth) {
    UserAccount userAccount = userBox.get("userAccount");
    return Column(
      children: [
        CustomDefaultTextStyle(
          text: text,
        ),
        Container(
          width: screenwidth / 3.5,
          height: height,
          color: AppSettings.primaryShade80,
          child: Center(
            child: TextButton(
              onPressed: userAccount.id == widget.userID
                  ? () async {
                      await showSearch(context: context, delegate: ExerciseCustomSearchDelegate());
                    }
                  : null,
              child: CustomDefaultTextStyle(
                text: topText,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

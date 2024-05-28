// ignore_for_file: use_build_context_synchronously

import 'package:app/api/report/report_service.dart';
import 'package:app/api/user_account/user_account_service.dart';
import 'package:app/bloc/best_lifts_bloc/best_lifts_bloc.dart';
import 'package:app/bloc/friendship_bloc/friendship_bloc.dart';
import 'package:app/bloc/user_account_bloc/user_account_bloc.dart';
import 'package:app/hive/best_lift/best_lift_overview.dart';
import 'package:app/hive/exercise/exercise.dart';
import 'package:app/hive/user_account/user_account.dart';
import 'package:app/pages/friends/friends.dart';
import 'package:app/pages/profile/leveling.dart';
import 'package:app/pages/profile/profile_picture.dart';
import 'package:app/pages/profile/settings.dart';
import 'package:app/resources/app_settings.dart';
import 'package:app/search_delegates/exercise_search_delegate.dart';
import 'package:app/widgets/style/flexus_default_icon.dart';
import 'package:app/widgets/style/flexus_default_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
    super.initState();
    loadData();
  }

  @override
  void dispose() {
    reportTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size deviceSize = MediaQuery.of(context).size;
    final UserAccount userAccount = userBox.get("userAccount");

    return Scaffold(
      backgroundColor: AppSettings.background,
      appBar: buildAppBar(context, userAccount),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              buildPictures(context, userAccount, deviceSize),
              SizedBox(height: deviceSize.height * 0.02),
              buildNames(userAccount),
              SizedBox(height: deviceSize.height * 0.1),
              buildBestLift(deviceSize),
              SizedBox(height: deviceSize.height * 0.2)
            ],
          ),
        ),
      ),
    );
  }

  void loadData() {
    bestLiftsBloc.add(GetBestLifts(userAccountID: widget.userID));
    friendshipBloc.add(GetFriendship(requestedID: widget.userID));
    isProfilePictureChecked = false;
    isNameChecked = false;
    isUsernameChecked = false;
    isOtherChecked = false;
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
          }

          return Column(
            children: [
              CustomDefaultTextStyle(
                text: userAccount.name,
                fontSize: AppSettings.fontSizeH3,
              ),
              CustomDefaultTextStyle(
                text: "@${userAccount.username}",
              ),
            ],
          );
        },
      ),
    );
  }

  SizedBox buildPictures(BuildContext context, UserAccount userAccount, Size deviceSize) {
    return SizedBox(
      width: deviceSize.width * 0.8,
      height: deviceSize.width * 0.8,
      child: BlocBuilder(
        bloc: userAccountBloc,
        builder: (context, state) {
          if (state is UserAccountLoaded) {
            return buildPictureStack(deviceSize, context, state.userAccount);
          }

          return buildPictureStack(deviceSize, context, userAccount);
        },
      ),
    );
  }

  Stack buildPictureStack(Size deviceSize, BuildContext context, UserAccount userAccount) {
    return Stack(
      children: [
        Positioned(
          top: deviceSize.width * 0.05,
          child: buildCorrectLevelImage(userAccount.level, deviceSize),
        ),
        Positioned(
          left: deviceSize.width * 0.28,
          top: deviceSize.width * 0.05,
          child: Hero(
            tag: "profile_picture",
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                PageTransition(
                  type: PageTransitionType.fade,
                  child: ProfilePicturePage(
                    userID: userAccount.id,
                    profilePicture: userAccount.profilePicture,
                  ),
                ),
              ).then((value) => setState(() {})),
              child: userAccount.profilePicture != null
                  ? CircleAvatar(
                      radius: deviceSize.width * 0.12,
                      backgroundImage: MemoryImage(userAccount.profilePicture!),
                    )
                  : Container(
                      width: deviceSize.width * 0.24,
                      height: deviceSize.width * 0.24,
                      decoration: BoxDecoration(
                        border: Border.all(width: 2, color: AppSettings.font.withOpacity(0.2)),
                        shape: BoxShape.circle,
                        color: AppSettings.background,
                      ),
                      alignment: Alignment.center,
                      child: CustomDefaultTextStyle(
                        text: userAccount.id == widget.userID ? "Add Picture" : "",
                        fontSize: AppSettings.fontSize,
                        color: AppSettings.font.withOpacity(0.5),
                      ),
                    ),
            ),
          ),
        ),
        Positioned(
          left: deviceSize.width * 0.31,
          top: deviceSize.width * 0.4,
          child: CustomDefaultTextStyle(
            text: userAccount.level.toString(),
            color: AppSettings.primary,
            fontSize: AppSettings.fontSizeH3,
          ),
        ),
      ],
    );
  }

  Widget buildCorrectLevelImage(int level, Size deviceSize) {
    switch (level) {
      case < 5:
        return SizedBox(
          width: deviceSize.width * 0.8,
          height: deviceSize.width * 0.8,
          child: Image.asset(
            "assets/images/body/body8.jpg",
            scale: 0.1,
          ),
        );

      case < 10:
        return SizedBox(
          width: deviceSize.width * 0.8,
          height: deviceSize.width * 0.8,
          child: Image.asset(
            "assets/images/body/body7.jpg",
            scale: 0.1,
          ),
        );

      case < 20:
        return SizedBox(
          width: deviceSize.width * 0.8,
          height: deviceSize.width * 0.8,
          child: Image.asset(
            "assets/images/body/body6.jpg",
            scale: 0.1,
          ),
        );

      case < 30:
        return SizedBox(
          width: deviceSize.width * 0.8,
          height: deviceSize.width * 0.8,
          child: Image.asset(
            "assets/images/body/body5.jpg",
            scale: 0.1,
          ),
        );

      case < 40:
        return SizedBox(
          width: deviceSize.width * 0.8,
          height: deviceSize.width * 0.8,
          child: Image.asset(
            "assets/images/body/body4.jpg",
            scale: 0.1,
          ),
        );

      case < 50:
        return SizedBox(
          width: deviceSize.width * 0.8,
          height: deviceSize.width * 0.8,
          child: Image.asset(
            "assets/images/body/body3.jpg",
            scale: 0.1,
          ),
        );

      case < 100:
        return SizedBox(
          width: deviceSize.width * 0.8,
          height: deviceSize.width * 0.8,
          child: Image.asset(
            "assets/images/body/body2.jpg",
            scale: 0.1,
          ),
        );

      case >= 100:
        return SizedBox(
          width: deviceSize.width * 0.8,
          height: deviceSize.width * 0.8,
          child: Image.asset(
            "assets/images/body/body1.jpg",
            scale: 0.1,
          ),
        );

      default:
        return Container(
          width: deviceSize.width * 0.8,
          height: deviceSize.width * 0.8,
          decoration: BoxDecoration(border: Border.all(color: Colors.green)),
        );
    }
  }

  Widget buildBestLift(Size deviceSize) {
    return BlocConsumer(
      bloc: bestLiftsBloc,
      listener: (context, state) {
        if (state is BestLiftsError) {
          Fluttertoast.cancel();
          Fluttertoast.showToast(
            msg: state.error,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            backgroundColor: AppSettings.error,
            textColor: AppSettings.fontV1,
            fontSize: AppSettings.fontSize,
          );
        }
      },
      builder: (context, state) {
        if (state is BestLiftsLoaded) {
          if (state.bestLiftOverviews.isNotEmpty) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildPedestal(
                  state.bestLiftOverviews.firstWhereOrNull((element) => element.position == 1),
                  deviceSize.height * 0.08,
                  deviceSize.width,
                  1,
                ),
                _buildPedestal(
                  state.bestLiftOverviews.firstWhereOrNull((element) => element.position == 0),
                  deviceSize.height * 0.1,
                  deviceSize.width,
                  0,
                ),
                _buildPedestal(
                  state.bestLiftOverviews.firstWhereOrNull((element) => element.position == 2),
                  deviceSize.height * 0.06,
                  deviceSize.width,
                  2,
                ),
              ],
            );
          } else {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildPedestal(null, deviceSize.height * 0.08, deviceSize.width, 1),
                _buildPedestal(null, deviceSize.height * 0.1, deviceSize.width, 0),
                _buildPedestal(null, deviceSize.height * 0.06, deviceSize.width, 2),
              ],
            );
          }
        } else {
          return Center(child: CircularProgressIndicator(color: AppSettings.primary));
        }
      },
    );
  }

  String getCorrectPedestralText(BestLiftOverview bestLiftOverview) {
    if (bestLiftOverview.isRepetition) {
      return "${bestLiftOverview.repetitions} x ${bestLiftOverview.workload}kg";
    } else {
      return "${bestLiftOverview.workload}s";
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
                        return ['Remove Friend', 'Report'].map((String choice) {
                          return PopupMenuItem<String>(
                            value: choice,
                            child: CustomDefaultTextStyle(text: choice),
                          );
                        }).toList();
                      } else {
                        if (state.friendship!.requestorID == userAccount.id) {
                          return ['Friendrequest sent', 'Report'].map((String choice) {
                            return PopupMenuItem<String>(
                              value: choice,
                              child: CustomDefaultTextStyle(text: choice),
                            );
                          }).toList();
                        } else {
                          return ['Accept friendrequest', 'Report'].map((String choice) {
                            return PopupMenuItem<String>(
                              value: choice,
                              child: CustomDefaultTextStyle(text: choice),
                            );
                          }).toList();
                        }
                      }
                    } else {
                      return ['Add Friend', 'Report'].map((String choice) {
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
                          child: const FriendsPage(),
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
                                        Fluttertoast.cancel();
                                        Fluttertoast.showToast(
                                          msg: response.error.toString(),
                                          toastLength: Toast.LENGTH_SHORT,
                                          gravity: ToastGravity.CENTER,
                                          backgroundColor: AppSettings.error,
                                          textColor: AppSettings.fontV1,
                                          fontSize: AppSettings.fontSize,
                                        );
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

  Widget _buildPedestal(BestLiftOverview? bestLiftOverview, double height, double screenwidth, int position) {
    UserAccount userAccount = userBox.get("userAccount");
    return Column(
      children: [
        CustomDefaultTextStyle(text: bestLiftOverview != null ? bestLiftOverview.exerciseName : ""),
        Container(
          width: screenwidth / 3.5,
          height: height,
          color: AppSettings.primaryShade80,
          child: Center(
            child: TextButton(
              onPressed: userAccount.id == widget.userID
                  ? bestLiftOverview != null
                      ? () async {
                          final val = await showSearch(context: context, delegate: ExerciseSearchDelegate(isMultipleChoice: false));
                          if (val != null) {
                            Exercise ex = val;
                            bestLiftsBloc.add(PatchBestLift(position: position, exerciseID: ex.id));
                          }
                        }
                      : () async {
                          final val = await showSearch(context: context, delegate: ExerciseSearchDelegate(isMultipleChoice: false));
                          if (val != null) {
                            Exercise ex = val;
                            bestLiftsBloc.add(PostBestLift(position: position, exerciseID: ex.id));
                          }
                        }
                  : null,
              child: CustomDefaultTextStyle(text: bestLiftOverview != null ? getCorrectPedestralText(bestLiftOverview) : "[Empty]"),
            ),
          ),
        ),
      ],
    );
  }
}

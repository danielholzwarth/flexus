// ignore_for_file: use_build_context_synchronously

import 'package:app/api/report_service.dart';
import 'package:app/api/user_account_service.dart';
import 'package:app/bloc/best_lifts_bloc/best_lifts_bloc.dart';
import 'package:app/hive/best_lift_overview.dart';
import 'package:app/hive/user_account.dart';
import 'package:app/pages/home/leveling.dart';
import 'package:app/pages/home/profile_picture.dart';
import 'package:app/pages/home/settings.dart';
import 'package:app/pages/workout_documentation/exercises.dart';
import 'package:app/resources/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';

class ProfilePage extends StatefulWidget {
  final bool isOwnProfile;
  final int userID;
  const ProfilePage({
    super.key,
    required this.isOwnProfile,
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

  late bool isProfilePictureChecked;
  late bool isNameChecked;
  late bool isUsernameChecked;
  late bool isOtherChecked;

  @override
  void initState() {
    super.initState();
    bestLiftsBloc.add(LoadBestLifts(userAccountID: widget.userID));
    isProfilePictureChecked = false;
    isNameChecked = false;
    isUsernameChecked = false;
    isOtherChecked = false;
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final UserAccount userAccount = userBox.get("userAccount");

    return Scaffold(
      backgroundColor: AppSettings.background,
      appBar: buildAppBar(context),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              buildPictures(screenWidth, context, userAccount),
              SizedBox(height: screenHeight * 0.02),
              buildNames(userAccount),
              Text("Since ${DateFormat('dd.MM.yyyy').format(userAccount.createdAt!)}"),
              SizedBox(height: screenHeight * 0.1),
              buildBestLift(screenHeight, screenWidth),
              SizedBox(height: screenHeight * 0.2)
            ],
          ),
        ),
      ),
    );
  }

  Column buildNames(UserAccount userAccount) {
    return Column(
      children: [
        Text(
          userAccount.name,
          style: TextStyle(
            color: AppSettings.font,
            fontSize: AppSettings.fontSizeTitle,
          ),
        ),
        Text(
          "@${userAccount.username}",
          style: TextStyle(
            color: AppSettings.font,
            fontSize: AppSettings.fontSize,
          ),
        ),
      ],
    );
  }

  SizedBox buildPictures(double screenWidth, BuildContext context, UserAccount userAccount) {
    return SizedBox(
      width: screenWidth * 0.8,
      height: screenWidth * 0.8,
      child: Stack(
        children: [
          const SizedBox(
            child: Image(
              fit: BoxFit.fill,
              image: NetworkImage('https://cdn-icons-png.flaticon.com/512/3490/3490782.png'),
            ),
          ),
          Positioned(
            left: screenWidth * 0.25,
            top: screenWidth * 0.12,
            child: Hero(
              tag: "profile_picture",
              child: GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  PageTransition(
                    type: PageTransitionType.fade,
                    child: ProfilePicturePage(
                      isOwnProfile: widget.isOwnProfile,
                    ),
                  ),
                ).then((value) => setState(() {})),
                child: userAccount.profilePicture != null
                    ? CircleAvatar(
                        radius: screenWidth * 0.15,
                        backgroundImage: MemoryImage(userAccount.profilePicture!),
                      )
                    : CircleAvatar(
                        radius: screenWidth * 0.15,
                        backgroundColor: Colors.transparent,
                      ),
              ),
            ),
          ),
          Positioned(
            left: screenWidth * 0.28,
            top: screenWidth * 0.5,
            child: Text(
              userAccount.level.toString(),
              style: TextStyle(
                color: AppSettings.primary,
                fontSize: AppSettings.fontSizeTitle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildBestLift(double screenHeight, double screenWidth) {
    return BlocBuilder(
      bloc: bestLiftsBloc,
      builder: (context, state) {
        if (state is BestLiftsLoading) {
          return Center(child: CircularProgressIndicator(color: AppSettings.primary));
        } else if (state is BestLiftsLoaded) {
          if (state.bestLiftOverviews.isNotEmpty) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildPedestal(state.bestLiftOverviews.length >= 2 ? getCorrectPedestralText(state.bestLiftOverviews[1]) : "",
                    state.bestLiftOverviews.length >= 2 ? state.bestLiftOverviews[1].exerciseName : "Tap here", screenHeight * 0.08, screenWidth),
                _buildPedestal(state.bestLiftOverviews.isNotEmpty ? getCorrectPedestralText(state.bestLiftOverviews[0]) : "",
                    state.bestLiftOverviews.isNotEmpty ? state.bestLiftOverviews[0].exerciseName : "Tap here", screenHeight * 0.1, screenWidth),
                _buildPedestal(state.bestLiftOverviews.length >= 3 ? getCorrectPedestralText(state.bestLiftOverviews[2]) : "",
                    state.bestLiftOverviews.length >= 3 ? state.bestLiftOverviews[2].exerciseName : "Tap here", screenHeight * 0.06, screenWidth),
              ],
            );
          } else {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildPedestal("", "Tap here", screenHeight * 0.08, screenWidth),
                _buildPedestal("", "Tap here", screenHeight * 0.1, screenWidth),
                _buildPedestal("", "Tap here", screenHeight * 0.06, screenWidth),
              ],
            );
          }
        } else {
          return const Text("Error loading best lifts");
        }
      },
    );
  }

  String getCorrectPedestralText(BestLiftOverview bestLiftOverview) {
    if (bestLiftOverview.duration != null) {
      return "${bestLiftOverview.duration}s";
    }

    String text = "";
    if (bestLiftOverview.repetitions != null) {
      text = text + bestLiftOverview.repetitions.toString();
    }

    if (bestLiftOverview.weight != null) {
      text = "$text x ${bestLiftOverview.weight}kg";
    }

    return text;
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppSettings.background,
      actions: [
        PopupMenuButton<String>(
          color: AppSettings.background,
          icon: Icon(
            Icons.menu,
            color: AppSettings.font,
            size: AppSettings.fontSizeTitle,
          ),
          itemBuilder: (BuildContext context) {
            return widget.isOwnProfile
                ? ['Settings', 'Leveling'].map((String choice) {
                    return PopupMenuItem<String>(
                      value: choice,
                      child: Text(choice),
                    );
                  }).toList()
                : ['Add Friend', 'Report'].map((String choice) {
                    return PopupMenuItem<String>(
                      value: choice,
                      child: Text(choice),
                    );
                  }).toList();
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
                );
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

              case "Report":
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return StatefulBuilder(
                      builder: (context, setState) {
                        return AlertDialog(
                          backgroundColor: AppSettings.background,
                          title: Text(
                            "What is the reason of your report?",
                            style: TextStyle(
                              color: AppSettings.font,
                              fontSize: AppSettings.fontSizeTitle,
                            ),
                          ),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Offensive profile picture",
                                    style: TextStyle(
                                      color: AppSettings.font,
                                      fontSize: AppSettings.fontSize,
                                    ),
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
                                  Text(
                                    "Offensive name",
                                    style: TextStyle(
                                      color: AppSettings.font,
                                      fontSize: AppSettings.fontSize,
                                    ),
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
                                  Text(
                                    "Offensive username",
                                    style: TextStyle(
                                      color: AppSettings.font,
                                      fontSize: AppSettings.fontSize,
                                    ),
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
                                  Text(
                                    "Other",
                                    style: TextStyle(
                                      color: AppSettings.font,
                                      fontSize: AppSettings.fontSize,
                                    ),
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
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  color: AppSettings.primary,
                                  fontSize: AppSettings.fontSize,
                                ),
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
                                  ScaffoldMessenger.of(context).clearSnackBars();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Center(
                                        child: Text(response.error.toString()),
                                      ),
                                    ),
                                  );
                                }

                                Navigator.of(context).pop();
                              },
                              child: Text(
                                'Report',
                                style: TextStyle(
                                  color: AppSettings.primary,
                                  fontSize: AppSettings.fontSize,
                                ),
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
                print("$choice not implemented yet");
            }
          },
        ),
      ],
    );
  }

  Widget _buildPedestal(String text, String topText, double height, double screenwidth) {
    return Column(
      children: [
        Text(
          text,
          style: TextStyle(
            color: AppSettings.font,
            fontSize: AppSettings.fontSize,
          ),
        ),
        Container(
          width: screenwidth / 3.5,
          height: height,
          color: AppSettings.primaryShade80,
          child: Center(
            child: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  PageTransition(
                    type: PageTransitionType.fade,
                    child: const ExercisesPage(),
                  ),
                );
              },
              child: Text(
                topText,
                style: TextStyle(
                  color: AppSettings.font,
                  fontSize: AppSettings.fontSize,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

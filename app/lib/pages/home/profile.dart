import 'package:app/api/user_account_service.dart';
import 'package:app/bloc/best_lifts_bloc/best_lifts_bloc.dart';
import 'package:app/bloc/user_account_bloc/user_account_bloc.dart';
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

  @override
  void initState() {
    super.initState();
    bestLiftsBloc.add(LoadBestLifts(userAccountID: widget.userID));
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final UserAccount userAccount = userBox.get("userAccount");

    return Scaffold(
      backgroundColor: AppSettings.background,
      appBar: buildAppBar(context),
      body: Center(
        child: BlocBuilder(
          bloc: bestLiftsBloc,
          builder: (context, state) {
            if (state is BestLiftsLoading) {
              return Center(child: CircularProgressIndicator(color: AppSettings.primary));
            } else if (state is BestLiftsLoaded) {
              return Column(
                children: [
                  buildPictures(screenWidth, context, userAccount),
                  SizedBox(height: screenHeight * 0.02),
                  buildNames(userAccount),
                  Text("Since ${DateFormat('dd.MM.yyyy').format(userAccount.createdAt!)}"),
                  const Spacer(),
                  buildBestLift(screenHeight, screenWidth, state),
                  SizedBox(height: screenHeight * 0.2)
                ],
              );
            } else if (state is UserAccountError) {
              return Text(
                'Error loading workouts',
                style: TextStyle(fontSize: AppSettings.fontSize),
              );
            } else {
              return Text(
                'Error XYZ',
                style: TextStyle(fontSize: AppSettings.fontSize),
              );
            }
          },
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

  Row buildBestLift(double screenHeight, double screenWidth, BestLiftsLoaded state) {
    List<BestLiftOverview>? bestLiftOverview = userBox.get("bestLiftOverview");
    if (bestLiftOverview != null) {
      int bestLiftCount = bestLiftOverview.length;

      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildPedestal(bestLiftCount >= 2 ? getCorrectPedestralText(bestLiftOverview[1]) : "",
              bestLiftCount >= 2 ? bestLiftOverview[1].exerciseName : "Tap here", screenHeight * 0.08, screenWidth),
          _buildPedestal(bestLiftCount >= 1 ? getCorrectPedestralText(bestLiftOverview[0]) : "",
              bestLiftCount >= 1 ? bestLiftOverview[0].exerciseName : "Tap here", screenHeight * 0.1, screenWidth),
          _buildPedestal(bestLiftCount >= 3 ? getCorrectPedestralText(bestLiftOverview[2]) : "",
              bestLiftCount >= 3 ? bestLiftOverview[2].exerciseName : "Tap here", screenHeight * 0.06, screenWidth),
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
          icon: Icon(
            Icons.menu,
            color: AppSettings.font,
            size: AppSettings.fontSizeTitle,
          ),
          itemBuilder: (BuildContext context) {
            return widget.isOwnProfile
                ? {'Settings', 'Leveling'}.map((String choice) {
                    return PopupMenuItem<String>(
                      value: choice,
                      child: Text(choice),
                    );
                  }).toList()
                : {'Add Friend', 'Report'}.map((String choice) {
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
              default:
                print("not implemented yet");
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

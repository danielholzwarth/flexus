import 'package:app/api/user_account_service.dart';
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
  final UserAccountBloc userAccountBloc = UserAccountBloc();

  @override
  void initState() {
    super.initState();
    userAccountBloc.add(LoadUserAccount(userAccountID: 1));
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
        child: BlocConsumer(
          bloc: userAccountBloc,
          listener: (context, state) {
            if (state is UserAccountLoaded) {}
          },
          builder: (context, state) {
            if (state is UserAccountLoading) {
              return Text(
                'Loading',
                style: TextStyle(fontSize: AppSettings.fontSize),
              );
            } else if (state is UserAccountLoaded) {
              return Column(
                children: [
                  buildPictures(screenWidth, context, userAccount),
                  buildNames(),
                  Text(state.userAccountOverview.gender ?? "No gender"),
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

  Column buildNames() {
    return Column(
      children: [
        Text(
          "Daniel",
          style: TextStyle(
            color: AppSettings.font,
            fontSize: AppSettings.fontSizeTitle,
          ),
        ),
        Text(
          "@dholzwarth",
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
              "13",
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

  Row buildBestLift(double screenHeight, double screenWidth, UserAccountLoaded state) {
    int bestLiftCount = 0;
    if (state.userAccountOverview.bestLiftOverview != null) {
      bestLiftCount = state.userAccountOverview.bestLiftOverview!.length;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _buildPedestal(bestLiftCount >= 2 ? getCorrectPedestralText(state.userAccountOverview.bestLiftOverview![1]) : "",
            bestLiftCount >= 2 ? state.userAccountOverview.bestLiftOverview![1].exerciseName : "Press to add", screenHeight * 0.08, screenWidth),
        _buildPedestal(bestLiftCount >= 1 ? getCorrectPedestralText(state.userAccountOverview.bestLiftOverview![0]) : "",
            bestLiftCount >= 1 ? state.userAccountOverview.bestLiftOverview![0].exerciseName : "Press to add", screenHeight * 0.1, screenWidth),
        _buildPedestal(bestLiftCount >= 3 ? getCorrectPedestralText(state.userAccountOverview.bestLiftOverview![2]) : "",
            bestLiftCount >= 3 ? state.userAccountOverview.bestLiftOverview![2].exerciseName : "Press to add", screenHeight * 0.06, screenWidth),
      ],
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
          icon: Icon(
            Icons.menu,
            color: AppSettings.font,
            size: AppSettings.fontSizeTitle,
          ),
          itemBuilder: (BuildContext context) {
            return widget.isOwnProfile
                ? {'Settings', 'Leveling', 'Change best lifts'}.map((String choice) {
                    return PopupMenuItem<String>(
                      value: choice,
                      child: Text(choice),
                    );
                  }).toList()
                : {'Settings', 'Leveling', 'Change best lifts'}.map((String choice) {
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
                    type: PageTransitionType.leftToRight,
                    child: const SettingsPage(),
                  ),
                );
                break;
              case "Leveling":
                Navigator.push(
                  context,
                  PageTransition(
                    type: PageTransitionType.leftToRight,
                    child: const LevelingPage(),
                  ),
                );
                break;
              case "Change best lifts":
                final response = await userAccountService.getUserAccountOverview(userBox.get("flexusjwt"), 1);
                print(response.bodyString);

                Navigator.push(
                  context,
                  PageTransition(
                    type: PageTransitionType.leftToRight,
                    child: const ExercisesPage(),
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
          width: screenwidth / 4,
          height: height,
          color: AppSettings.primaryShade80,
          child: Center(
            child: Text(
              topText,
              style: TextStyle(
                color: AppSettings.font,
                fontSize: AppSettings.fontSize,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

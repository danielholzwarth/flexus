import 'package:app/pages/home/leveling.dart';
import 'package:app/pages/home/profile_picture.dart';
import 'package:app/pages/home/settings.dart';
import 'package:app/pages/workout_documentation/exercises.dart';
import 'package:app/resources/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

class ProfilePage extends StatelessWidget {
  final bool isOwnProfile;
  final int userID;
  const ProfilePage({
    super.key,
    required this.isOwnProfile,
    required this.userID,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppSettings.background,
      appBar: buildAppBar(context),
      body: Center(
        child: Column(
          children: [
            buildPictures(screenWidth, context),
            buildNames(),
            const Spacer(),
            buildBestLifts(screenHeight, screenWidth),
            SizedBox(height: screenHeight * 0.2)
          ],
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

  SizedBox buildPictures(double screenWidth, BuildContext context) {
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
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                PageTransition(
                  type: PageTransitionType.leftToRight,
                  child: const ProfilePicturePage(),
                ),
              ),
              child: CircleAvatar(
                radius: screenWidth * 0.15,
                backgroundImage: const NetworkImage('https://www.anthropics.com/portraitpro/img/page-images/homepage/v22/what-can-it-do-2A.jpg'),
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

  Row buildBestLifts(double screenHeight, double screenWidth) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _buildPedestal("1 x 120kg", "Deadlift", screenHeight * 0.08, screenWidth),
        _buildPedestal("1 x 100kg", "Benchpress", screenHeight * 0.1, screenWidth),
        _buildPedestal("1 x 150kg", "Squat", screenHeight * 0.06, screenWidth),
      ],
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppSettings.background,
      title: const Text('Profile'),
      centerTitle: true,
      actions: [
        PopupMenuButton<String>(
          icon: Icon(
            Icons.menu,
            color: AppSettings.font,
            size: AppSettings.fontSizeTitle,
          ),
          itemBuilder: (BuildContext context) {
            return isOwnProfile
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
          onSelected: (String choice) {
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

import 'package:app/resources/app_settings.dart';
import 'package:flutter/material.dart';

class LevelingPage extends StatelessWidget {
  const LevelingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppSettings.background,
      appBar: AppBar(
        backgroundColor: AppSettings.background,
        shadowColor: AppSettings.background,
        surfaceTintColor: AppSettings.background,
        title: const Text('Leveling'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              SizedBox(height: AppSettings.screenHeight * 0.03),
              buildItem(
                "What does it mean?",
                "To track your consistency, you can refer to your player number on your profile page."
                    "The longer you engage in workouts, the higher your number will be.Your character will also get stronger themore you train",
              ),
              SizedBox(height: AppSettings.screenHeight * 0.05),
              buildItem(
                "How do I level up?",
                "For each workout you complete, your level increases by one point."
                    "However, you can increase your level only once per day, but feel free to track multiple workouts as they will still be reflected in your statistics.",
              ),
              SizedBox(height: AppSettings.screenHeight * 0.05),
              buildItem(
                "Can I lose level?",
                "Yes. As soon as you don’t work out for more than one week, you'll lose five points per week.\n"
                    "That means no workout for 3 weeks results in a loss of 15 levels.",
              ),
              SizedBox(height: AppSettings.screenHeight * 0.05),
            ],
          ),
        ),
      ),
    );
  }

  SizedBox buildItem(String title, String description) {
    return SizedBox(
      width: AppSettings.screenWidth * 0.8,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: AppSettings.font,
              fontSize: AppSettings.fontSizeTitle,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            description,
            style: TextStyle(
              color: AppSettings.font,
              fontSize: AppSettings.fontSize,
            ),
          ),
        ],
      ),
    );
  }
}

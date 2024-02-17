import 'package:app/pages/workout_documentation/start_workout.dart';
import 'package:app/resources/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

class FlexusFloatingActionButton extends StatelessWidget {
  const FlexusFloatingActionButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      foregroundColor: AppSettings.fontV1,
      backgroundColor: AppSettings.primary,
      onPressed: () {
        Navigator.push(
          context,
          PageTransition(
            type: PageTransitionType.fade,
            child: const StartWorkoutPage(),
          ),
        );
      },
      shape: const CircleBorder(),
      child: Icon(
        Icons.add,
        size: AppSettings.fontSizeTitle,
      ),
    );
  }
}

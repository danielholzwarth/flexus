import 'package:app/bloc/exercise_bloc/exercise_bloc.dart';
import 'package:app/resources/app_settings.dart';
import 'package:app/widgets/style/flexus_basic_title.dart';
import 'package:app/widgets/style/flexus_default_text_style.dart';
import 'package:flutter/material.dart';

class ExerciseExplanationPage extends StatefulWidget {
  const ExerciseExplanationPage({
    super.key,
    required this.name,
    required this.exerciseID,
  });
  final String name;
  final int exerciseID;

  @override
  State<ExerciseExplanationPage> createState() => _ExerciseExplanationPageState();
}

class _ExerciseExplanationPageState extends State<ExerciseExplanationPage> {
  ExerciseBloc exerciseBloc = ExerciseBloc();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size deviceSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppSettings.background,
      appBar: AppBar(
        title: CustomDefaultTextStyle(
          text: "Benchpress (Demo)",
          fontSize: AppSettings.fontSizeH3,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: deviceSize.width * 0.05,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildMuscleGroups(deviceSize),
              buildCorrectForm(deviceSize),
              SizedBox(height: deviceSize.height * 0.1),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildMuscleGroups(Size deviceSize) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FlexusBasicTitle(deviceSize: deviceSize, text: "Affected Muscle Groups"),
        ExpansionTile(
          tilePadding: EdgeInsets.zero,
          title: CustomDefaultTextStyle(
            text: "Primary: Chest and Triceps",
            fontSize: AppSettings.fontSizeH4,
          ),
          shape: InputBorder.none,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CustomDefaultTextStyle(
                  text: "Chest Muscle (Pectoralis Major)",
                  fontWeight: FontWeight.w600,
                ),
                const CustomDefaultTextStyle(text: "This is the main muscle responsible for drawing the arm across the body."),
                SizedBox(height: deviceSize.height * 0.02),
                const CustomDefaultTextStyle(
                  text: "Tricep",
                  fontWeight: FontWeight.w600,
                ),
                const CustomDefaultTextStyle(text: "The main muscle responsible for straightening the arm from a bent position."),
                SizedBox(height: deviceSize.height * 0.02)
              ],
            )
          ],
        ),
        ExpansionTile(
          tilePadding: EdgeInsets.zero,
          title: CustomDefaultTextStyle(
            text: "Secondary: Shoulder and Core",
            fontSize: AppSettings.fontSizeH4,
          ),
          shape: InputBorder.none,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CustomDefaultTextStyle(
                  text: "Shoulder (Front Deltoid)",
                  fontWeight: FontWeight.w600,
                ),
                const CustomDefaultTextStyle(
                  text: "The front of the delt will help out the chest in bringing your arm across the front of the body.",
                ),
                SizedBox(height: deviceSize.height * 0.02),
                const CustomDefaultTextStyle(
                  text: "Core",
                  fontWeight: FontWeight.w600,
                ),
                const CustomDefaultTextStyle(
                    text:
                        "A strong core will help transfer force in an advanced lifting technique called “Leg Drive” in the bench press. Beginners should avoid this technique until they have mastered the fundamentals."),
              ],
            )
          ],
        ),
      ],
    );
  }

  Widget buildCorrectForm(Size deviceSize) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FlexusBasicTitle(deviceSize: deviceSize, text: "Correct Form"),
        Padding(
          padding: EdgeInsets.only(
            left: deviceSize.width * 0.05,
            top: deviceSize.width * 0.02,
            right: deviceSize.width * 0.05,
          ),
          child: Material(
            elevation: AppSettings.elevation,
            borderRadius: const BorderRadius.all(Radius.circular(20.0)),
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(20.0)),
              child: Image.asset("assets/images/exercises/benchpress.gif"),
            ),
          ),
        ),
        SizedBox(height: deviceSize.height * 0.02),
        const CustomDefaultTextStyle(
          text: "Step 1: The Set Up For Bench Press",
          fontWeight: FontWeight.w600,
        ),
        const CustomDefaultTextStyle(
          text: '''
Start with your back flat on a bench and feet firmly planted on the ground.

Keep your feet apart so you have a firm base of support. Your shoulder blades should be tucked back and down.

Think about trying to put your shoulder blades in your back pockets.

Finally you will want to make sure you eyes are directly underneath the barbell.''',
        ),
        SizedBox(height: deviceSize.height * 0.02),
        const CustomDefaultTextStyle(
          text: "Step 2: Hand Grip Position Bench Press",
          fontWeight: FontWeight.w600,
        ),
        const CustomDefaultTextStyle(
          text: '''
Start with no weight on the bar to see if your hand position is correct when the bar touches your chest.

Your hands should be wide enough on the barbell so that in the bottom position, when the bar is touching your chest, your forearm is perpendicular to the bar.

For most people this is just outside shoulder width.''',
        ),
        SizedBox(height: deviceSize.height * 0.02),
        const CustomDefaultTextStyle(
          text: "Step 3: Full Range Of Motion",
          fontWeight: FontWeight.w600,
        ),
        const CustomDefaultTextStyle(text: '''
The bar should be unracked from the bench and will hover over your shoulders. This is the starting position.

You should lower the bar down to your chest. Ideally, this will be a few inches lower down on the chest and more in line with the nipples than the shoulders.

The bar itself does not move 100% up and down. It is more of an arc pattern.'''),
      ],
    );
  }
}

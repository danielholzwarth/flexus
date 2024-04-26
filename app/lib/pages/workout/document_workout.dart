import 'package:app/hive/gym/gym.dart';
import 'package:app/hive/plan/plan.dart';
import 'package:app/hive/split/split.dart';
import 'package:app/pages/workout/document_exercise.dart';
import 'package:app/pages/workout/timer.dart';
import 'package:app/resources/app_settings.dart';
import 'package:app/widgets/buttons/flexus_floating_action_button.dart';
import 'package:app/widgets/style/flexus_default_icon.dart';
import 'package:app/widgets/style/flexus_default_text_style.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:page_transition/page_transition.dart';

class DocumentWorkoutPage extends StatefulWidget {
  const DocumentWorkoutPage({
    super.key,
    this.gym,
    this.plan,
    this.split,
  });

  final Gym? gym;
  final Plan? plan;
  final Split? split;

  @override
  State<DocumentWorkoutPage> createState() => _DocumentWorkoutPageState();
}

class _DocumentWorkoutPageState extends State<DocumentWorkoutPage> {
  final userBox = Hive.box('userBox');

  final PageController pageController = PageController();
  int currentPageIndex = 0;
  int exerciseLength = 4;

  List<Widget> pages = [];

  bool hasCurrentWorkout = true;

  @override
  void initState() {
    if (hasCurrentWorkout) {
      //Get Local Workout Data
    } else {
      if (widget.split != null) {
        //Load exercises for split
        //As soon as loaded display accordingly

        //Add pages for each exercise
      } else {
        pages.add(const DocumentExercisePage(
          exerciseID: null,
          pageID: 1,
        ));
      }
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppSettings.background,
      appBar: AppBar(
        backgroundColor: AppSettings.background,
        title: CustomDefaultTextStyle(
          text: "SplitName",
          fontSize: AppSettings.fontSizeH3,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              debugPrint("adding new page ${pages.length + 1}");
              pages.add(DocumentExercisePage(exerciseID: null, pageID: pages.length + 1));
              currentPageIndex = pages.length;

              setState(() {
                pageController.jumpToPage(currentPageIndex);
              });
            },
            icon: const FlexusDefaultIcon(iconData: Icons.add),
          ),
          TextButton(
            onPressed: () {
              //Post and Finish Workout
              
              if (widget.gym != null) {
                userBox.put("currentGym", widget.gym);
              }
              if (widget.plan != null) {
                userBox.put("currentPlan", widget.plan);
              }
              if (widget.split != null) {
                userBox.put("currentSplit", widget.split);
              }
              Navigator.pop(context);
            },
            child: const CustomDefaultTextStyle(text: "Finish"),
          ),
        ],
      ),
      body: PageView(
        onPageChanged: (value) => {
          setState(() {
            currentPageIndex = value;
          }),
        },
        controller: pageController,
        children: pages,
      ),
      floatingActionButton: FlexusFloatingActionButton(
        icon: Icons.timer_outlined,
        onPressed: () async {
          dynamic result = await Navigator.push(
            context,
            PageTransition(
              type: PageTransitionType.fade,
              child: const TimerPage(),
            ),
          );

          debugPrint("Timer value: $result");
        },
      ),
    );
  }
}

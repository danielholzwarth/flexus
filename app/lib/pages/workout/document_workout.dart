import 'package:app/bloc/exercise_bloc/exercise_bloc.dart';
import 'package:app/hive/gym/gym.dart';
import 'package:app/hive/plan/plan.dart';
import 'package:app/hive/split/split.dart';
import 'package:app/pages/workout/document_exercise.dart';
import 'package:app/pages/workout/timer.dart';
import 'package:app/resources/app_settings.dart';
import 'package:app/widgets/buttons/flexus_floating_action_button.dart';
import 'package:app/widgets/style/flexus_default_icon.dart';
import 'package:app/widgets/style/flexus_default_text_style.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  final ExerciseBloc exerciseBloc = ExerciseBloc();

  final PageController pageController = PageController();
  int currentPageIndex = 0;
  int exerciseLength = 4;

  List<Widget> pages = [];

  bool hasCurrentWorkout = false;

  @override
  void initState() {
    if (hasCurrentWorkout) {
      //Get Local Workout Data
    } else {
      if (widget.split != null) {
        exerciseBloc.add(GetExercisesFromSplitID(splitID: widget.split!.id));
      } else {
        pages.add(const DocumentExercisePage(exercise: null, pageID: 1));
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
          text: widget.split != null ? widget.split!.name : "Custom Workout",
          fontSize: AppSettings.fontSizeH3,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              pages.add(DocumentExercisePage(exercise: null, pageID: pages.length + 1));
              currentPageIndex = pages.length;

              setState(() {
                pageController.animateToPage(currentPageIndex - 1, duration: Duration(seconds: 1), curve: Curves.easeInOut);
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
      body: BlocConsumer(
        bloc: exerciseBloc,
        listener: (context, state) {
          if (state is ExercisesFromSplitIDLoaded) {
            for (int i = 0; i <= state.exercises.length - 1; i++) {
              pages.add(DocumentExercisePage(exercise: state.exercises[i], pageID: i + 1));
            }
          }
        },
        builder: (context, state) {
          if (state is ExercisesLoading) {
            return Center(child: CircularProgressIndicator(color: AppSettings.primary));
          } else {
            return PageView(
              scrollBehavior: const CupertinoScrollBehavior(),
              onPageChanged: (value) => {
                setState(() {
                  currentPageIndex = value;
                }),
              },
              controller: pageController,
              children: pages,
            );
          }
        },
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

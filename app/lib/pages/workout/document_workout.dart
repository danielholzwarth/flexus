import 'package:app/bloc/exercise_bloc/exercise_bloc.dart';
import 'package:app/bloc/workout_bloc/workout_bloc.dart';
import 'package:app/hive/exercise/current_exercise.dart';
import 'package:app/hive/exercise/exercise.dart';
import 'package:app/hive/gym/gym.dart';
import 'package:app/hive/plan/current_plan.dart';
import 'package:app/hive/workout/current_workout.dart';
import 'package:app/hive/workout/measurement.dart';
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
    this.currentPlan,
  });

  final Gym? gym;
  final CurrentPlan? currentPlan;

  @override
  State<DocumentWorkoutPage> createState() => _DocumentWorkoutPageState();
}

class _DocumentWorkoutPageState extends State<DocumentWorkoutPage> {
  final userBox = Hive.box('userBox');
  final ExerciseBloc exerciseBloc = ExerciseBloc();
  final WorkoutBloc workoutBloc = WorkoutBloc();

  final PageController pageController = PageController();
  int currentPageIndex = 0;

  List<Widget> pages = List.empty(growable: true);

  CurrentWorkout? currentWorkout;

  @override
  void initState() {
    CurrentWorkout? workout = userBox.get("currentWorkout");

    if (workout != null) {
      currentWorkout = workout;

      for (int i = 0; i <= currentWorkout!.exercises.length - 1; i++) {
        pages.add(DocumentExercisePage(pageID: i + 1));
      }
    } else {
      if (widget.currentPlan != null) {
        if (widget.currentPlan!.splits.isNotEmpty) {
          exerciseBloc.add(GetExercisesFromSplitID(splitID: widget.currentPlan!.splits[widget.currentPlan!.currentSplit].id));
        } else {
          pages.add(const DocumentExercisePage(pageID: 1));
          currentWorkout =
              CurrentWorkout(exercises: [CurrentExercise(exercise: Exercise(id: 0, name: "", typeID: 0), oldMeasurements: [], measurements: [])]);
          userBox.put("currentWorkout", currentWorkout);
        }
      } else {
        pages.add(const DocumentExercisePage(pageID: 1));
        currentWorkout =
            CurrentWorkout(exercises: [CurrentExercise(exercise: Exercise(id: 0, name: "", typeID: 0), oldMeasurements: [], measurements: [])]);
        userBox.put("currentWorkout", currentWorkout);
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
          text: getPlanName(),
          fontSize: AppSettings.fontSizeH3,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              pages.add(DocumentExercisePage(pageID: pages.length + 1));

              if (currentWorkout != null) {
                currentWorkout!.exercises.add(CurrentExercise(
                  exercise: Exercise(id: 0, name: "", typeID: 0),
                  oldMeasurements: [],
                  measurements: [],
                ));
              }

              setState(() {
                pageController.animateToPage(pages.length - 1, duration: const Duration(seconds: 1), curve: Curves.easeInOut);
              });
            },
            icon: const FlexusDefaultIcon(iconData: Icons.add),
          ),
          TextButton(
            onPressed: () {
              CurrentWorkout? currentWorkout = userBox.get("currentWorkout");

              if (currentWorkout != null) {
                CurrentWorkout finishedCurrentWorkout =
                    CurrentWorkout(gym: currentWorkout.gym, plan: currentWorkout.plan, split: currentWorkout.split, exercises: []);

                for (var ex in currentWorkout.exercises) {
                  CurrentExercise current = CurrentExercise(exercise: ex.exercise, oldMeasurements: ex.oldMeasurements, measurements: []);
                  for (var m in ex.measurements) {
                    if (m.workload > 0) {
                      current.measurements.add(Measurement(repetitions: m.repetitions > 0 ? m.repetitions : 1, workload: m.workload));
                    }
                  }
                  finishedCurrentWorkout.exercises.add(current);
                }

                workoutBloc.add(PatchWorkout(
                  workoutID: -1,
                  name: "finishWorkout",
                  currentWorkout: finishedCurrentWorkout,
                ));
                if (widget.gym != null) {
                  userBox.put("currentGym", widget.gym);
                }
                if (widget.currentPlan != null) {
                  userBox.put("currentPlan", widget.currentPlan);
                }
                userBox.delete("currentWorkout");

                Navigator.pop(context);
              } else {
                debugPrint('Null?');
              }
            },
            child: const CustomDefaultTextStyle(text: "Finish"),
          ),
        ],
      ),
      body: BlocConsumer(
        bloc: exerciseBloc,
        listener: (context, state) {
          if (state is ExercisesFromSplitIDLoaded) {
            List<CurrentExercise> currentExercises = [];

            if (state.currentExercises.isNotEmpty) {
              for (int i = 0; i <= state.currentExercises.length - 1; i++) {
                pages.add(DocumentExercisePage(pageID: i + 1));
                currentExercises.add(CurrentExercise(
                    exercise: state.currentExercises[i].exercise, oldMeasurements: state.currentExercises[i].oldMeasurements, measurements: []));
              }
            } else {
              pages.add(const DocumentExercisePage(pageID: 1));
              currentExercises.add(CurrentExercise(exercise: Exercise(id: 0, name: "", typeID: 0), oldMeasurements: [], measurements: []));
            }

            currentWorkout = CurrentWorkout(
              gym: widget.gym,
              plan: widget.currentPlan?.plan,
              split: widget.currentPlan != null ? widget.currentPlan!.splits[widget.currentPlan!.currentSplit] : null,
              exercises: currentExercises,
            );

            userBox.put("currentWorkout", currentWorkout);
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
      floatingActionButton: buildFloatingActionButton(),
    );
  }

  Widget buildFloatingActionButton() {
    return FlexusFloatingActionButton(
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
    );
  }

  String getPlanName() {
    if (widget.currentPlan != null) {
      if (widget.currentPlan!.splits.isNotEmpty) {
        return widget.currentPlan!.splits[widget.currentPlan!.currentSplit].name;
      }
    } else if (currentWorkout != null) {
      if (currentWorkout!.split != null) {
        return currentWorkout!.split!.name;
      }
    }
    return "Custom Workout";
  }
}

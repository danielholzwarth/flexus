// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:app/bloc/exercise_bloc/exercise_bloc.dart';
import 'package:app/bloc/workout_bloc/workout_bloc.dart';
import 'package:app/hive/exercise/current_exercise.dart';
import 'package:app/hive/exercise/exercise.dart';
import 'package:app/hive/gym/gym.dart';
import 'package:app/hive/plan/current_plan.dart';
import 'package:app/hive/timer/timer_value.dart';
import 'package:app/hive/workout/current_workout.dart';
import 'package:app/hive/workout/measurement.dart';
import 'package:app/pages/home/pageview.dart';
import 'package:app/pages/workout/document_exercise.dart';
import 'package:app/pages/workout/finish_workout.dart';
import 'package:app/pages/workout/timer.dart';
import 'package:app/resources/app_settings.dart';
import 'package:app/widgets/buttons/flexus_floating_action_button.dart';
import 'package:app/widgets/error/flexus_error.dart';
import 'package:app/widgets/style/flexus_default_icon.dart';
import 'package:app/widgets/style/flexus_default_text_style.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:page_transition/page_transition.dart';

class DocumentWorkoutPage extends StatefulWidget {
  final Gym? gym;
  final CurrentPlan? currentPlan;

  const DocumentWorkoutPage({
    super.key,
    this.gym,
    this.currentPlan,
  });

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
  Timer? timer;
  TimerValue timerValue = TimerValue(isRunning: false, milliseconds: 0);
  Duration timerDuration = Duration.zero;

  final ConfettiController confettiController = ConfettiController(duration: Durations.extralong1);

  @override
  void initState() {
    super.initState();
    buildPages();
  }

  @override
  void dispose() async {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Scaffold(
          backgroundColor: AppSettings.background,
          appBar: buildAppBar(context),
          body: buildBody(),
          floatingActionButton: timerValue.isRunning
              ? buildFloatingTimerButton()
              : currentPageIndex < pages.length - 1
                  ? buildFloatingActionButton()
                  : null,
        ),
        ConfettiWidget(
          confettiController: confettiController,
          blastDirectionality: BlastDirectionality.explosive,
          minBlastForce: 1,
          shouldLoop: true,
          maxBlastForce: 30,
          numberOfParticles: 20,
        ),
      ],
    );
  }

  Widget buildBody() {
    return BlocConsumer(
      bloc: workoutBloc,
      listener: (context, state) async {
        if (state is! WorkoutUpdating && state is! WorkoutInitial) {
          confettiController.play();

          await Future.delayed(Durations.extralong2);

          if (widget.gym != null) {
            userBox.put("currentGym", widget.gym);
          }
          if (widget.currentPlan != null) {
            userBox.put("currentPlan", widget.currentPlan);
          }
          userBox.delete("currentWorkout");
          userBox.delete("timerValue");

          Navigator.pushReplacement(
            context,
            PageTransition(
              type: PageTransitionType.fade,
              child: const PageViewPage(),
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is WorkoutUpdating || state is WorkoutInitial) {
          return BlocConsumer(
            bloc: exerciseBloc,
            listener: (context, state) {
              if (state is CurrentExercisesFromSplitIDLoaded) {
                List<CurrentExercise> currentExercises = [];

                if (state.currentExercises.isNotEmpty) {
                  for (int i = 0; i <= state.currentExercises.length - 1; i++) {
                    pages.add(DocumentExercisePage(pageID: i + 1));
                    currentExercises.add(CurrentExercise(
                        exercise: state.currentExercises[i].exercise, oldMeasurements: state.currentExercises[i].oldMeasurements, measurements: []));
                  }
                }

                if (pages.isEmpty) {
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

                pages.add(const FinishWorkoutPage());
                setState(() {});
              }
            },
            builder: (context, state) {
              if (state is ExerciseInitial && pages.isEmpty) {
                return Center(child: CircularProgressIndicator(color: AppSettings.primary));
              }

              if (state is ExerciseError) {
                return FlexusError(
                  text: state.error,
                  func: () {
                    buildPages();
                    setState(() {});
                  },
                );
              }

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
            },
          );
        }

        if (state is! WorkoutUpdating && state is! WorkoutInitial) {
          return const Center();
        }

        return Center(child: CircularProgressIndicator(color: AppSettings.primary));
      },
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppSettings.background,
      title: CustomDefaultTextStyle(
        text: getPlanName(),
        fontSize: AppSettings.fontSizeH3,
      ),
      centerTitle: true,
      actions: [
        if (currentPageIndex < pages.length - 1)
          IconButton(
            onPressed: () {
              pages.remove(pages.last);

              pages.add(DocumentExercisePage(pageID: pages.length + 1));

              if (currentWorkout != null) {
                currentWorkout!.exercises.add(CurrentExercise(
                  exercise: Exercise(id: 0, name: "", typeID: 0),
                  oldMeasurements: [],
                  measurements: [],
                ));

                pages.add(const FinishWorkoutPage());
              }
              pageController.jumpToPage(currentPageIndex);

              setState(() {
                pageController.animateToPage(pages.length - 2, duration: const Duration(seconds: 1), curve: Curves.easeInOut);
              });
            },
            icon: const FlexusDefaultIcon(iconData: Icons.add),
          ),
        if (currentPageIndex < pages.length - 1)
          TextButton(
            onPressed: () async {
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
              } else {
                debugPrint('Null?');
              }
            },
            child: const CustomDefaultTextStyle(text: "Finish"),
          )
      ],
    );
  }

  void buildPages() {
    CurrentWorkout? workout = userBox.get("currentWorkout");

    if (workout != null) {
      currentWorkout = workout;

      for (int i = 0; i <= currentWorkout!.exercises.length - 1; i++) {
        pages.add(DocumentExercisePage(pageID: i + 1));
      }
      pages.add(const FinishWorkoutPage());
    } else {
      if (widget.currentPlan != null) {
        if (widget.currentPlan!.splits.isNotEmpty) {
          exerciseBloc.add(GetCurrentExercisesFromSplitID(
            splitID: widget.currentPlan!.splits[widget.currentPlan!.currentSplit].id,
            currentPlan: widget.currentPlan!,
          ));
        } else {
          pages.add(const DocumentExercisePage(pageID: 1));
          currentWorkout =
              CurrentWorkout(exercises: [CurrentExercise(exercise: Exercise(id: 0, name: "", typeID: 0), oldMeasurements: [], measurements: [])]);
          userBox.put("currentWorkout", currentWorkout);
          pages.add(const FinishWorkoutPage());
        }
      } else {
        pages.add(const DocumentExercisePage(pageID: 1));
        currentWorkout =
            CurrentWorkout(exercises: [CurrentExercise(exercise: Exercise(id: 0, name: "", typeID: 0), oldMeasurements: [], measurements: [])]);
        userBox.put("currentWorkout", currentWorkout);
        pages.add(const FinishWorkoutPage());
      }
    }
  }

  Widget buildFloatingActionButton() {
    return FlexusFloatingActionButton(
      icon: Icons.timer_outlined,
      onPressed: () async {
        FocusManager.instance.primaryFocus?.unfocus();

        if (timerValue.isRunning) {
          timerValue.milliseconds = timerDuration.inMilliseconds;
        }

        dynamic val = await Navigator.push(
          context,
          PageTransition(
            type: PageTransitionType.fade,
            child: TimerPage(timerValue: timerValue),
          ),
        );
        if (val != null) {
          timerValue = val;
          timerDuration = Duration(milliseconds: timerValue.milliseconds);
          if (timerValue.isRunning && timerValue.milliseconds > 0) {
            timer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
              setState(() {
                timerDuration = timerDuration += const Duration(milliseconds: 10);
              });
            });
          } else {
            userBox.put("timerValue", timerDuration.inMilliseconds);
            timerValue.milliseconds = 0;
          }
        }
      },
    );
  }

  Widget buildFloatingTimerButton() {
    return FloatingActionButton.extended(
      elevation: AppSettings.elevation,
      backgroundColor: AppSettings.primary,
      label: CustomDefaultTextStyle(
        text: formatTime(timerDuration),
        color: AppSettings.fontV1,
        fontSize: AppSettings.fontSizeH4,
      ),
      onPressed: () async {
        FocusManager.instance.primaryFocus?.unfocus();

        if (timerValue.isRunning) {
          timerValue.milliseconds = timerDuration.inMilliseconds;
        }

        dynamic val = await Navigator.push(
          context,
          PageTransition(
            type: PageTransitionType.fade,
            child: TimerPage(timerValue: timerValue),
          ),
        );
        if (val != null) {
          timerValue = val;
          timerDuration = Duration(milliseconds: timerValue.milliseconds);
          if (!timerValue.isRunning) {
            userBox.put("timerValue", timerDuration.inMilliseconds);
            timerValue.milliseconds = 0;
          }
        }
      },
    );
  }

  String formatTime(Duration duration) {
    String minutesString = duration.inMinutes >= 1 ? "${duration.inMinutes.toString().padLeft(1, '0')}:" : "";
    String secondsString = (duration.inSeconds % 60).toString().padLeft(2, '0');
    String millisecondsString = ((duration.inMilliseconds % 1000) ~/ 10).toString().padLeft(2, '0');

    return "$minutesString$secondsString:$millisecondsString";
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

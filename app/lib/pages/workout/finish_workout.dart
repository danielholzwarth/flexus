// ignore_for_file: use_build_context_synchronously

import 'package:app/bloc/workout_bloc/workout_bloc.dart';
import 'package:app/hive/exercise/current_exercise.dart';
import 'package:app/hive/gym/gym.dart';
import 'package:app/hive/plan/current_plan.dart';
import 'package:app/hive/workout/current_workout.dart';
import 'package:app/hive/workout/measurement.dart';
import 'package:app/pages/home/pageview.dart';
import 'package:app/resources/app_settings.dart';
import 'package:app/widgets/buttons/flexus_button.dart';
import 'package:app/widgets/style/flexus_basic_title.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:page_transition/page_transition.dart';

class FinishWorkoutPage extends StatefulWidget {
  final Gym? gym;
  final CurrentPlan? currentPlan;

  const FinishWorkoutPage({
    super.key,
    this.gym,
    this.currentPlan,
  });

  @override
  State<FinishWorkoutPage> createState() => _FinishWorkoutPageState();
}

class _FinishWorkoutPageState extends State<FinishWorkoutPage> {
  final userBox = Hive.box('userBox');
  final WorkoutBloc workoutBloc = WorkoutBloc();

  final ConfettiController confettiController = ConfettiController(duration: Durations.extralong1);

  @override
  Widget build(BuildContext context) {
    Size deviceSize = MediaQuery.of(context).size;

    return Stack(
      alignment: Alignment.center,
      children: [
        Scaffold(
          backgroundColor: AppSettings.background,
          body: BlocConsumer(
            bloc: workoutBloc,
            listener: (context, state) async {
              if (state is! WorkoutUpdating && state is! WorkoutInitial) {
                confettiController.play();

                await Future.delayed(Durations.extralong2);

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
              if (state is WorkoutInitial) {
                return Center(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        FlexusBasicTitle(
                          deviceSize: deviceSize,
                          text: "Finish Workout?",
                          hasPadding: false,
                        ),
                        SizedBox(height: deviceSize.height * 0.05),
                        FlexusButton(
                          text: "Finish",
                          function: () {
                            CurrentWorkout? currentWorkout = userBox.get("currentWorkout");

                            if (currentWorkout != null) {
                              CurrentWorkout finishedCurrentWorkout =
                                  CurrentWorkout(gym: currentWorkout.gym, plan: currentWorkout.plan, split: currentWorkout.split, exercises: []);

                              for (var ex in currentWorkout.exercises) {
                                CurrentExercise current =
                                    CurrentExercise(exercise: ex.exercise, oldMeasurements: ex.oldMeasurements, measurements: []);
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
                              userBox.delete("timerValue");
                            } else {
                              debugPrint('Null?');
                            }
                          },
                          fontColor: AppSettings.fontV1,
                          backgroundColor: AppSettings.primary,
                        ),
                      ],
                    ),
                  ),
                );
              }
              if (state is! WorkoutUpdating && state is! WorkoutInitial) {
                return const Center();
              }
              return Center(child: CircularProgressIndicator(color: AppSettings.primary));
            },
          ),
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
}

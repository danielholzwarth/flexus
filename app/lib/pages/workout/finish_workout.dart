import 'package:app/bloc/workout_bloc/workout_bloc.dart';
import 'package:app/hive/exercise/current_exercise.dart';
import 'package:app/hive/gym/gym.dart';
import 'package:app/hive/plan/current_plan.dart';
import 'package:app/hive/workout/current_workout.dart';
import 'package:app/hive/workout/measurement.dart';
import 'package:app/resources/app_settings.dart';
import 'package:app/widgets/buttons/flexus_button.dart';
import 'package:app/widgets/style/flexus_basic_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

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
  // int workoutTimeInSeconds = 0;

  // @override
  // void initState() {
  //   super.initState();
  //   DateTime? workoutStartTime = userBox.get("currentWorkoutStartTime");
  //   if (workoutStartTime != null) {
  //     workoutTimeInSeconds = DateTime.now().difference(workoutStartTime).inSeconds;
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    Size deviceSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppSettings.background,
      body: BlocConsumer(
        bloc: workoutBloc,
        listener: (context, state) {
          if (state is! WorkoutUpdating && state is! WorkoutInitial) {
            Navigator.pop(context, true);
          }
        },
        builder: (context, state) {
          if (state is WorkoutUpdating) {
            return Center(child: CircularProgressIndicator(color: AppSettings.primary));
          }
          return Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  FlexusBasicTitle(
                    deviceSize: deviceSize,
                    text: "Finish Workout?",
                    hasPadding: false,
                  ),
                  // SizedBox(height: deviceSize.height * 0.05),
                  // CustomDefaultTextStyle(
                  //   text: "Workout Time: ${formatTime(Duration(seconds: workoutTimeInSeconds))}",
                  //   fontSize: AppSettings.fontSizeH4,
                  // ),
                  // SizedBox(height: deviceSize.height * 0.02),
                  // CustomDefaultTextStyle(
                  //   text: "Exercises completed: ",
                  //   fontSize: AppSettings.fontSizeH4,
                  // ),
                  SizedBox(height: deviceSize.height * 0.05),
                  FlexusButton(
                    text: "Finish",
                    function: () {
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
        },
      ),
    );
  }

  // String formatTime(Duration duration) {
  //   String hoursString = duration.inHours >= 1 ? "${duration.inHours.toString().padLeft(2, '0')}:" : "";
  //   String minutesString = duration.inMinutes >= 1 ? "${duration.inMinutes.toString().padLeft(2, '0')}:" : "";
  //   String secondsString = (duration.inSeconds % 60).toString().padLeft(2, '0');

  //   return "$hoursString$minutesString$secondsString";
  // }
}

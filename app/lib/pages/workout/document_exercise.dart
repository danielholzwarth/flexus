import 'package:app/hive/exercise/current_exercise.dart';
import 'package:app/hive/workout/current_workout.dart';
import 'package:app/hive/workout/measurement.dart';
import 'package:app/resources/app_settings.dart';
import 'package:app/search_delegates/exercise_search_delegate.dart';
import 'package:app/widgets/buttons/flexus_button.dart';
import 'package:app/widgets/flexus_textfield.dart';
import 'package:app/widgets/style/flexus_basic_title.dart';
import 'package:app/widgets/style/flexus_default_icon.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class DocumentExercisePage extends StatefulWidget {
  const DocumentExercisePage({
    super.key,
    required this.pageID,
  });

  final int pageID;

  @override
  State<DocumentExercisePage> createState() => _DocumentExercisePageState();
}

class _DocumentExercisePageState extends State<DocumentExercisePage> with AutomaticKeepAliveClientMixin<DocumentExercisePage> {
  final userBox = Hive.box('userBox');

  bool isRepetition = false;
  final setsGoalController = TextEditingController();
  final repsGoalController = TextEditingController();
  final weightGoalController = TextEditingController();
  final durationGoalController = TextEditingController();

  int setCount = 0;
  List<Map<String, TextEditingController>> setController = [];

  CurrentExercise? currentExercise;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    CurrentWorkout? currentWorkout = userBox.get("currentWorkout");
    if (currentWorkout != null) {
      currentExercise = currentWorkout.exercises[widget.pageID - 1];
    }

    Size deviceSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppSettings.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            buildExercise(context, deviceSize),
            buildGoal(deviceSize),
            SizedBox(height: deviceSize.height * 0.05),
            buildSets(deviceSize),
          ],
        ),
      ),
    );
  }

  Widget buildExercise(BuildContext context, Size deviceSize) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        FlexusBasicTitle(deviceSize: deviceSize, text: "Exercise ${widget.pageID}"),
        FlexusButton(
          text: currentExercise != null
              ? currentExercise!.exercise.id != 0
                  ? currentExercise!.exercise.name
                  : "Pick Exercise"
              : "Pick Exercise",
          fontColor: currentExercise != null
              ? currentExercise!.exercise.id != 0
                  ? AppSettings.font
                  : AppSettings.primary
              : AppSettings.primary,
          function: () async {
            dynamic pickedExercise = await showSearch(context: context, delegate: ExerciseSearchDelegate(isMultipleChoice: false));
            if (pickedExercise != null) {
              //Get Full Details of Exercise
              if (currentExercise != null) {
                currentExercise!.exercise = pickedExercise;
              } else {
                currentExercise = CurrentExercise(exercise: pickedExercise, goal: "goal", measurements: []);
              }
              setState(() {});
            }
          },
          width: deviceSize.width * 0.9,
        ),
      ],
    );
  }

  Widget buildGoal(Size deviceSize) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: deviceSize.width * 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FlexusBasicTitle(deviceSize: deviceSize, text: "Goal"),
          isRepetition
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    FlexusTextField(
                      hintText: "Sets",
                      textController: setsGoalController,
                      width: deviceSize.width * 0.25,
                      textInputType: TextInputType.number,
                      onChanged: (String newValue) {
                        setState(() {});
                      },
                    ),
                    FlexusTextField(
                      hintText: "Reps",
                      textController: repsGoalController,
                      width: deviceSize.width * 0.25,
                      textInputType: TextInputType.number,
                      onChanged: (String newValue) {
                        setState(() {});
                      },
                    ),
                    FlexusTextField(
                      hintText: "Weigth",
                      textController: weightGoalController,
                      width: deviceSize.width * 0.25,
                      textInputType: TextInputType.number,
                      onChanged: (String newValue) {
                        setState(() {});
                      },
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    FlexusTextField(
                      hintText: "Sets",
                      textController: setsGoalController,
                      width: deviceSize.width * 0.4,
                      textInputType: TextInputType.number,
                      onChanged: (String newValue) {
                        setState(() {});
                      },
                    ),
                    FlexusTextField(
                      hintText: "Duration",
                      textController: durationGoalController,
                      width: deviceSize.width * 0.4,
                      textInputType: TextInputType.number,
                      onChanged: (String newValue) {
                        setState(() {});
                      },
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  Widget buildSets(Size deviceSize) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        for (int i = 0; i < setCount; i++)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: deviceSize.width * 0.05),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                FlexusBasicTitle(deviceSize: deviceSize, text: "Set X"),
                isRepetition
                    ? FlexusTextField(
                        hintText: "Reps",
                        textController: setController[i]["reps"]!,
                        width: deviceSize.width * 0.25,
                        textInputType: TextInputType.number,
                        onChanged: (String newValue) {
                          setState(() {});
                        },
                      )
                    : Container(),
                isRepetition
                    ? FlexusTextField(
                        hintText: "Weigth",
                        textController: setController[i]["weight"]!,
                        width: deviceSize.width * 0.25,
                        textInputType: TextInputType.number,
                        onChanged: (String newValue) {
                          setState(() {});
                        },
                      )
                    : Container(),
                !isRepetition
                    ? FlexusTextField(
                        hintText: "Duration",
                        textController: setController[i]["duration"]!,
                        width: deviceSize.width * 0.4,
                        textInputType: TextInputType.number,
                        onChanged: (String newValue) {
                          setState(() {});
                        },
                      )
                    : Container(),
              ],
            ),
          ),
        SizedBox(height: deviceSize.height * 0.02),
        IconButton(
          onPressed: () {
            setController.add({
              "reps": TextEditingController(),
              "weight": TextEditingController(),
              "duration": TextEditingController(),
            });

            // if (currentExercise != null) {
            currentExercise!.measurements.add(Measurement(repetitions: 0, workload: 0));
            // } else {
            //   currentExercise = CurrentExercise(exercise: exercise, goal: goal, measurements: measurements)
            // }

            setState(() {
              setCount += 1;
            });
          },
          icon: FlexusDefaultIcon(
            iconData: Icons.add,
            iconColor: AppSettings.primary,
            iconSize: AppSettings.fontSizeH2,
          ),
        )
      ],
    );
  }
}

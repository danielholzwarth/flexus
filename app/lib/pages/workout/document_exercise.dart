import 'package:app/bloc/exercise_bloc/exercise_bloc.dart';
import 'package:app/hive/exercise/current_exercise.dart';
import 'package:app/hive/exercise/exercise.dart';
import 'package:app/hive/workout/current_workout.dart';
import 'package:app/hive/workout/measurement.dart';
import 'package:app/resources/app_settings.dart';
import 'package:app/search_delegates/exercise_search_delegate.dart';
import 'package:app/widgets/buttons/flexus_button.dart';
import 'package:app/widgets/buttons/flexus_button_small.dart';
import 'package:app/widgets/flexus_table_textfield.dart';
import 'package:app/widgets/style/flexus_basic_title.dart';
import 'package:app/widgets/style/flexus_default_icon.dart';
import 'package:app/widgets/style/flexus_default_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  final ExerciseBloc exerciseBloc = ExerciseBloc();
  List<Map<String, TextEditingController>> setController = [];
  CurrentExercise? currentExercise;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    initController();

    Size deviceSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppSettings.background,
      body: buildBody(deviceSize),
    );
  }

  Widget buildBody(Size deviceSize) {
    return SingleChildScrollView(
      child: BlocConsumer(
        bloc: exerciseBloc,
        listener: (context, state) {
          if (state is CurrentExerciseFromExerciseIDLoaded) {
            if (currentExercise != null) {
              setController.clear();

              currentExercise = state.currentExercise;

              CurrentWorkout? currentWorkout = userBox.get("currentWorkout");
              if (currentWorkout != null) {
                currentWorkout.exercises[widget.pageID - 1] = currentExercise!;

                userBox.put("currentWorkout", currentWorkout);
              }
            }
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              buildExercise(context, deviceSize),
              currentExercise != null && currentExercise!.exercise.id != 0 ? buildOldMeasurements(deviceSize) : Container(),
              currentExercise != null && currentExercise!.exercise.id != 0 ? buildSets(deviceSize) : Container(),
            ],
          );
        },
      ),
    );
  }

  void initController() {
    CurrentWorkout? currentWorkout = userBox.get("currentWorkout");
    if (currentWorkout != null) {
      currentExercise = currentWorkout.exercises[widget.pageID - 1];

      if (setController.isEmpty) {
        for (int i = 0; i <= currentExercise!.measurements.length - 1; i++) {
          if (currentExercise!.exercise.typeID == 1) {
            setController.add({
              "reps": TextEditingController(
                  text: currentExercise!.measurements[i].repetitions > 0 ? currentExercise!.measurements[i].repetitions.toString() : null),
              "workload": TextEditingController(
                  text: currentExercise!.measurements[i].workload > 0 ? currentExercise!.measurements[i].workload.toString() : null),
            });
          } else {
            setController.add({
              "workload": TextEditingController(
                  text: currentExercise!.measurements[i].workload > 0 ? currentExercise!.measurements[i].workload.toString() : null),
            });
          }
        }
      }
    }
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
              if (currentExercise != null) {
                if (currentExercise!.exercise != pickedExercise) {
                  Exercise ex = pickedExercise;
                  exerciseBloc.add(GetCurrentExerciseFromExerciseID(exerciseID: ex.id));
                }
              } else {
                Exercise ex = pickedExercise;
                exerciseBloc.add(GetCurrentExerciseFromExerciseID(exerciseID: ex.id));
              }

              setState(() {});
            }
          },
          width: deviceSize.width * 0.9,
        ),
      ],
    );
  }

  Widget buildOldMeasurements(Size deviceSize) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.only(top: deviceSize.height * 0.03),
          child: ExpansionTile(
            initiallyExpanded: true,
            tilePadding: EdgeInsets.symmetric(horizontal: deviceSize.width * 0.05),
            expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
            shape: InputBorder.none,
            title: Row(
              children: [
                FlexusBasicTitle(
                  deviceSize: deviceSize,
                  text: "Last workout",
                  hasPadding: false,
                ),
                IconButton(
                  onPressed: () {
                    for (var oldMeasurement in currentExercise!.oldMeasurements) {
                      if (currentExercise != null) {
                        setController.add({
                          "reps": TextEditingController(text: oldMeasurement.repetitions.toString()),
                          "workload": TextEditingController(text: oldMeasurement.workload.toString()),
                        });

                        currentExercise!.measurements.add(Measurement(
                          repetitions: oldMeasurement.repetitions,
                          workload: oldMeasurement.workload,
                        ));

                        CurrentWorkout? currentWorkout = userBox.get("currentWorkout");
                        if (currentWorkout != null) {
                          currentWorkout.exercises[widget.pageID - 1] = currentExercise!;

                          userBox.put("currentWorkout", currentWorkout);
                        }

                        setState(() {});
                      }
                    }
                  },
                  icon: FlexusDefaultIcon(
                    iconData: Icons.copy,
                    iconSize: AppSettings.fontSizeH4,
                  ),
                ),
              ],
            ),
            children: [
              currentExercise!.oldMeasurements.isEmpty
                  ? Center(
                      child: SizedBox(
                        width: deviceSize.width * 0.4,
                        child: const CustomDefaultTextStyle(
                          text: "No old data found",
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : currentExercise!.exercise.typeID == 1
                      ? DataTable(
                          columns: const [
                            DataColumn(label: CustomDefaultTextStyle(text: "Sets", textAlign: TextAlign.left)),
                            DataColumn(label: CustomDefaultTextStyle(text: "Repetitions", textAlign: TextAlign.left)),
                            DataColumn(label: CustomDefaultTextStyle(text: "Workload (kg)", textAlign: TextAlign.left)),
                          ],
                          rows: [
                            for (int i = 0; i <= currentExercise!.oldMeasurements.length - 1; i++)
                              DataRow(
                                cells: [
                                  DataCell(
                                    SizedBox(
                                      width: deviceSize.width * 0.15,
                                      child: CustomDefaultTextStyle(
                                        text: "Set ${i + 1}",
                                        textAlign: TextAlign.left,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    SizedBox(
                                      width: deviceSize.width * 0.15,
                                      child: CustomDefaultTextStyle(
                                        text: currentExercise!.oldMeasurements[i].repetitions.toString(),
                                        textAlign: TextAlign.left,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    SizedBox(
                                      width: deviceSize.width * 0.15,
                                      child: CustomDefaultTextStyle(
                                        text: "${currentExercise!.oldMeasurements[i].workload}kg",
                                        textAlign: TextAlign.left,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        )
                      : DataTable(
                          columns: const [
                            DataColumn(label: CustomDefaultTextStyle(text: "Sets", textAlign: TextAlign.left)),
                            DataColumn(label: CustomDefaultTextStyle(text: "Duration (s)", textAlign: TextAlign.left)),
                          ],
                          rows: [
                            for (int i = 0; i <= currentExercise!.oldMeasurements.length - 1; i++)
                              DataRow(
                                cells: [
                                  DataCell(
                                    SizedBox(
                                      width: deviceSize.width * 0.15,
                                      child: CustomDefaultTextStyle(
                                        text: "Set ${i + 1}",
                                        textAlign: TextAlign.left,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    SizedBox(
                                      width: deviceSize.width * 0.15,
                                      child: CustomDefaultTextStyle(
                                        text: "${currentExercise!.oldMeasurements[i].workload}s",
                                        textAlign: TextAlign.left,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildSets(Size deviceSize) {
    if (currentExercise != null && currentExercise!.measurements.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: deviceSize.width * 0.05),
            child: Row(
              children: [
                FlexusBasicTitle(
                  deviceSize: deviceSize,
                  text: "Current Workout",
                  hasPadding: true,
                ),
              ],
            ),
          ),
          currentExercise!.exercise.typeID == 1
              ? DataTable(
                  columnSpacing: 0,
                  horizontalMargin: deviceSize.width * 0.05,
                  columns: const [
                    DataColumn(label: CustomDefaultTextStyle(text: "Sets", textAlign: TextAlign.left)),
                    DataColumn(label: CustomDefaultTextStyle(text: "Repetitions", textAlign: TextAlign.left)),
                    DataColumn(label: CustomDefaultTextStyle(text: "Workload (kg)", textAlign: TextAlign.left)),
                  ],
                  rows: [
                    for (int i = 0; i <= currentExercise!.measurements.length - 1; i++)
                      DataRow(
                        onLongPress: () => {
                          showModalBottomSheet(
                            context: context,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
                            ),
                            builder: (BuildContext context) {
                              return Container(
                                padding: EdgeInsets.only(top: deviceSize.height * 0.05),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CustomDefaultTextStyle(
                                      text: "Delete Set ${i + 1}?",
                                      fontSize: AppSettings.fontSizeH3,
                                    ),
                                    SizedBox(height: deviceSize.height * 0.03),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        FlexusButtonSmall(
                                          text: "Cancel",
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                        ),
                                        FlexusButtonSmall(
                                          text: "Delete",
                                          fontColor: AppSettings.error,
                                          onPressed: () {
                                            if (currentExercise != null) {
                                              setController.removeAt(i);

                                              currentExercise!.measurements.removeAt(i);

                                              CurrentWorkout? currentWorkout = userBox.get("currentWorkout");
                                              if (currentWorkout != null) {
                                                currentWorkout.exercises[widget.pageID - 1] = currentExercise!;

                                                userBox.put("currentWorkout", currentWorkout);
                                              }

                                              setState(() {});
                                              Navigator.pop(context);
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: deviceSize.height * 0.05),
                                  ],
                                ),
                              );
                            },
                          ),
                        },
                        cells: [
                          DataCell(
                            SizedBox(
                              child: CustomDefaultTextStyle(
                                text: "Set ${i + 1}",
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ),
                          DataCell(
                            FlexusTableTextField(
                              hintText: "Reps",
                              textAlign: TextAlign.left,
                              textController: setController[i]["reps"]!,
                              textInputType: TextInputType.number,
                              onTapOutside: (p0) {
                                FocusManager.instance.primaryFocus?.unfocus();
                              },
                              onChanged: (String newValue) {
                                currentExercise!.measurements[i].repetitions = int.tryParse(newValue) ?? 0;

                                CurrentWorkout? currentWorkout = userBox.get("currentWorkout");
                                if (currentWorkout != null) {
                                  currentWorkout.exercises[widget.pageID - 1] = currentExercise!;

                                  userBox.put("currentWorkout", currentWorkout);
                                }
                                setState(() {});
                              },
                            ),
                          ),
                          DataCell(
                            FlexusTableTextField(
                              hintText: "Workload",
                              textAlign: TextAlign.left,
                              textController: setController[i]["workload"]!,
                              textInputType: TextInputType.number,
                              onTapOutside: (p0) {
                                FocusManager.instance.primaryFocus?.unfocus();
                              },
                              onChanged: (String newValue) {
                                currentExercise!.measurements[i].workload = double.tryParse(newValue) ?? 0;

                                CurrentWorkout? currentWorkout = userBox.get("currentWorkout");
                                if (currentWorkout != null) {
                                  currentWorkout.exercises[widget.pageID - 1] = currentExercise!;

                                  userBox.put("currentWorkout", currentWorkout);
                                }
                                setState(() {});
                              },
                            ),
                          ),
                        ],
                      ),
                  ],
                )
              : DataTable(
                  columns: const [
                    DataColumn(label: CustomDefaultTextStyle(text: "Sets", textAlign: TextAlign.left)),
                    DataColumn(label: CustomDefaultTextStyle(text: "Duration (s)", textAlign: TextAlign.left)),
                  ],
                  rows: [
                    for (int i = 0; i <= currentExercise!.measurements.length - 1; i++)
                      DataRow(
                        onLongPress: () => {
                          showModalBottomSheet(
                            context: context,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
                            ),
                            builder: (BuildContext context) {
                              return Container(
                                padding: EdgeInsets.only(top: deviceSize.height * 0.05),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CustomDefaultTextStyle(
                                      text: "Delete Set ${i + 1}?",
                                      fontSize: AppSettings.fontSizeH3,
                                    ),
                                    SizedBox(height: deviceSize.height * 0.03),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        FlexusButtonSmall(
                                          text: "Cancel",
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                        ),
                                        FlexusButtonSmall(
                                          text: "Delete",
                                          fontColor: AppSettings.error,
                                          onPressed: () {
                                            if (currentExercise != null) {
                                              setController.removeAt(i);

                                              currentExercise!.measurements.removeAt(i);

                                              CurrentWorkout? currentWorkout = userBox.get("currentWorkout");
                                              if (currentWorkout != null) {
                                                currentWorkout.exercises[widget.pageID - 1] = currentExercise!;

                                                userBox.put("currentWorkout", currentWorkout);
                                              }

                                              setState(() {});
                                              Navigator.pop(context);
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: deviceSize.height * 0.05),
                                  ],
                                ),
                              );
                            },
                          ),
                        },
                        cells: [
                          DataCell(
                            SizedBox(
                              width: deviceSize.width * 0.15,
                              child: CustomDefaultTextStyle(
                                text: "Set ${i + 1}",
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ),
                          DataCell(
                            FlexusTableTextField(
                              hintText: "Duration",
                              textController: setController[i]["workload"]!,
                              textInputType: TextInputType.number,
                              onTap: () {
                                int? millis = userBox.get("timerValue");
                                if (millis == null) {
                                  return;
                                }
                                if (setController[i]["workload"]!.text.isEmpty) {
                                  setController[i]["workload"]!.text = (millis / 1000).toString();

                                  currentExercise!.measurements[i].workload = (millis / 1000);

                                  CurrentWorkout? currentWorkout = userBox.get("currentWorkout");
                                  if (currentWorkout != null) {
                                    currentWorkout.exercises[widget.pageID - 1] = currentExercise!;

                                    userBox.put("currentWorkout", currentWorkout);
                                  }
                                }
                                setState(() {});
                              },
                              onChanged: (String newValue) {
                                currentExercise!.measurements[i].workload = double.tryParse(newValue) ?? 0;

                                CurrentWorkout? currentWorkout = userBox.get("currentWorkout");
                                if (currentWorkout != null) {
                                  currentWorkout.exercises[widget.pageID - 1] = currentExercise!;

                                  userBox.put("currentWorkout", currentWorkout);
                                }
                                setState(() {});
                              },
                              onTapOutside: (p0) {
                                FocusManager.instance.primaryFocus?.unfocus();

                                currentExercise!.measurements[i].workload = double.tryParse(setController[i]["workload"]!.text) ?? 0;

                                CurrentWorkout? currentWorkout = userBox.get("currentWorkout");
                                if (currentWorkout != null) {
                                  currentWorkout.exercises[widget.pageID - 1] = currentExercise!;

                                  userBox.put("currentWorkout", currentWorkout);
                                }
                              },
                              onEditingComplete: () {
                                FocusManager.instance.primaryFocus?.unfocus();
                                currentExercise!.measurements[i].workload = double.tryParse(setController[i]["workload"]!.text) ?? 0;

                                CurrentWorkout? currentWorkout = userBox.get("currentWorkout");
                                if (currentWorkout != null) {
                                  currentWorkout.exercises[widget.pageID - 1] = currentExercise!;

                                  userBox.put("currentWorkout", currentWorkout);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
          SizedBox(height: deviceSize.height * 0.02),
          buildAddButton(),
          SizedBox(height: deviceSize.height * 0.15),
        ],
      );
    } else {
      return Column(
        children: [
          SizedBox(height: deviceSize.height * 0.03),
          buildAddButton(),
        ],
      );
    }
  }

  Widget buildAddButton() {
    return IconButton(
      onPressed: () {
        if (currentExercise != null) {
          setController.add({
            "reps": TextEditingController(),
            "workload": TextEditingController(),
          });

          currentExercise!.measurements.add(Measurement(repetitions: 0, workload: 0));

          CurrentWorkout? currentWorkout = userBox.get("currentWorkout");
          if (currentWorkout != null) {
            currentWorkout.exercises[widget.pageID - 1] = currentExercise!;

            userBox.put("currentWorkout", currentWorkout);
          }

          setState(() {});
        }
      },
      icon: FlexusDefaultIcon(
        iconData: Icons.add,
        iconColor: AppSettings.primary,
        iconSize: AppSettings.fontSizeH2,
      ),
    );
  }
}

import 'package:app/bloc/workout_bloc/workout_bloc.dart';
import 'package:app/hive/set/workout_set.dart';
import 'package:app/hive/workout/workout_details.dart';
import 'package:app/resources/app_settings.dart';
import 'package:app/widgets/list_tiles/flexus_workout_list_tile.dart';
import 'package:app/widgets/style/flexus_basic_title.dart';
import 'package:app/widgets/style/flexus_default_icon.dart';
import 'package:app/widgets/style/flexus_default_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class ViewWorkoutPage extends StatefulWidget {
  final int workoutID;

  const ViewWorkoutPage({
    super.key,
    this.workoutID = -1,
  });

  @override
  State<ViewWorkoutPage> createState() => _ViewWorkoutPageState();
}

class _ViewWorkoutPageState extends State<ViewWorkoutPage> {
  WorkoutBloc workoutBloc = WorkoutBloc();

  @override
  void initState() {
    workoutBloc.add(GetWorkoutDetails(workoutID: widget.workoutID));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size deviceSize = MediaQuery.of(context).size;

    return BlocBuilder(
      bloc: workoutBloc,
      builder: (context, state) {
        if (state is WorkoutDetailsLoaded) {
          WorkoutDetails workoutDetails = state.workoutDetails;

          return Scaffold(
            appBar: AppBar(
              title: CustomDefaultTextStyle(
                text: workoutDetails.split != null ? workoutDetails.split!.name : "Custom Workout",
                fontSize: AppSettings.fontSizeH3,
              ),
              centerTitle: true,
            ),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  buildStats(deviceSize, workoutDetails),
                  SizedBox(height: deviceSize.height * 0.03),
                  buildExercises(deviceSize, workoutDetails),
                ],
              ),
            ),
          );
        } else {
          return Scaffold(
            appBar: AppBar(),
            body: Center(child: CircularProgressIndicator(color: AppSettings.primary)),
          );
        }
      },
    );
  }

  Widget buildStats(Size deviceSize, WorkoutDetails workoutDetails) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: deviceSize.width * 0.05),
          child: FlexusBasicTitle(
            deviceSize: deviceSize,
            text: "Stats",
            hasPadding: false,
          ),
        ),
        DataTable(
          dataRowMinHeight: deviceSize.height * 0.02,
          dataRowMaxHeight: deviceSize.height * 0.05,
          headingRowHeight: deviceSize.height * 0.02,
          columns: const [
            DataColumn(label: CustomDefaultTextStyle(text: '')),
            DataColumn(label: CustomDefaultTextStyle(text: '')),
          ],
          rows: [
            buildDataRow("Date", DateFormat('dd.MM.yyyy').format(DateTime.parse(workoutDetails.startTime.toString()))),
            buildDataRow("Gym", workoutDetails.gym != null ? workoutDetails.gym!.name : "-"),
            buildDataRow("Duration", getCorrectDurationString(workoutDetails.startTime, workoutDetails.endtime)),
            buildDataRow("Total moved weight", getTotalWeight(workoutDetails)),
            buildDataRow("New Personal Bests", workoutDetails.pbSetIDs.length.toString()),
          ],
        ),
      ],
    );
  }

  Widget buildExercises(Size deviceSize, WorkoutDetails workoutDetails) {
    return workoutDetails.exercises.isNotEmpty
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: deviceSize.width * 0.05),
                child: FlexusBasicTitle(
                  deviceSize: deviceSize,
                  text: "Exercises",
                  hasPadding: false,
                ),
              ),
              for (int i = 0; i <= workoutDetails.exercises.length - 1; i++)
                Padding(
                  padding: EdgeInsets.only(top: deviceSize.height * 0.02),
                  child: DataTable(
                    dataRowMinHeight: deviceSize.height * 0.02,
                    dataRowMaxHeight: deviceSize.height * 0.05,
                    headingRowHeight: deviceSize.height * 0.04,
                    columns: [
                      DataColumn(
                        label: CustomDefaultTextStyle(
                          text: '${i + 1}. ${workoutDetails.exercises[i].name}',
                          fontWeight: FontWeight.w600,
                          fontSize: AppSettings.fontSizeH4,
                        ),
                      ),
                      const DataColumn(label: CustomDefaultTextStyle(text: '')),
                      const DataColumn(label: CustomDefaultTextStyle(text: '')),
                    ],
                    rows: [
                      for (int j = 0; j <= workoutDetails.sets[i].length - 1; j++)
                        DataRow(
                          cells: [
                            DataCell(CustomDefaultTextStyle(text: "Set ${j + 1}")),
                            DataCell(
                              CustomDefaultTextStyle(
                                text: getMeasurementString(
                                  workoutDetails.sets[i][j],
                                  workoutDetails.exercises[i].typeID == 1,
                                ),
                              ),
                            ),
                            DataCell(workoutDetails.pbSetIDs.contains(workoutDetails.sets[i][j].id)
                                ? const FlexusDefaultIcon(iconData: Icons.emoji_events)
                                : Container()),
                          ],
                        ),
                    ],
                  ),
                ),
            ],
          )
        : Padding(
            padding: EdgeInsets.only(top: deviceSize.height * 0.05),
            child: const Center(child: CustomDefaultTextStyle(text: "No sets found")),
          );
  }

  DataRow buildDataRow(String first, String second) {
    return DataRow(
      cells: [
        DataCell(CustomDefaultTextStyle(text: first)),
        DataCell(
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Flexible(
                child: CustomDefaultTextStyle(text: second),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String getMeasurementString(WorkoutSet set, bool isDuration) {
    if (isDuration) {
      return "${set.repetitions} x ${set.workload}kg";
    } else {
      return "${set.workload}s";
    }
  }

  String getTotalWeight(WorkoutDetails workoutDetails) {
    double totalWeight = 0;
    for (var i = 0; i <= workoutDetails.exercises.length - 1; i++) {
      for (var set in workoutDetails.sets[i]) {
        if (workoutDetails.exercises[i].typeID == 1) {
          totalWeight += set.repetitions * set.workload;
        }
      }
    }
    return "$totalWeight kg";
  }
}

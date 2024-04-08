import 'dart:math';

import 'package:app/bloc/plan_bloc/plan_bloc.dart';
import 'package:app/hive/exercise.dart';
import 'package:app/hive/plan.dart';
import 'package:app/pages/workoutplan_creation/create_plan.dart';
import 'package:app/resources/app_settings.dart';
import 'package:app/search_delegates/plan_search_delegate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:page_transition/page_transition.dart';

class PlanPage extends StatefulWidget {
  const PlanPage({super.key});

  @override
  State<PlanPage> createState() => _PlanPageState();
}

class _PlanPageState extends State<PlanPage> {
  PlanBloc planBloc = PlanBloc();

  @override
  void initState() {
    planBloc.add(GetActivePlan());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      bloc: planBloc,
      builder: (context, state) {
        if (state is PlanLoaded) {
          return Scaffold(
            backgroundColor: AppSettings.background,
            appBar: buildAppBar(state.plan),
            body: state.plan != null
                ? buildPlanView(state.plan!)
                : const Center(
                    child: Text("You don't have an active plan right now."),
                  ),
          );
        } else {
          return Scaffold(
            backgroundColor: AppSettings.background,
            body: Center(child: CircularProgressIndicator(color: AppSettings.primary)),
          );
        }
      },
    );
  }

  Widget buildPlanView(Plan plan) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Standard Details
          buildGeneral(),
          SizedBox(height: AppSettings.screenHeight * 0.05),
          buildSplit(),
          SizedBox(height: AppSettings.screenHeight * 0.05),
          buildSplit(),
          SizedBox(height: AppSettings.screenHeight * 0.05),
          buildSplit(),
        ],
      ),
    );
  }

  Widget buildGeneral() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.only(left: AppSettings.screenWidth * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'General',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: AppSettings.fontSizeTitleSmall,
                ),
              ),
            ],
          ),
        ),
        DataTable(
          dataRowMinHeight: AppSettings.screenHeight * 0.02,
          dataRowMaxHeight: AppSettings.screenHeight * 0.05,
          headingRowHeight: AppSettings.screenHeight * 0.02,
          columns: const [
            DataColumn(label: Text('')),
            DataColumn(label: Text('')),
          ],
          rows: [
            DataRow(
              cells: [
                DataCell(const Text("Split"), onTap: () => debugPrint("asdad")),
                const DataCell(
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text("Push Pull Beine"),
                    ],
                  ),
                ),
              ],
            ),
            DataRow(
              cells: [
                DataCell(const Text("Blocked days"), onTap: () => debugPrint("asdad")),
                const DataCell(
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text("Tuesday, Friday"),
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      ],
    );
  }

  Widget buildSplit() {
    List<Exercise> exercises = [
      Exercise(id: 1, name: "Benchpress", typeID: 1),
      Exercise(id: 2, name: "Squats", typeID: 2),
      Exercise(id: 3, name: "Deadlifts", typeID: 3),
      Exercise(id: 4, name: "Pull-ups", typeID: 4),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.only(left: AppSettings.screenWidth * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                exercises[Random().nextInt(3)].name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: AppSettings.fontSizeTitleSmall,
                ),
              ),
            ],
          ),
        ),
        DataTable(
          dataRowMinHeight: AppSettings.screenHeight * 0.02,
          dataRowMaxHeight: AppSettings.screenHeight * 0.05,
          columns: const [
            DataColumn(label: Text('Exercise')),
            DataColumn(label: Text('Repetitions')),
          ],
          rows: exercises
              .map<DataRow>((exercise) => DataRow(
                    cells: [
                      DataCell(Text("${exercise.id}. ${exercise.name}"), onTap: () => debugPrint("asdad")),
                      const DataCell(
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("50"),
                            Text("60"),
                            Text("70"),
                            SizedBox(),
                          ],
                        ),
                      ),
                    ],
                  ))
              .toList(),
        ),
      ],
    );
  }

  AppBar buildAppBar(Plan? plan) {
    return AppBar(
      backgroundColor: AppSettings.background,
      title: Text(plan != null ? plan.name : ""),
      centerTitle: true,
      actions: [
        PopupMenuButton<String>(
          color: AppSettings.background,
          icon: Icon(
            Icons.menu,
            color: AppSettings.font,
            size: AppSettings.fontSizeTitle,
          ),
          itemBuilder: (BuildContext context) {
            if (plan != null) {
              return ['Change Plan', 'Create New Plan', 'Delete Plan'].map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            } else {
              return ['Select Plan', 'Create New Plan'].map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            }
          },
          onSelected: (String choice) async {
            switch (choice) {
              case "Select Plan":
              case "Change Plan":
                final newPlanID = await showSearch(context: context, delegate: PlanSearchDelegate());
                if (newPlanID != null) {
                  planBloc.add(PatchPlan(
                    planID: newPlanID,
                    name: "isActive",
                    value: true,
                  ));
                }

                break;

              case "Create New Plan":
                Navigator.push(
                  context,
                  PageTransition(
                    type: PageTransitionType.rightToLeft,
                    child: const CreatePlanPage(),
                  ),
                ).then((value) => planBloc.add(GetActivePlan()));
                break;

              case "Delete Plan":
                planBloc.add(DeletePlan(planID: plan!.id));
                break;

              default:
                debugPrint("$choice not implemented yet");
            }
          },
        )
      ],
    );
  }
}

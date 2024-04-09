import 'package:app/bloc/plan_bloc/plan_bloc.dart';
import 'package:app/hive/plan.dart';
import 'package:app/hive/plan_overview.dart';
import 'package:app/pages/workoutplan_creation/create_plan.dart';
import 'package:app/resources/app_settings.dart';
import 'package:app/search_delegates/plan_search_delegate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';

class PlanPage extends StatefulWidget {
  const PlanPage({super.key});

  @override
  State<PlanPage> createState() => _PlanPageState();
}

class _PlanPageState extends State<PlanPage> {
  PlanBloc planBloc = PlanBloc();
  PlanBloc planOverviewBloc = PlanBloc();

  @override
  void initState() {
    planBloc.add(GetActivePlan());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer(
      bloc: planBloc,
      listener: (context, state) {
        if (state is PlanLoaded && state.plan != null) {
          planOverviewBloc.add(GetPlanOverview());
        }
      },
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
    return BlocBuilder(
      bloc: planOverviewBloc,
      builder: (context, state) {
        if (state is PlanOverviewLoaded) {
          if (state.planOverview != null) {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  buildGeneral(state.planOverview!),
                  SizedBox(height: AppSettings.screenHeight * 0.05),
                  buildSplits(state.planOverview!),
                ],
              ),
            );
          } else {
            return const Text("Error Loading Plan Details");
          }
        } else {
          return Scaffold(
            backgroundColor: AppSettings.background,
            body: Center(child: CircularProgressIndicator(color: AppSettings.primary)),
          );
        }
      },
    );
  }

  Widget buildGeneral(PlanOverview planOverview) {
    String combinedSplitName = "";
    Set<String> encounteredNames = {};

    for (var i = 0; i < planOverview.splitOverviews.length; i++) {
      var splitName = planOverview.splitOverviews[i].split.name;

      if (splitName != "Rest" && !encounteredNames.contains(splitName)) {
        if (combinedSplitName.isNotEmpty) {
          combinedSplitName += ", $splitName";
        } else {
          combinedSplitName += splitName;
        }
        encounteredNames.add(splitName);
      }
    }
    combinedSplitName = combinedSplitName.trim();

    String blockedDays = "none";

    if (planOverview.plan.restList != null) {
      blockedDays = "";
      for (var i = 0; i < planOverview.plan.restList!.length; i++) {
        if (planOverview.plan.restList![i]) {
          if (blockedDays.isNotEmpty) {
            blockedDays += ", ${getWeekday(i)}";
          } else {
            blockedDays += getWeekday(i);
          }
        }
      }
    }

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
                DataCell(
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [Text(combinedSplitName)],
                  ),
                ),
              ],
            ),
            DataRow(
              cells: [
                DataCell(const Text("Blocked days"), onTap: () => debugPrint("asdad")),
                DataCell(
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(blockedDays),
                    ],
                  ),
                ),
              ],
            ),
            DataRow(
              cells: [
                DataCell(const Text("Created"), onTap: () => debugPrint("asdad")),
                DataCell(
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(DateFormat('dd.MM.yyyy').format(planOverview.plan.createdAt)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget buildSplits(PlanOverview planOverview) {
    return Column(
      children: [
        for (int index = 0; index < planOverview.splitOverviews.length; index++)
          Column(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: AppSettings.screenWidth * 0.05),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          planOverview.plan.isWeekly
                              ? "${getWeekday(index)} - ${planOverview.splitOverviews[index].split.name}"
                              : "${index + 1}. ${planOverview.splitOverviews[index].split.name}",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: AppSettings.fontSizeTitleSmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                  planOverview.splitOverviews[index].exercises.isNotEmpty
                      ? DataTable(
                          dataRowMinHeight: AppSettings.screenHeight * 0.02,
                          dataRowMaxHeight: AppSettings.screenHeight * 0.05,
                          columns: const [
                            DataColumn(label: Text('Exercise')),
                            DataColumn(label: Text('Repetitions')),
                          ],
                          rows: [
                            for (int index = 0; index < planOverview.splitOverviews[index].exercises.length; index++)
                              DataRow(
                                cells: [
                                  DataCell(Text("${index + 1}. ${planOverview.splitOverviews[index].exercises[index].name}"),
                                      onTap: () => debugPrint("asdad")),
                                  planOverview.splitOverviews[index].repetitions.isNotEmpty
                                      ? DataCell(
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              for (int repetitionIndex = 0;
                                                  repetitionIndex < planOverview.splitOverviews[index].repetitions[index].length;
                                                  repetitionIndex++)
                                                Text(planOverview.splitOverviews[index].repetitions[index][repetitionIndex]),
                                              const SizedBox()
                                            ],
                                          ),
                                        )
                                      : const DataCell(
                                          Text("no data"),
                                        )
                                ],
                              ),
                          ],
                        )
                      : planOverview.splitOverviews[index].split.name != "Rest"
                          ? Padding(
                              padding: EdgeInsets.only(left: AppSettings.screenWidth * 0.05, top: AppSettings.screenHeight * 0.01),
                              child: const Text("No default exercises selected"),
                            )
                          : SizedBox(height: AppSettings.screenHeight * 0.02),
                ],
              ),
              SizedBox(height: AppSettings.screenHeight * 0.05),
            ],
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

String getWeekday(int index) {
  final weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  return weekdays[index % 7];
}

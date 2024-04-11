import 'package:app/bloc/plan_bloc/plan_bloc.dart';
import 'package:app/hive/plan/plan.dart';
import 'package:app/hive/plan/plan_overview.dart';
import 'package:app/pages/plan/create_plan.dart';
import 'package:app/resources/app_settings.dart';
import 'package:app/search_delegates/plan_search_delegate.dart';
import 'package:app/widgets/flexus_scrollbar.dart';
import 'package:app/widgets/style/flexus_default_text_style.dart';
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
  final ScrollController scrollController = ScrollController();
  final PlanBloc planBloc = PlanBloc();
  final PlanBloc planOverviewBloc = PlanBloc();

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
                    child: CustomDefaultTextStyle(text: "You don't have an active plan right now."),
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
            return FlexusScrollBar(
              scrollController: scrollController,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    buildGeneral(state.planOverview!),
                    SizedBox(height: AppSettings.screenHeight * 0.05),
                    buildSplits(state.planOverview!),
                  ],
                ),
              ),
            );
          } else {
            return const CustomDefaultTextStyle(text: "Error Loading Plan Details");
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

    String blockedDays = getBlockedDays(planOverview);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.only(left: AppSettings.screenWidth * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomDefaultTextStyle(
                text: 'General',
                fontWeight: FontWeight.bold,
                fontSize: AppSettings.fontSizeH3,
              ),
            ],
          ),
        ),
        DataTable(
          dataRowMinHeight: AppSettings.screenHeight * 0.02,
          dataRowMaxHeight: AppSettings.screenHeight * 0.05,
          headingRowHeight: AppSettings.screenHeight * 0.02,
          columns: const [
            DataColumn(label: CustomDefaultTextStyle(text: '')),
            DataColumn(label: CustomDefaultTextStyle(text: '')),
          ],
          rows: [
            DataRow(
              cells: [
                DataCell(const CustomDefaultTextStyle(text: "Split"), onTap: () => debugPrint("asdad")),
                DataCell(
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Flexible(
                        child: CustomDefaultTextStyle(
                          text: combinedSplitName,
                          overflow: TextOverflow.clip,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            DataRow(
              cells: [
                DataCell(const CustomDefaultTextStyle(text: "Blocked days"), onTap: () => debugPrint("asdad")),
                DataCell(
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Flexible(child: CustomDefaultTextStyle(text: blockedDays)),
                    ],
                  ),
                ),
              ],
            ),
            DataRow(
              cells: [
                DataCell(const CustomDefaultTextStyle(text: "Created"), onTap: () => debugPrint("asdad")),
                DataCell(
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      CustomDefaultTextStyle(text: DateFormat('dd.MM.yyyy').format(planOverview.plan.createdAt)),
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: AppSettings.screenWidth * 0.05, bottom: AppSettings.screenHeight * 0.01),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomDefaultTextStyle(
                text: 'Splits',
                fontWeight: FontWeight.bold,
                fontSize: AppSettings.fontSizeH3,
              ),
            ],
          ),
        ),
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
                        CustomDefaultTextStyle(
                          text: planOverview.plan.isWeekly
                              ? "${planOverview.splitOverviews[index].split.name} (${getWeekday(index)})"
                              : "${planOverview.splitOverviews[index].split.name} (Day ${index + 1})",
                          fontWeight: FontWeight.w600,
                          fontSize: AppSettings.fontSizeH4,
                        ),
                      ],
                    ),
                  ),
                  planOverview.splitOverviews[index].exercises.isNotEmpty
                      ? DataTable(
                          dataRowMinHeight: AppSettings.screenHeight * 0.02,
                          dataRowMaxHeight: AppSettings.screenHeight * 0.05,
                          columns: const [
                            DataColumn(label: CustomDefaultTextStyle(text: 'Exercise')),
                            DataColumn(label: CustomDefaultTextStyle(text: 'Measurements')),
                          ],
                          rows: [
                            for (int exerciseIndex = 0; exerciseIndex < planOverview.splitOverviews[index].exercises.length; exerciseIndex++)
                              DataRow(
                                cells: [
                                  DataCell(Text("${exerciseIndex + 1}. ${planOverview.splitOverviews[index].exercises[exerciseIndex].name}"),
                                      onTap: () => debugPrint("asdad")),
                                  planOverview.splitOverviews[index].measurements.isNotEmpty
                                      ? DataCell(
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              for (int measurementIndex = 0;
                                                  measurementIndex < planOverview.splitOverviews[index].measurements[exerciseIndex].length;
                                                  measurementIndex++)
                                                CustomDefaultTextStyle(
                                                    text: planOverview.splitOverviews[index].measurements[exerciseIndex][measurementIndex],
                                                    overflow: TextOverflow.clip),
                                              const SizedBox()
                                            ],
                                          ),
                                        )
                                      : const DataCell(CustomDefaultTextStyle(text: "not implemented yet")),
                                ],
                              ),
                          ],
                        )
                      : planOverview.splitOverviews[index].split.name != "Rest"
                          ? Padding(
                              padding: EdgeInsets.only(left: AppSettings.screenWidth * 0.05, top: AppSettings.screenHeight * 0.01),
                              child: const CustomDefaultTextStyle(text: "No default exercises selected"),
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
      title: CustomDefaultTextStyle(
        text: plan != null ? plan.name : "",
        fontSize: AppSettings.fontSizeH3,
      ),
      centerTitle: true,
      actions: [
        PopupMenuButton<String>(
          color: AppSettings.background,
          icon: Icon(
            Icons.menu,
            color: AppSettings.font,
            size: AppSettings.fontSizeH3,
          ),
          itemBuilder: (BuildContext context) {
            if (plan != null) {
              return ['Change Plan', 'Create New Plan', 'Delete Plan'].map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: CustomDefaultTextStyle(text: choice),
                );
              }).toList();
            } else {
              return ['Select Plan', 'Create New Plan'].map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: CustomDefaultTextStyle(text: choice),
                );
              }).toList();
            }
          },
          onSelected: (String choice) async {
            switch (choice) {
              case "Select Plan":
              case "Change Plan":
                final newPlanID = await showSearch(context: context, delegate: PlanCustomSearchDelegate());
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

String getBlockedDays(PlanOverview planOverview) {
  if (planOverview.plan.restList != null) {
    List<bool> restList = planOverview.plan.restList!;

    if (restList.contains(true)) {
      String blockedDays = "";
      for (var i = 0; i < restList.length; i++) {
        if (restList[i]) {
          if (blockedDays.isNotEmpty) {
            blockedDays += ", ${getWeekday(i)}";
          } else {
            blockedDays += getWeekday(i);
          }
        }
      }
      return blockedDays;
    } else {
      return "-";
    }
  } else {
    return "-";
  }
}

String getWeekday(int index) {
  final weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  return weekdays[index % 7];
}

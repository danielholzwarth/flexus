import 'package:app/bloc/plan_bloc/plan_bloc.dart';
import 'package:app/pages/workoutplan_creation/create_plan.dart';
import 'package:app/resources/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
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
    planBloc.add(GetPlans());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppSettings.background,
      appBar: buildAppBar(),
      body: Center(
        child: BlocBuilder(
          bloc: planBloc,
          builder: (context, state) {
            if (state is PlansLoaded) {
              if (state.plans.isNotEmpty) {
                final activePlan = state.plans.firstWhereOrNull((element) => element.isActive);
                if (activePlan != null) {
                  return Text(activePlan.name);
                } else {
                  return Text("No active plan found.");
                }
              } else {
                return Text("You don't have a plan yet. Create your first workout plan now!");
              }
            } else {
              return Text("error");
            }
          },
        ),
      ),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      backgroundColor: AppSettings.background,
      actions: [
        BlocBuilder(
          bloc: planBloc,
          builder: (context, state) {
            if (state is PlansLoaded) {
              return PopupMenuButton<String>(
                color: AppSettings.background,
                icon: Icon(
                  Icons.menu,
                  color: AppSettings.font,
                  size: AppSettings.fontSizeTitle,
                ),
                itemBuilder: (BuildContext context) {
                  return ['Change plan', 'Create new plan'].map((String choice) {
                    return PopupMenuItem<String>(
                      value: choice,
                      child: Text(choice),
                    );
                  }).toList();
                },
                onSelected: (String choice) async {
                  switch (choice) {
                    case "Change plan":
                      //Plan Search Delegate
                      break;

                    case "Create new plan":
                      Navigator.push(
                        context,
                        PageTransition(
                          type: PageTransitionType.rightToLeft,
                          child: const CreatePlanPage(),
                        ),
                      ).then((value) => setState(() {}));
                      break;

                    default:
                      debugPrint("$choice not implemented yet");
                  }
                },
              );
            } else {
              return Center(child: CircularProgressIndicator(color: AppSettings.primary));
            }
          },
        ),
      ],
    );
  }
}

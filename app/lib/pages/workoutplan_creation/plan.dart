import 'package:app/bloc/plan_bloc/plan_bloc.dart';
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
            body: Center(
              child: Text(state.plan != null ? "Plan: ${state.plan!.name}" : "You don't have an active plan right now."),
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

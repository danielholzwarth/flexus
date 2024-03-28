import 'package:app/pages/workoutplan_creation/create_plan.dart';
import 'package:app/widgets/buttons/flexus_button.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

class PlanPage extends StatelessWidget {
  const PlanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PlanPage'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FlexusButton(
              text: "create plan",
              function: () {
                Navigator.push(
                  context,
                  PageTransition(
                    type: PageTransitionType.fade,
                    child: const CreatePlanPage(),
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}

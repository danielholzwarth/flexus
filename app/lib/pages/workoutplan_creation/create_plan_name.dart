import 'package:app/widgets/flexus_button.dart';
import 'package:flutter/material.dart';

class CreatePlanNamePage extends StatelessWidget {
  const CreatePlanNamePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CreatePlanNamePage'),
        centerTitle: true,
      ),
      body: const Center(
        child: Column(
          children: [
            Text("hello"),
            FlexusButton(text: "CONTINUE", route: "/create_plan_count"),
          ],
        ),
      ),
    );
  }
}

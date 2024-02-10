import 'package:app/widgets/flexus_button.dart';
import 'package:flutter/material.dart';

class PlanPage extends StatelessWidget {
  const PlanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PlanPage'),
        centerTitle: true,
      ),
      body: const Center(
        child: Column(
          children: [
            Text("hello"),
            FlexusButton(text: "CREATE PLAN",),
          ],
        ),
      ),
    );
  }
}

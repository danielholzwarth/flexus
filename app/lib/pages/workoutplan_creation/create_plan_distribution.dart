import 'package:app/widgets/flexus_button.dart';
import 'package:flutter/material.dart';

class CreatePlanDistributionPage extends StatelessWidget {
  const CreatePlanDistributionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CreatePlanDistributionPage'),
        centerTitle: true,
      ),
      body: const Center(
        child: Column(
          children: [
            Text("hello"),
            //Pop Generation
            FlexusButton(
              text: "LOGIN",
              route: "/plan",
              hasBack: false,
            ),
          ],
        ),
      ),
    );
  }
}

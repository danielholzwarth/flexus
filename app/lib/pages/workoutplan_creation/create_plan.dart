import 'package:flutter/material.dart';

class CreatePlanPage extends StatelessWidget {
  const CreatePlanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CreatePlanPage'),
        centerTitle: true,
      ),
      body: const Center(
        child: Column(
          children: [
            Text("hello"),
          ],
        ),
      ),
    );
  }
}

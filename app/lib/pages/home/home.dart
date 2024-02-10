import 'package:app/widgets/flexus_button.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HomePage'),
        centerTitle: true,
      ),
      body: const Center(
        child: Column(
          children: [
            Text("hello"),
            FlexusButton(text: "Profile"),
            FlexusButton(text: "Locations"),
          ],
        ),
      ),
    );
  }
}

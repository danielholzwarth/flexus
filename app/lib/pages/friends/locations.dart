import 'package:app/widgets/flexus_button.dart';
import 'package:flutter/material.dart';

class LocationsPage extends StatelessWidget {
  const LocationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LocationsPage'),
        centerTitle: true,
      ),
      body: const Center(
        child: Column(
          children: [
            Text("hello"),
            FlexusButton(text: "Add Friend"),
          ],
        ),
      ),
    );
  }
}

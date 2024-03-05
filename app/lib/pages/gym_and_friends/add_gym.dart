import 'package:flutter/material.dart';

class AddGymPage extends StatelessWidget {
  const AddGymPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AddGymPage'),
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

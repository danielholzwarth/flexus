import 'package:flutter/material.dart';

class LevelingPage extends StatelessWidget {
  const LevelingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LevelingPage'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text("hello"),
      ),
    );
  }
}

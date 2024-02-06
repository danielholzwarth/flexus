import 'package:app/widgets/flexus_button.dart';
import 'package:flutter/material.dart';

class StartupPage extends StatelessWidget {
  const StartupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Startup'),
        centerTitle: true,
      ),
      body: const Center(
        child: Column(
          children: [
            Text("hello"),
            FlexusButton(text: "Login", route: "/login"),
            FlexusButton(text: "Register", route: "/register_username"),
          ],
        ),
      ),
    );
  }
}

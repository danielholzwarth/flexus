import 'package:app/widgets/flexus_button.dart';
import 'package:flutter/material.dart';

class RegisterUsernamePage extends StatelessWidget {
  const RegisterUsernamePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register Username'),
        centerTitle: true,
      ),
      body: const Center(
        child: Column(
          children: [
            Text("hello"),
            FlexusButton(text: "CONTINUE", route: "/register_password"),
          ],
        ),
      ),
    );
  }
}

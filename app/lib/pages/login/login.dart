import 'package:app/widgets/flexus_button.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LoginPage'),
        centerTitle: true,
      ),
      body: const Center(
        child: Column(
          children: [
            Text("hello"),
            FlexusButton(
              text: "LOGIN",
              route: "/home",
              hasBack: false,
            ),
          ],
        ),
      ),
    );
  }
}

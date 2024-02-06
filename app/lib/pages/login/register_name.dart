import 'package:app/widgets/flexus_button.dart';
import 'package:flutter/material.dart';

class RegisterNamePage extends StatelessWidget {
  const RegisterNamePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register Name'),
        centerTitle: true,
      ),
      body: const Center(
        child: Column(
          children: [
            Text("hello"),
            FlexusButton(
              text: "CREATE ACCOUNT",
              route: "/home",
              hasBack: false,
            ),
          ],
        ),
      ),
    );
  }
}

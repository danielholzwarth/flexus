import 'package:app/widgets/flexus_button.dart';
import 'package:flutter/material.dart';

class RegisterPasswordPage extends StatelessWidget {
  const RegisterPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register Password'),
        centerTitle: true,
      ),
      body: const Center(
        child: Column(
          children: [
            Text("hello"),
            FlexusButton(text: "CONTINUE", route: "/register_name"),
          ],
        ),
      ),
    );
  }
}

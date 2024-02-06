import 'package:app/widgets/flexus_button.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ProfilePage'),
        centerTitle: true,
      ),
      body: const Center(
        child: Column(
          children: [
            Text("hello"),
            FlexusButton(text: "Settings", route: "/settings"),
            FlexusButton(text: "Leveling", route: "/leveling"),
            FlexusButton(text: "Profile Picture", route: "/profile_picture"),
          ],
        ),
      ),
    );
  }
}

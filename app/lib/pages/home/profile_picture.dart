import 'package:flutter/material.dart';

class ProfilePicturePage extends StatelessWidget {
  const ProfilePicturePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ProfilePicturePage'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text("hello"),
      ),
    );
  }
}

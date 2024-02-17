import 'package:app/pages/home/home.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

class LocationsPage extends StatelessWidget {
  const LocationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: (DragEndDetails details) {
        _implementSwiping(details, context);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('LocationsPage'),
          centerTitle: true,
        ),
        body: const Center(
          child: Column(
            children: [
              Text("hello"),
            ],
          ),
        ),
      ),
    );
  }

  void _implementSwiping(DragEndDetails details, BuildContext context) {
    if (details.primaryVelocity! > 0) {
      Navigator.pushAndRemoveUntil(
        context,
        PageTransition(
          type: PageTransitionType.leftToRight,
          child: const HomePage(),
        ),
        (route) => false,
      );
    }
  }
}

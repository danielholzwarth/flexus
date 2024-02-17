import 'package:app/pages/friends/locations.dart';
import 'package:app/pages/home/home.dart';
import 'package:app/resources/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: (DragEndDetails details) {
        _implementSwiping(details, context);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('StatisticsPage'),
          centerTitle: true,
        ),
        body: const Center(
          child: Text("Statistics"),
        ),
      ),
    );
  }

  void _implementSwiping(DragEndDetails details, BuildContext context) {
    if (details.primaryVelocity! < 0) {
      Navigator.pushAndRemoveUntil(
        context,
        PageTransition(
          type: PageTransitionType.rightToLeft,
          child: const HomePage(),
        ),
        (route) => false,
      );
    }
  }
}

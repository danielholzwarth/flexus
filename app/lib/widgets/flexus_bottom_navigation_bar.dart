import 'package:app/pages/friends/locations.dart';
import 'package:app/pages/statistics/statistics.dart';
import 'package:app/resources/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

class FlexusBottomNavigationBar extends StatelessWidget {
  final ScrollController scrollController;
  const FlexusBottomNavigationBar({
    super.key,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20.0)),
      child: BottomAppBar(
        color: AppSettings.primaryShade80,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(
              icon: Icon(
                Icons.bar_chart_rounded,
                color: AppSettings.font,
                size: AppSettings.fontSizeTitle,
              ),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  PageTransition(
                    type: PageTransitionType.leftToRight,
                    child: const StatisticsPage(),
                  ),
                );
              },
            ),
            IconButton(
              icon: Icon(
                Icons.fitness_center,
                color: AppSettings.font,
                size: AppSettings.fontSizeMainTitle,
              ),
              onPressed: () {
                //Update list if internet connection
                scrollController.animateTo(
                  0,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.linear,
                );
              },
            ),
            IconButton(
              icon: Icon(
                Icons.people,
                color: AppSettings.font,
                size: AppSettings.fontSizeTitle,
              ),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  PageTransition(
                    type: PageTransitionType.rightToLeft,
                    child: const LocationsPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

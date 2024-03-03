import 'package:app/pages/friends/locations.dart';
import 'package:app/pages/home/home.dart';
import 'package:app/pages/statistics/statistics.dart';
import 'package:app/resources/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

class FlexusBottomNavigationBar extends StatelessWidget {
  final int pageIndex;
  final ScrollController scrollController;
  const FlexusBottomNavigationBar({
    super.key,
    required this.scrollController,
    required this.pageIndex,
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
                size: pageIndex == 0 ? AppSettings.fontSizeMainTitle : AppSettings.fontSizeTitle,
              ),
              onPressed: () {
                if (pageIndex == 0) {
                  scrollToTop();
                } else {
                  Navigator.pushReplacement(
                    context,
                    PageTransition(
                      type: PageTransitionType.leftToRight,
                      child: const StatisticsPage(),
                    ),
                  );
                }
              },
            ),
            IconButton(
              icon: Icon(
                Icons.fitness_center,
                color: AppSettings.font,
                size: pageIndex == 1 ? AppSettings.fontSizeMainTitle : AppSettings.fontSizeTitle,
              ),
              onPressed: () {
                if (pageIndex == 1) {
                  scrollToTop();
                } else {
                  Navigator.pushReplacement(
                    context,
                    PageTransition(
                      type: pageIndex == 0 ? PageTransitionType.rightToLeft : PageTransitionType.leftToRight,
                      child: const HomePage(),
                    ),
                  );
                }
              },
            ),
            IconButton(
              icon: Icon(
                Icons.people,
                color: AppSettings.font,
                size: pageIndex == 2 ? AppSettings.fontSizeMainTitle : AppSettings.fontSizeTitle,
              ),
              onPressed: () {
                if (pageIndex == 2) {
                  scrollToTop();
                } else {
                  Navigator.pushReplacement(
                    context,
                    PageTransition(
                      type: PageTransitionType.rightToLeft,
                      child: const LocationsPage(),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void scrollToTop() {
    scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.linear,
    );
  }
}

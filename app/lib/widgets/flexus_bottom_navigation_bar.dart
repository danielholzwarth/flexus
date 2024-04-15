import 'package:app/pages/home/gym.dart';
import 'package:app/pages/home/home.dart';
import 'package:app/pages/home/statistics.dart';
import 'package:app/resources/app_settings.dart';
import 'package:app/widgets/style/flexus_default_icon.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

class FlexusBottomNavigationBar extends StatelessWidget {
  final int pageIndex;

  const FlexusBottomNavigationBar({
    super.key,
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
              icon: FlexusDefaultIcon(
                iconData: Icons.bar_chart_rounded,
                iconSize: pageIndex == 0 ? AppSettings.fontSizeH1 : AppSettings.fontSizeH3,
              ),
              onPressed: () {
                if (pageIndex != 0) {
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
              icon: FlexusDefaultIcon(
                iconData: Icons.fitness_center,
                iconSize: pageIndex == 1 ? AppSettings.fontSizeH1 : AppSettings.fontSizeH3,
              ),
              onPressed: () {
                if (pageIndex != 1) {
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
              icon: FlexusDefaultIcon(
                iconData: Icons.people,
                iconSize: pageIndex == 2 ? AppSettings.fontSizeH1 : AppSettings.fontSizeH3,
              ),
              onPressed: () {
                if (pageIndex != 2) {
                  Navigator.pushReplacement(
                    context,
                    PageTransition(
                      type: PageTransitionType.rightToLeft,
                      child: const GymPage(),
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
}

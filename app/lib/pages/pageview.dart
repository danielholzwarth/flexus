import 'package:app/pages/gym_and_friends/gym.dart';
import 'package:app/pages/home/home.dart';
import 'package:app/pages/statistics/statistics.dart';
import 'package:app/resources/app_settings.dart';
import 'package:flutter/material.dart';

class PageViewPage extends StatefulWidget {
  const PageViewPage({super.key});

  @override
  State<PageViewPage> createState() => _PageViewPageState();
}

class _PageViewPageState extends State<PageViewPage> {
  int currentPageIndex = 1;
  PageController pageController = PageController(initialPage: 1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        onPageChanged: (value) => {
          setState(() {
            currentPageIndex = value;
          }),
        },
        controller: pageController,
        children: const [
          StatisticsPage(),
          HomePage(),
          GymPage(),
        ],
      ),
      bottomNavigationBar: ClipRRect(
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
                  size: currentPageIndex == 0 ? AppSettings.fontSizeMainTitle : AppSettings.fontSizeTitle,
                ),
                onPressed: () {
                  setState(() {
                    currentPageIndex = 0;
                    pageController.jumpToPage(currentPageIndex);
                  });
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.fitness_center,
                  color: AppSettings.font,
                  size: currentPageIndex == 1 ? AppSettings.fontSizeMainTitle : AppSettings.fontSizeTitle,
                ),
                onPressed: () {
                  setState(() {
                    currentPageIndex = 1;
                    pageController.jumpToPage(currentPageIndex);
                  });
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.people,
                  color: AppSettings.font,
                  size: currentPageIndex == 2 ? AppSettings.fontSizeMainTitle : AppSettings.fontSizeTitle,
                ),
                onPressed: () {
                  setState(() {
                    currentPageIndex = 2;
                    pageController.jumpToPage(currentPageIndex);
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

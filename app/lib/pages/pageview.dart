import 'package:app/pages/gym_and_friends/gym.dart';
import 'package:app/pages/home/home.dart';
import 'package:app/pages/statistics/statistics.dart';
import 'package:app/widgets/flexus_bottom_navigation_bar.dart';
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
          currentPageIndex = value,
        },
        controller: pageController,
        children: const [
          StatisticsPage(),
          HomePage(),
          GymPage(),
        ],
      ),
      bottomNavigationBar: FlexusBottomNavigationBar(pageIndex: currentPageIndex),
    );
  }
}

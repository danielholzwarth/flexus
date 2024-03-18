import 'package:app/hive/user_settings.dart';
import 'package:app/pages/home/gym.dart';
import 'package:app/pages/home/home.dart';
import 'package:app/pages/home/statistics.dart';
import 'package:app/pages/workout_documentation/start_workout.dart';
import 'package:app/resources/app_settings.dart';
import 'package:app/widgets/buttons/flexus_button.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:page_transition/page_transition.dart';

class PageViewPage extends StatefulWidget {
  final bool isFirst;

  const PageViewPage({
    super.key,
    this.isFirst = false,
  });

  @override
  State<PageViewPage> createState() => _PageViewPageState();
}

class _PageViewPageState extends State<PageViewPage> {
  final userBox = Hive.box("userBox");
  bool isFirstTime = true;

  int currentPageIndex = 1;
  PageController pageController = PageController(initialPage: 1);

  @override
  void initState() {
    final flexusjwt = userBox.get("flexusjwt");
    AppSettings.isTokenExpired = JwtDecoder.isExpired(flexusjwt);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    UserSettings userSettings = userBox.get("userSettings");
    bool isQuickAccess = userSettings.isQuickAccess;
    if (isFirstTime && widget.isFirst && isQuickAccess) {
      isFirstTime = false;
      return buildQuickAccess(context);
    } else {
      return buildPages();
    }
  }

  Scaffold buildPages() {
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
      bottomNavigationBar: buildBottomNavigationBar(),
    );
  }

  ClipRRect buildBottomNavigationBar() {
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
    );
  }

  Scaffold buildQuickAccess(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        color: AppSettings.primary,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            FlexusButton(
              text: "Start Workout",
              function: () {
                Navigator.push(
                  context,
                  PageTransition(
                    type: PageTransitionType.fade,
                    child: const StartWorkoutPage(),
                  ),
                ).then((value) => setState(() {}));
              },
              backgroundColor: AppSettings.background,
              fontColor: AppSettings.font,
            ),
            SizedBox(height: AppSettings.screenHeight * 0.1),
            FlexusButton(
              text: "Send Notification",
              function: () {
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Center(
                      child: Text("Not implemented yet :("),
                    ),
                  ),
                );
              },
              backgroundColor: AppSettings.backgroundV1,
              fontColor: AppSettings.fontV1,
            ),
            SizedBox(height: AppSettings.screenHeight * 0.1),
            IconButton(
              icon: Icon(
                Icons.close,
                size: AppSettings.fontSizeMainTitle,
              ),
              onPressed: () {
                setState(() {});
              },
            )
          ],
        ),
      ),
    );
  }
}

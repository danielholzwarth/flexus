import 'package:app/bloc/init_bloc/initialization_bloc.dart';
import 'package:app/pages/home/gym.dart';
import 'package:app/pages/home/home.dart';
import 'package:app/pages/home/statistics.dart';
import 'package:app/pages/workout/start_workout.dart';
import 'package:app/resources/app_settings.dart';
import 'package:app/widgets/buttons/flexus_button.dart';
import 'package:app/widgets/error/flexus_error.dart';
import 'package:app/widgets/style/flexus_default_icon.dart';
import 'package:app/widgets/style/flexus_default_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive/hive.dart';
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

class _PageViewPageState extends State<PageViewPage> with TickerProviderStateMixin {
  final userBox = Hive.box("userBox");
  bool isFirstTime = true;
  int currentPageIndex = 1;
  PageController pageController = PageController(initialPage: 1);

  InitializationBloc initializationBloc = InitializationBloc();

  late final AnimationController animationController = AnimationController(
    duration: const Duration(milliseconds: 1500),
    vsync: this,
  )..repeat(reverse: true);

  late final Animation<double> animation = CurvedAnimation(
    reverseCurve: Curves.easeOut,
    parent: animationController,
    curve: Curves.easeOut,
  );

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    Size deviceSize = MediaQuery.of(context).size;

    return BlocBuilder(
      bloc: initializationBloc,
      builder: (context, state) {
        if (state is Initializing) {
          return Scaffold(
            backgroundColor: AppSettings.primary,
            body: Center(
              child: FadeTransition(
                opacity: animation,
                child: FlexusDefaultIcon(
                  iconData: Icons.star,
                  iconSize: deviceSize.height * 0.17,
                  iconColor: AppSettings.background,
                ),
              ),
            ),
          );
        } else if (state is Initialized) {
          // UserSettings userSettings = userBox.get("userSettings");
          // bool isQuickAccess = userSettings.isQuickAccess;

          // if (isFirstTime && widget.isFirst && isQuickAccess) {
          //   isFirstTime = false;
          //   return buildQuickAccess(context, deviceSize);
          // } else {
          return buildPages();
          // }
        } else if (state is InitializingError) {
          return FlexusError(text: state.error, func: loadData);
        } else {
          return const Center(child: CustomDefaultTextStyle(text: "Error: No valid state"));
        }
      },
    );
  }

  void loadData() {
    initializationBloc.add(InitializeApp());
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
              icon: FlexusDefaultIcon(
                iconData: Icons.bar_chart_rounded,
                iconSize: currentPageIndex == 0 ? AppSettings.fontSizeH1 : AppSettings.fontSizeH3,
              ),
              onPressed: () {
                setState(() {
                  currentPageIndex = 0;
                  pageController.jumpToPage(currentPageIndex);
                });
              },
            ),
            IconButton(
              icon: FlexusDefaultIcon(
                iconData: Icons.fitness_center,
                iconSize: currentPageIndex == 1 ? AppSettings.fontSizeH1 : AppSettings.fontSizeH3,
              ),
              onPressed: () {
                setState(() {
                  currentPageIndex = 1;
                  pageController.jumpToPage(currentPageIndex);
                });
              },
            ),
            IconButton(
              icon: FlexusDefaultIcon(
                iconData: Icons.people,
                iconSize: currentPageIndex == 2 ? AppSettings.fontSizeH1 : AppSettings.fontSizeH3,
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

  Scaffold buildQuickAccess(BuildContext context, Size deviceSize) {
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
            SizedBox(height: deviceSize.height * 0.1),
            FlexusButton(
              text: "Send Notification",
              function: () async {
                Fluttertoast.cancel();
                Fluttertoast.showToast(
                  msg: "Not implemented yet",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.CENTER,
                  backgroundColor: AppSettings.error,
                  textColor: AppSettings.fontV1,
                  fontSize: AppSettings.fontSize,
                );
              },
              backgroundColor: AppSettings.backgroundV1,
              fontColor: AppSettings.fontV1,
            ),
            SizedBox(height: deviceSize.height * 0.1),
            IconButton(
              icon: FlexusDefaultIcon(
                iconData: Icons.close,
                iconSize: AppSettings.fontSizeH1,
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

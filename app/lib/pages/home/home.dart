import 'package:app/hive/workout.dart';
import 'package:app/pages/friends/locations.dart';
import 'package:app/pages/home/profile.dart';
import 'package:app/pages/statistics/statistics.dart';
import 'package:app/pages/workoutplan_creation/plan.dart';
import 'package:app/resources/app_settings.dart';
import 'package:app/widgets/flexus_archive_sliver_appbar.dart';
import 'package:app/widgets/flexus_bottom_navigation_bar.dart';
import 'package:app/widgets/flexus_floating_action_button.dart';
import 'package:app/widgets/flexus_sliver_appbar.dart';
import 'package:app/widgets/flexus_workout_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController scrollController = ScrollController(initialScrollOffset: 50);
  bool isArchiveVisible = false;

  @override
  void initState() {
    super.initState();
    scrollController.addListener(scrollListener);
  }

  void scrollListener() {
    if (scrollController.offset == 0) {
      setState(() {
        isArchiveVisible = true;
      });
    } else {
      setState(() {
        isArchiveVisible = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (DragUpdateDetails details) {
        implementDraging(details, context);
      },
      child: Scaffold(
        body: CustomScrollView(
          controller: scrollController,
          slivers: <Widget>[
            _buildFlexusSliverAppBar(context),
            SliverVisibility(
              sliver: const FlexusArchiveSliverAppBar(),
              visible: isArchiveVisible,
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  return FlexusWorkoutListTile(
                    workout: Workout(
                      id: index,
                      userAccountID: index,
                      starttime: DateTime.now().subtract(Duration(days: index)).add(Duration(minutes: index * 13)),
                      endtime: DateTime.now().subtract(Duration(days: index)).add(Duration(minutes: 150 + index * 7)),
                      isArchived: false,
                    ),
                  );
                },
                childCount: 50,
              ),
            ),
          ],
        ),
        floatingActionButton: const FlexusFloatingActionButton(),
        bottomNavigationBar: FlexusBottomNavigationBar(scrollController: scrollController),
      ),
    );
  }

  FlexusSliverAppBar _buildFlexusSliverAppBar(BuildContext context) {
    return FlexusSliverAppBar(
      leading: IconButton(
        icon: Icon(
          Icons.person,
          size: AppSettings.fontSizeTitle,
        ),
        onPressed: () {
          Navigator.push(
            context,
            PageTransition(
              type: PageTransitionType.leftToRight,
              child: const ProfilePage(),
            ),
          );
        },
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.menu_book,
            size: AppSettings.fontSizeTitle,
          ),
          onPressed: () {
            Navigator.push(
              context,
              PageTransition(
                type: PageTransitionType.fade,
                child: const PlanPage(),
              ),
            );
          },
        ),
        IconButton(
          icon: Icon(
            Icons.search,
            size: AppSettings.fontSizeTitle,
          ),
          onPressed: () {
            print('Lupe was clicked');
          },
        ),
      ],
    );
  }
}

void implementDraging(DragUpdateDetails details, BuildContext context) {
  if (details.delta.dx > 0.5) {
    Navigator.pushReplacement(
      context,
      PageTransition(
        type: PageTransitionType.leftToRight,
        child: const StatisticsPage(),
      ),
    );
  } else {
    Navigator.pushReplacement(
      context,
      PageTransition(
        type: PageTransitionType.rightToLeft,
        child: const LocationsPage(),
      ),
    );
  }
}

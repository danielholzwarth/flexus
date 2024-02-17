import 'package:app/hive/workout.dart';
import 'package:app/pages/friends/locations.dart';
import 'package:app/pages/home/archive.dart';
import 'package:app/pages/home/profile.dart';
import 'package:app/pages/statistics/statistics.dart';
import 'package:app/pages/workout_documentation/start_workout.dart';
import 'package:app/pages/workoutplan_creation/plan.dart';
import 'package:app/resources/app_settings.dart';
import 'package:app/widgets/flexus_workout_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: (DragEndDetails details) {
        _implementSwiping(details, context);
      },
      child: Scaffold(
        body: CustomScrollView(
          slivers: <Widget>[
            _buildAppBar(context),
            SliverAppBar(
              toolbarHeight: 30,
              backgroundColor: AppSettings.background,
              surfaceTintColor: AppSettings.background,
              foregroundColor: AppSettings.font,
              expandedHeight: 30,
              centerTitle: true,
              title: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    PageTransition(
                      type: PageTransitionType.fade,
                      child: const ArchivePage(),
                    ),
                  );
                },
                child: const Text("Archive"),
              ),
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
        floatingActionButton: FloatingActionButton(
          foregroundColor: AppSettings.fontV1,
          backgroundColor: AppSettings.primary,
          onPressed: () {
            Navigator.push(
              context,
              PageTransition(
                type: PageTransitionType.fade,
                child: const StartWorkoutPage(),
              ),
            );
          },
          shape: const CircleBorder(),
          child: Icon(
            Icons.add,
            size: AppSettings.fontSizeTitle,
          ),
        ),
        bottomNavigationBar: _buildBottomAppBar(context),
      ),
    );
  }

  void _implementSwiping(DragEndDetails details, BuildContext context) {
    if (details.primaryVelocity! > 0) {
      Navigator.pushAndRemoveUntil(
        context,
        PageTransition(
          type: PageTransitionType.leftToRight,
          child: const StatisticsPage(),
        ),
        (route) => false,
      );
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        PageTransition(
          type: PageTransitionType.rightToLeft,
          child: const LocationsPage(),
        ),
        (route) => false,
      );
    }
  }

  ClipRRect _buildBottomAppBar(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20.0)),
      child: BottomAppBar(
        color: AppSettings.primaryShade80,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.show_chart),
              onPressed: () {
                Navigator.push(
                  context,
                  PageTransition(
                    type: PageTransitionType.leftToRight,
                    child: const StatisticsPage(),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(
                Icons.fitness_center,
                color: Colors.amber,
              ),
              onPressed: () {
                // Get back up to latest workouts (and refresh)
              },
            ),
            IconButton(
              icon: const Icon(Icons.people),
              onPressed: () {
                Navigator.push(
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

  ListView _buildListView(BuildContext context) {
    return ListView.builder(
      itemCount: 20,
      itemBuilder: (context, index) {
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
    );
  }

  SliverAppBar _buildAppBar(BuildContext context) {
    return SliverAppBar(
      backgroundColor: AppSettings.background,
      surfaceTintColor: AppSettings.background,
      foregroundColor: AppSettings.font,
      expandedHeight: 50,
      floating: true,
      leading: IconButton(
        icon: Icon(
          Icons.person,
          size: AppSettings.fontSize,
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
            size: AppSettings.fontSize,
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
            size: AppSettings.fontSize,
          ),
          onPressed: () {
            print('Lupe wurde geklickt');
          },
        ),
      ],
    );
  }
}

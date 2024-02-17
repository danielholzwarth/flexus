import 'package:app/hive/workout.dart';
import 'package:app/pages/friends/locations.dart';
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
    return Scaffold(
      appBar: _buildAppBar(context),
      body: _buildListView(context),
      floatingActionButton: FloatingActionButton(
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
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: _buildBottomAppBar(context),
    );
  }

  BottomAppBar _buildBottomAppBar(BuildContext context) {
    return BottomAppBar(
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
            icon: const Icon(Icons.fitness_center),
            onPressed: () {
              //Get back up to latest workouts (and refresh)
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

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.person),
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
          icon: const Icon(Icons.menu_book),
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
          icon: const Icon(Icons.search),
          onPressed: () {
            print('Lupe wurde geklickt');
          },
        ),
      ],
    );
  }
}

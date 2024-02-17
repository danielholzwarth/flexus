import 'package:app/hive/workout.dart';
import 'package:app/pages/home/home.dart';
import 'package:app/resources/app_settings.dart';
import 'package:app/widgets/flexus_sliver_appbar.dart';
import 'package:app/widgets/flexus_workout_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

class ArchivePage extends StatelessWidget {
  ArchivePage({super.key});

  final ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: (DragEndDetails details) {
        _implementSwiping(details, context);
      },
      child: Scaffold(
        body: CustomScrollView(
          controller: scrollController,
          slivers: <Widget>[
            FlexusSliverAppBar(
              title: const Text("Archive"),
              actions: [
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
      ),
    );
  }
}

void _implementSwiping(DragEndDetails details, BuildContext context) {
  if (details.primaryVelocity! > 0) {
    Navigator.pushAndRemoveUntil(
      context,
      PageTransition(
        type: PageTransitionType.fade,
        child: const HomePage(),
      ),
      (route) => false,
    );
  }
}

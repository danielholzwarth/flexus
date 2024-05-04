import 'package:app/bloc/workout_bloc/workout_bloc.dart';
import 'package:app/hive/workout/workout.dart';
import 'package:app/hive/workout/workout_overview.dart';
import 'package:app/resources/app_settings.dart';
import 'package:app/search_delegates/workouts_search_delegate.dart';
import 'package:app/widgets/flexus_scrollbar.dart';
import 'package:app/widgets/flexus_sliver_appbar.dart';
import 'package:app/widgets/list_tiles/flexus_workout_list_tile.dart';
import 'package:app/widgets/style/flexus_default_icon.dart';
import 'package:app/widgets/style/flexus_default_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

class ArchivePage extends StatefulWidget {
  const ArchivePage({super.key});

  @override
  State<ArchivePage> createState() => _ArchivePageState();
}

class _ArchivePageState extends State<ArchivePage> {
  final ScrollController scrollController = ScrollController();
  final TextEditingController searchController = TextEditingController();
  final WorkoutBloc workoutBloc = WorkoutBloc();
  bool isArchiveVisible = false;
  bool isSearch = false;
  final userBox = Hive.box('userBox');

  @override
  void initState() {
    workoutBloc.add(GetSearchWorkout(isArchive: true));
    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppSettings.background,
      body: FlexusScrollBar(
        scrollController: scrollController,
        child: CustomScrollView(
          controller: scrollController,
          slivers: <Widget>[
            buildAppBar(context),
            buildWorkouts(),
          ],
        ),
      ),
    );
  }

  BlocBuilder<WorkoutBloc, Object?> buildWorkouts() {
    return BlocBuilder(
      bloc: workoutBloc,
      builder: (context, state) {
        if (state is WorkoutsLoaded) {
          if (state.workoutOverviews.isNotEmpty) {
            return SliverList(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  return FlexusWorkoutListTile(
                    key: UniqueKey(),
                    workoutOverview: WorkoutOverview(
                      workout: Workout(
                        id: state.workoutOverviews[index].workout.id,
                        userAccountID: state.workoutOverviews[index].workout.userAccountID,
                        createdAt: state.workoutOverviews[index].workout.createdAt,
                        starttime: state.workoutOverviews[index].workout.starttime,
                        endtime: state.workoutOverviews[index].workout.endtime,
                        isActive: state.workoutOverviews[index].workout.isActive,
                        isArchived: state.workoutOverviews[index].workout.isArchived,
                        isStared: state.workoutOverviews[index].workout.isStared,
                        isPinned: state.workoutOverviews[index].workout.isPinned,
                      ),
                      planName: state.workoutOverviews[index].planName,
                      splitName: state.workoutOverviews[index].splitName,
                      bestLiftCount: state.workoutOverviews[index].bestLiftCount,
                    ),
                    workoutBloc: workoutBloc,
                  );
                },
                childCount: state.workoutOverviews.length,
              ),
            );
          } else {
            return const SliverFillRemaining(
              child: Center(
                child: CustomDefaultTextStyle(
                  text: 'No workouts found',
                ),
              ),
            );
          }
        } else if (state is WorkoutError) {
          return SliverFillRemaining(
            child: Center(
              child: CustomDefaultTextStyle(
                text: 'Error: ${state.error}',
              ),
            ),
          );
        } else {
          return SliverFillRemaining(
            child: Center(child: CircularProgressIndicator(color: AppSettings.primary)),
          );
        }
      },
    );
  }

  FlexusSliverAppBar buildAppBar(BuildContext context) {
    return FlexusSliverAppBar(
      title: CustomDefaultTextStyle(
        text: "Archive",
        fontSize: AppSettings.fontSizeH3,
      ),
      actions: [
        IconButton(
          icon: const FlexusDefaultIcon(iconData: Icons.search),
          onPressed: () async {
            await showSearch(context: context, delegate: WorkoutSearchDelegate(isArchived: true));
            workoutBloc.add(GetSearchWorkout(isArchive: true));
          },
        ),
      ],
    );
  }
}

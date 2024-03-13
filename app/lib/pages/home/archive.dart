import 'package:app/bloc/workout_bloc/workout_bloc.dart';
import 'package:app/hive/workout.dart';
import 'package:app/hive/workout_overview.dart';
import 'package:app/resources/app_settings.dart';
import 'package:app/widgets/flexus_scrollbar.dart';
import 'package:app/widgets/flexus_sliver_appbar.dart';
import 'package:app/widgets/list_tiles/flexus_workout_list_tile.dart';
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppSettings.background,
      body: FlexusScrollBar(
        scrollController: scrollController,
        child: CustomScrollView(
          controller: scrollController,
          slivers: <Widget>[
            buildAppBar(context),
            BlocBuilder(
              bloc: workoutBloc,
              builder: (context, state) {
                if (state is WorkoutLoaded) {
                  if (state.workoutOverviews.isNotEmpty) {
                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                          return FlexusWorkoutListTile(
                            workoutOverview: WorkoutOverview(
                              workout: Workout(
                                id: state.workoutOverviews[index].workout.id,
                                userAccountID: state.workoutOverviews[index].workout.userAccountID,
                                starttime: state.workoutOverviews[index].workout.starttime,
                                endtime: state.workoutOverviews[index].workout.endtime,
                                isArchived: state.workoutOverviews[index].workout.isArchived,
                                isStared: state.workoutOverviews[index].workout.isStared,
                                isPinned: state.workoutOverviews[index].workout.isPinned,
                              ),
                              planName: state.workoutOverviews[index].planName,
                              splitName: state.workoutOverviews[index].splitName,
                            ),
                            workoutBloc: workoutBloc,
                          );
                        },
                        childCount: state.workoutOverviews.length,
                      ),
                    );
                  } else {
                    return SliverFillRemaining(
                      child: Center(
                        child: Text(
                          'No workouts found',
                          style: TextStyle(fontSize: AppSettings.fontSize),
                        ),
                      ),
                    );
                  }
                } else if (state is WorkoutError) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Text(
                        'Error: ${state.error}',
                        style: TextStyle(fontSize: AppSettings.fontSize),
                      ),
                    ),
                  );
                } else {
                  return SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator(color: AppSettings.primary)),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  FlexusSliverAppBar buildAppBar(BuildContext context) {
    return FlexusSliverAppBar(
      title: Text(
        "Archive",
        style: TextStyle(fontSize: AppSettings.fontSizeTitle, color: AppSettings.font),
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.search,
            size: AppSettings.fontSizeTitle,
          ),
          onPressed: () async {
            await showSearch(context: context, delegate: CustomSearchDelegate());
            workoutBloc.add(GetSearchWorkout(isArchive: true));
          },
        ),
      ],
    );
  }
}

class CustomSearchDelegate extends SearchDelegate {
  WorkoutBloc workoutBloc = WorkoutBloc();
  ScrollController scrollController = ScrollController();

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: const Icon(Icons.clear),
      )
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, null);
      },
      icon: const Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    workoutBloc.add(GetSearchWorkout(isArchive: true, keyWord: query));

    return BlocBuilder(
      bloc: workoutBloc,
      builder: (context, state) {
        if (state is WorkoutSearching) {
          return Scaffold(
            backgroundColor: AppSettings.background,
            body: Center(child: CircularProgressIndicator(color: AppSettings.primary)),
          );
        } else if (state is WorkoutLoaded) {
          if (state.workoutOverviews.isNotEmpty) {
            return Scaffold(
              backgroundColor: AppSettings.background,
              body: FlexusScrollBar(
                scrollController: scrollController,
                child: ListView.builder(
                  controller: scrollController,
                  itemBuilder: (context, index) {
                    return FlexusWorkoutListTile(workoutBloc: workoutBloc, workoutOverview: state.workoutOverviews[index], query: query);
                  },
                  itemCount: state.workoutOverviews.length,
                ),
              ),
            );
          } else {
            return Scaffold(
              backgroundColor: AppSettings.background,
              body: const Center(
                child: Text("No workouts found"),
              ),
            );
          }
        } else {
          return Scaffold(
            backgroundColor: AppSettings.background,
            body: const Center(
              child: Text("Error loading workouts"),
            ),
          );
        }
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    workoutBloc.add(GetSearchWorkout(isArchive: true, keyWord: query));

    return BlocBuilder(
      bloc: workoutBloc,
      builder: (context, state) {
        if (state is WorkoutSearching) {
          return Scaffold(
            backgroundColor: AppSettings.background,
            body: Center(child: CircularProgressIndicator(color: AppSettings.primary)),
          );
        } else if (state is WorkoutLoaded) {
          if (state.workoutOverviews.isNotEmpty) {
            return Scaffold(
              backgroundColor: AppSettings.background,
              body: FlexusScrollBar(
                scrollController: scrollController,
                child: ListView.builder(
                  controller: scrollController,
                  itemBuilder: (context, index) {
                    return FlexusWorkoutListTile(workoutBloc: workoutBloc, workoutOverview: state.workoutOverviews[index], query: query);
                  },
                  itemCount: state.workoutOverviews.length,
                ),
              ),
            );
          } else {
            return Scaffold(
              backgroundColor: AppSettings.background,
              body: const Center(
                child: Text("No workouts found"),
              ),
            );
          }
        } else {
          return Scaffold(
            backgroundColor: AppSettings.background,
            body: const Center(
              child: Text("Error loading workouts"),
            ),
          );
        }
      },
    );
  }
}

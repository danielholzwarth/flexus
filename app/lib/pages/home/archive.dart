import 'package:app/bloc/workout_bloc/workout_bloc.dart';
import 'package:app/hive/workout.dart';
import 'package:app/hive/workout_overview.dart';
import 'package:app/resources/app_settings.dart';
import 'package:app/widgets/flexus_search_textfield.dart';
import 'package:app/widgets/flexus_sliver_appbar.dart';
import 'package:app/widgets/flexus_workout_list_tile.dart';
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
    super.initState();
    workoutBloc.add(LoadWorkout(isArchive: true));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: scrollController,
        slivers: <Widget>[
          _buildFlexusSliverAppBar(context),
          BlocBuilder(
            bloc: workoutBloc,
            builder: (context, state) {
              if (state is WorkoutLoading || state is WorkoutDeleting) {
                return SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: AppSettings.primary)));
              } else if (state is WorkoutLoaded || state is WorkoutDeleted) {
                List<WorkoutOverview> workoutOverviews = userBox.get("workoutOverviews");

                if (workoutOverviews.isNotEmpty) {
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                        return FlexusWorkoutListTile(
                          workoutOverview: WorkoutOverview(
                            workout: Workout(
                              id: workoutOverviews[index].workout.id,
                              userAccountID: workoutOverviews[index].workout.userAccountID,
                              starttime: workoutOverviews[index].workout.starttime,
                              endtime: workoutOverviews[index].workout.endtime,
                              isArchived: true,
                            ),
                            planName: workoutOverviews[index].planName,
                            splitName: workoutOverviews[index].splitName,
                          ),
                          workoutBloc: workoutBloc,
                        );
                      },
                      childCount: workoutOverviews.length,
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
                      'Error loading workouts',
                      style: TextStyle(fontSize: AppSettings.fontSize),
                    ),
                  ),
                );
              } else {
                return SliverFillRemaining(
                  child: Center(
                    child: Text(
                      'Error XYZ',
                      style: TextStyle(fontSize: AppSettings.fontSize),
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFlexusSliverAppBar(BuildContext context) {
    return isSearch ? buildSearchBar(context) : buildAppBar(context);
  }

  FlexusSliverAppBar buildSearchBar(BuildContext context) {
    return FlexusSliverAppBar(
      hasLeading: false,
      title: FlexusSearchTextField(
        hintText: "Search...",
        onChanged: (String newValue) {
          workoutBloc.add(LoadWorkout(
            isArchive: true,
            isSearch: true,
            keyWord: searchController.text,
          ));
        },
        textController: searchController,
        suffixOnPressed: () {
          setState(() {
            searchController.text = "";
            isSearch = false;
            workoutBloc.add(LoadWorkout(isArchive: true));
          });
        },
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
          onPressed: () {
            setState(() {
              isSearch = true;
              workoutBloc.add(LoadWorkout(isSearch: true));
            });
          },
        ),
      ],
    );
  }
}

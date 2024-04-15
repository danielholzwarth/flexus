import 'package:app/bloc/workout_bloc/workout_bloc.dart';
import 'package:app/resources/app_settings.dart';
import 'package:app/widgets/flexus_scrollbar.dart';
import 'package:app/widgets/list_tiles/flexus_workout_list_tile.dart';
import 'package:app/widgets/style/flexus_default_icon.dart';
import 'package:app/widgets/style/flexus_default_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WorkoutsCustomSearchDelegate extends SearchDelegate {
  final bool? isArchived;

  WorkoutsCustomSearchDelegate({
    this.isArchived,
  });

  WorkoutBloc workoutBloc = WorkoutBloc();
  ScrollController scrollController = ScrollController();

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: const FlexusDefaultIcon(iconData: Icons.clear),
      )
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, null);
      },
      icon: const FlexusDefaultIcon(iconData: Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return buildSearchResults(context);
  }

  Widget buildSearchResults(BuildContext context) {
    workoutBloc.add(GetSearchWorkout(keyWord: query, isArchive: isArchived));

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: BlocBuilder(
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
                      return FlexusWorkoutListTile(
                        workoutBloc: workoutBloc,
                        workoutOverview: state.workoutOverviews[index],
                        query: query,
                        key: UniqueKey(),
                      );
                    },
                    itemCount: state.workoutOverviews.length,
                  ),
                ),
              );
            } else {
              return Scaffold(
                backgroundColor: AppSettings.background,
                body: const Center(
                  child: CustomDefaultTextStyle(text: "No workouts found"),
                ),
              );
            }
          } else {
            return Scaffold(
              backgroundColor: AppSettings.background,
              body: const Center(
                child: CustomDefaultTextStyle(text: "Error loading workouts"),
              ),
            );
          }
        },
      ),
    );
  }
}

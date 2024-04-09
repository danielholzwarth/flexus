import 'package:app/bloc/exercise_bloc/exercise_bloc.dart';
import 'package:app/hive/exercise/exercise.dart';
import 'package:app/resources/app_settings.dart';
import 'package:app/widgets/flexus_scrollbar.dart';
import 'package:app/widgets/list_tiles/flexus_exercise_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ExerciseSearchDelegate extends SearchDelegate {
  ScrollController scrollController = ScrollController();
  ExerciseBloc exerciseBloc = ExerciseBloc();
  bool isLoaded = false;
  List<Exercise> items = [];
  List<Exercise> checkedItems = [];

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
        close(context, checkedItems);
      },
      icon: const Icon(Icons.arrow_back),
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
    if (!isLoaded) {
      exerciseBloc.add(GetExercises());
      isLoaded = true;
    }

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: BlocBuilder(
        bloc: exerciseBloc,
        builder: (context, state) {
          if (state is ExercisesLoaded) {
            items = state.exercises;
            List<Exercise> filteredExercises =
                state.exercises.where((exercise) => exercise.name.toLowerCase().contains(query.toLowerCase())).toList();

            if (filteredExercises.isNotEmpty) {
              return Scaffold(
                backgroundColor: AppSettings.background,
                body: FlexusScrollBar(
                  scrollController: scrollController,
                  child: ListView.builder(
                    controller: scrollController,
                    itemBuilder: (context, index) {
                      return FlexusExerciseListTile(
                        query: query,
                        title: filteredExercises[index].name,
                        value: checkedItems.contains(filteredExercises[index]) ? true : false,
                        subtitle: filteredExercises[index].typeID == 1
                            ? "Measurements"
                            : filteredExercises[index].typeID == 2
                                ? "Duration"
                                : "Other",
                        onChanged: (value) {
                          if (value) {
                            checkedItems.add(filteredExercises[index]);
                          } else {
                            checkedItems.remove(filteredExercises[index]);
                          }

                          exerciseBloc.add(RefreshGetExercisesState(exercises: items));
                        },
                      );
                    },
                    itemCount: filteredExercises.length,
                  ),
                ),
              );
            } else {
              return Scaffold(
                backgroundColor: AppSettings.background,
                body: const Center(
                  child: Text("No exercise found"),
                ),
              );
            }
          } else {
            return Scaffold(
              backgroundColor: AppSettings.background,
              body: Center(child: CircularProgressIndicator(color: AppSettings.primary)),
            );
          }
        },
      ),
    );
  }
}

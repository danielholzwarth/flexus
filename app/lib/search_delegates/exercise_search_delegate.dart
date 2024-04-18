import 'package:app/bloc/exercise_bloc/exercise_bloc.dart';
import 'package:app/hive/exercise/exercise.dart';
import 'package:app/resources/app_settings.dart';
import 'package:app/widgets/flexus_scrollbar.dart';
import 'package:app/widgets/list_tiles/flexus_exercise_list_tile.dart';
import 'package:app/widgets/style/flexus_default_icon.dart';
import 'package:app/widgets/style/flexus_default_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ExerciseCustomSearchDelegate extends SearchDelegate {
  ExerciseCustomSearchDelegate({
    this.isMultipleChoice = true,
  });

  bool isMultipleChoice;
  ScrollController scrollController = ScrollController();
  ExerciseBloc exerciseBloc = ExerciseBloc();
  bool isLoaded = false;
  List<Exercise> items = [];
  List<Exercise> checkedItems = [];

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

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
        if (isMultipleChoice) {
          close(context, checkedItems);
        } else {
          close(context, null);
        }
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
                        isMultipleChoice: isMultipleChoice,
                        query: query,
                        title: filteredExercises[index].name,
                        value: checkedItems.contains(filteredExercises[index]) ? true : false,
                        subtitle: filteredExercises[index].typeID == 1
                            ? "Measurement"
                            : filteredExercises[index].typeID == 2
                                ? "Duration"
                                : "Other",
                        onTap: isMultipleChoice
                            ? null
                            : () {
                                close(
                                    context,
                                    Exercise(
                                      id: filteredExercises[index].id,
                                      name: filteredExercises[index].name,
                                      typeID: filteredExercises[index].typeID,
                                      creatorID: filteredExercises[index].creatorID,
                                    ));
                              },
                        onChanged: isMultipleChoice
                            ? (value) {
                                if (value) {
                                  checkedItems.add(filteredExercises[index]);
                                } else {
                                  checkedItems.remove(filteredExercises[index]);
                                }

                                exerciseBloc.add(RefreshGetExercisesState(exercises: items));
                              }
                            : null,
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
                  child: CustomDefaultTextStyle(text: "No exercise found"),
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

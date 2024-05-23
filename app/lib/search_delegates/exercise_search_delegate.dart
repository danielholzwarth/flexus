import 'package:app/bloc/exercise_bloc/exercise_bloc.dart';
import 'package:app/hive/exercise/exercise.dart';
import 'package:app/pages/workout/create_exercise.dart';
import 'package:app/resources/app_settings.dart';
import 'package:app/widgets/flexus_scrollbar.dart';
import 'package:app/widgets/list_tiles/flexus_exercise_list_tile.dart';
import 'package:app/widgets/style/flexus_default_icon.dart';
import 'package:app/widgets/style/flexus_default_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:page_transition/page_transition.dart';

class ExerciseSearchDelegate extends SearchDelegate {
  final bool isMultipleChoice;
  final List<Exercise> oldCheckedItems;
  ScrollController scrollController = ScrollController();
  ExerciseBloc exerciseBloc = ExerciseBloc();
  bool isLoaded = false;
  List<Exercise> items = [];
  List<Exercise> checkedItems = [];
  String oldQuery = "anything";
  final userBox = Hive.box('userBox');

  ExerciseSearchDelegate({
    this.isMultipleChoice = true,
    this.oldCheckedItems = const [],
  });

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      query != ""
          ? IconButton(
              onPressed: () {
                query = '';
              },
              icon: const FlexusDefaultIcon(iconData: Icons.clear),
            )
          : IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  PageTransition(
                    type: PageTransitionType.fade,
                    child: const CreateExercisePage(),
                  ),
                ).then((value) => exerciseBloc.add(GetExercises()));
              },
              icon: const FlexusDefaultIcon(iconData: Icons.add),
            ),
      isMultipleChoice
          ? TextButton(
              onPressed: () => close(context, checkedItems),
              child: CustomDefaultTextStyle(
                text: "Save",
                color: AppSettings.primary,
              ),
            )
          : Container(),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        if (isMultipleChoice) {
          close(context, oldCheckedItems);
        } else {
          close(context, null);
        }
      },
      icon: const FlexusDefaultIcon(iconData: Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return buildSearchResults(context, false);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (!isLoaded) {
      exerciseBloc.add(GetExercises());
      isLoaded = true;
      checkedItems.addAll(oldCheckedItems);
    }

    if (oldQuery == query) {
      return buildSearchResults(context, false);
    }
    oldQuery = query;
    return buildSearchResults(context, true);
  }

  Widget buildSearchResults(BuildContext context, bool rebuild) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: BlocConsumer(
        bloc: exerciseBloc,
        listener: (context, state) {
          if (state is ExercisesLoaded) {
            dynamic exerciseDyn = userBox.get("createdExercise");
            if (exerciseDyn != null) {
              Exercise exercise = exerciseDyn;
              checkedItems.add(exercise);
              userBox.delete("createdExercise");
            }
          }
        },
        builder: (context, state) {
          if (state is ExercisesLoaded) {
            items = state.exercises;
            List<Exercise> filteredExercises =
                state.exercises.where((exercise) => exercise.name.toLowerCase().contains(query.toLowerCase())).toList();

            if (filteredExercises.isNotEmpty) {
              return Scaffold(
                backgroundColor: AppSettings.background,
                body: Column(
                  children: [
                    Expanded(
                      child: FlexusScrollBar(
                        scrollController: scrollController,
                        child: ListView.builder(
                          controller: scrollController,
                          itemBuilder: (context, index) {
                            return FlexusExerciseListTile(
                              isMultipleChoice: isMultipleChoice,
                              query: query,
                              exercise: filteredExercises[index],
                              value: checkedItems.any((element) => element.id == filteredExercises[index].id) ? true : false,
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
                                        ),
                                      );
                                    },
                              onChanged: isMultipleChoice
                                  ? (value) {
                                      if (value) {
                                        checkedItems.add(filteredExercises[index]);
                                      } else {
                                        checkedItems.removeWhere((element) => element.id == filteredExercises[index].id);
                                      }

                                      exerciseBloc.add(RefreshGetExercisesState(exercises: items));
                                    }
                                  : null,
                            );
                          },
                          itemCount: filteredExercises.length,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return Scaffold(
                backgroundColor: AppSettings.background,
                body: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomDefaultTextStyle(text: "No exercise found"),
                    ],
                  ),
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

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
import 'package:page_transition/page_transition.dart';

class ExerciseCustomSearchDelegate extends SearchDelegate {
  ExerciseCustomSearchDelegate({
    this.isMultipleChoice = true,
    this.oldCheckedItems = const [],
  });

  bool isMultipleChoice;
  ScrollController scrollController = ScrollController();
  ExerciseBloc exerciseBloc = ExerciseBloc();
  bool isLoaded = false;
  List<Exercise> items = [];
  List<Exercise> checkedItems = [];
  List<Exercise> oldCheckedItems;

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
    return buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return buildSearchResults(context);
  }

  Widget buildSearchResults(BuildContext context) {
    Size deviceSize = MediaQuery.of(context).size;

    if (!isLoaded) {
      exerciseBloc.add(GetExercises());
      isLoaded = true;
      checkedItems.addAll(oldCheckedItems);
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

            filteredExercises.sort((a, b) {
              bool aChecked = checkedItems.any((element) => element.id == a.id);
              bool bChecked = checkedItems.any((element) => element.id == b.id);
              if (aChecked && !bChecked) {
                return -1;
              } else if (!aChecked && bChecked) {
                return 1;
              }
              return 0;
            });

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
                    TextButton(
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(AppSettings.background),
                          surfaceTintColor: MaterialStateProperty.all(AppSettings.background),
                          overlayColor: MaterialStateProperty.all(AppSettings.primaryShade48),
                          foregroundColor: MaterialStateProperty.all(AppSettings.primary),
                          fixedSize: MaterialStateProperty.all(Size.fromWidth(deviceSize.width * 0.4))),
                      onPressed: () {
                        Navigator.push(
                          context,
                          PageTransition(
                            type: PageTransitionType.fade,
                            child: const CreateExercisePage(),
                          ),
                        );
                      },
                      child: const Text("Create exercise"),
                    ),
                  ],
                ),
              );
            } else {
              return Scaffold(
                backgroundColor: AppSettings.background,
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CustomDefaultTextStyle(text: "No exercise found"),
                      TextButton(
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(AppSettings.background),
                            surfaceTintColor: MaterialStateProperty.all(AppSettings.background),
                            overlayColor: MaterialStateProperty.all(AppSettings.primaryShade48),
                            foregroundColor: MaterialStateProperty.all(AppSettings.primary),
                            fixedSize: MaterialStateProperty.all(Size.fromWidth(deviceSize.width * 0.4))),
                        onPressed: () {
                          Navigator.push(
                            context,
                            PageTransition(
                              type: PageTransitionType.fade,
                              child: const CreateExercisePage(),
                            ),
                          );
                        },
                        child: const Text("Create exercise"),
                      ),
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

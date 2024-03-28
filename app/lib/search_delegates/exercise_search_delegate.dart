import 'package:app/resources/app_settings.dart';
import 'package:app/widgets/flexus_scrollbar.dart';
import 'package:app/widgets/list_tiles/flexus_exercise_list_tile.dart';
import 'package:flutter/material.dart';

class ExerciseSearchDelegate extends SearchDelegate {
  ScrollController scrollController = ScrollController();

  List<String> items = ["Benchpress", "Butterfly", "Squats"];
  List<String> checkedItems = [];

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
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: AppSettings.background,
        body: FlexusScrollBar(
          scrollController: scrollController,
          child: ListView.builder(
            controller: scrollController,
            itemBuilder: (context, index) {
              return FlexusExerciseListTile(
                query: query,
                title: items[index],
                onChanged: (value) {
                  if (value) {
                    checkedItems.add(items[index]);
                  } else {
                    checkedItems.remove(items[index]);
                  }
                },
              );
            },
            itemCount: items.length,
          ),
        ),
      ),
    );
  }
}

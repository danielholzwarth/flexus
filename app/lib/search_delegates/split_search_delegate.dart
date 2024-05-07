import 'package:app/bloc/split_bloc/split_bloc.dart';
import 'package:app/hive/plan/current_plan.dart';
import 'package:app/hive/plan/plan.dart';
import 'package:app/resources/app_settings.dart';
import 'package:app/widgets/flexus_scrollbar.dart';
import 'package:app/widgets/list_tiles/flexus_split_list_tile.dart';
import 'package:app/widgets/style/flexus_default_icon.dart';
import 'package:app/widgets/style/flexus_default_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SplitSearchDelegate extends SearchDelegate {
  final Plan plan;

  SplitSearchDelegate({
    required this.plan,
  });

  ScrollController scrollController = ScrollController();
  SplitBloc splitBloc = SplitBloc();

  bool isLoaded = false;

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
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
    if (!isLoaded) {
      splitBloc.add(GetSplits(planID: plan.id));
      isLoaded = true;
    }

    return GestureDetector(
      onVerticalDragDown: (details) {
        FocusScope.of(context).unfocus();
      },
      child: BlocBuilder(
        bloc: splitBloc,
        builder: (context, state) {
          if (state is SplitsLoaded) {
            if (state.splits.isNotEmpty) {
              state.splits.sort((a, b) => a.id.compareTo(b.id));
              return Scaffold(
                backgroundColor: AppSettings.background,
                body: FlexusScrollBar(
                  scrollController: scrollController,
                  child: ListView.builder(
                    controller: scrollController,
                    itemBuilder: (context, index) {
                      return FlexusSplitListTile(
                        onPressed: () {
                          close(
                            context,
                            CurrentPlan(plan: plan, currentSplit: index, splits: state.splits),
                          );
                        },
                        title: state.splits[index].name,
                        query: query,
                        key: UniqueKey(),
                      );
                    },
                    itemCount: state.splits.length,
                  ),
                ),
              );
            } else {
              return Scaffold(
                backgroundColor: AppSettings.background,
                body: const Center(
                  child: CustomDefaultTextStyle(text: "No splits found"),
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

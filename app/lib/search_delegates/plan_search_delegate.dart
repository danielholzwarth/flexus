import 'package:app/bloc/plan_bloc/plan_bloc.dart';
import 'package:app/hive/plan/plan.dart';
import 'package:app/resources/app_settings.dart';
import 'package:app/widgets/flexus_scrollbar.dart';
import 'package:app/widgets/list_tiles/flexus_plan_list_tile.dart';
import 'package:app/widgets/style/flexus_default_icon.dart';
import 'package:app/widgets/style/flexus_default_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class PlanSearchDelegate extends SearchDelegate {
  ScrollController scrollController = ScrollController();
  PlanBloc planBloc = PlanBloc();
  bool isLoaded = false;
  List<Plan> items = [];

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
      planBloc.add(GetPlans());
      isLoaded = true;
    }

    return GestureDetector(
      onVerticalDragDown: (details) {
        FocusScope.of(context).unfocus();
      },
      child: BlocBuilder(
        bloc: planBloc,
        builder: (context, state) {
          if (state is PlansLoaded) {
            items = state.plans;
            List<Plan> filteredPlans = state.plans.where((plan) => plan.name.toLowerCase().contains(query.toLowerCase())).toList();

            if (filteredPlans.isNotEmpty) {
              return Scaffold(
                backgroundColor: AppSettings.background,
                body: FlexusScrollBar(
                  scrollController: scrollController,
                  child: ListView.builder(
                    controller: scrollController,
                    itemBuilder: (context, index) {
                      return FlexusPlanListTile(
                        query: query,
                        title: filteredPlans[index].name,
                        subtitle: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomDefaultTextStyle(
                              text: "Splits: ${filteredPlans[index].splitCount}",
                              fontSize: AppSettings.fontSizeT2,
                            ),
                            CustomDefaultTextStyle(
                              text: "Created at: ${DateFormat('dd.MM.yyyy').format(filteredPlans[index].createdAt)}",
                              fontSize: AppSettings.fontSizeT2,
                            )
                          ],
                        ),
                        onPressed: () {
                          close(context, filteredPlans[index]);
                        },
                      );
                    },
                    itemCount: filteredPlans.length,
                  ),
                ),
              );
            } else {
              return Scaffold(
                backgroundColor: AppSettings.background,
                body: const Center(
                  child: CustomDefaultTextStyle(text: "No plan found"),
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

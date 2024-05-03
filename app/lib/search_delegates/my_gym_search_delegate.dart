import 'dart:convert';

import 'package:app/bloc/gym_bloc/gym_bloc.dart';
import 'package:app/resources/app_settings.dart';
import 'package:app/widgets/flexus_scrollbar.dart';
import 'package:app/widgets/list_tiles/flexus_my_gym_search_list_tile.dart';
import 'package:app/widgets/style/flexus_default_icon.dart';
import 'package:app/widgets/style/flexus_default_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

class MyGymSearchDelegate extends SearchDelegate {
  ScrollController scrollController = ScrollController();
  GymBloc gymBloc = GymBloc();
  bool isLoaded = false;

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
      gymBloc.add(GetMyGyms(query: query));

      isLoaded = true;
    }

    return GestureDetector(
      onVerticalDragDown: (details) {
        FocusScope.of(context).unfocus();
      },
      child: BlocBuilder(
        bloc: gymBloc,
        builder: (context, state) {
          if (state is MyGymsLoaded) {
            if (state.gyms.isNotEmpty) {
              return Scaffold(
                backgroundColor: AppSettings.background,
                body: FlexusScrollBar(
                  scrollController: scrollController,
                  child: ListView.builder(
                    controller: scrollController,
                    itemBuilder: (context, index) {
                      return FlexusMyGymSearchListTile(
                        gym: state.gyms[index],
                        query: query,
                        onTap: () {
                          close(context, state.gyms[index]);
                        },
                        key: UniqueKey(),
                      );
                    },
                    itemCount: state.gyms.length,
                  ),
                ),
              );
            } else {
              return Scaffold(
                backgroundColor: AppSettings.background,
                body: const Center(
                  child: CustomDefaultTextStyle(text: "No gyms found"),
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

  Future<List<Map<String, dynamic>>> searchLocations(String query) async {
    final response = await http.get(Uri.parse('https://nominatim.openstreetmap.org/search?q=$query&format=json&addressdetails=1'));

    if (response.statusCode == 200) {
      debugPrint(response.body);
      final List<dynamic> results = json.decode(response.body);
      final List<Map<String, dynamic>> firstTenResults = results.take(10).cast<Map<String, dynamic>>().toList();
      return firstTenResults;
    } else {
      throw Exception('Failed to load search results');
    }
  }
}

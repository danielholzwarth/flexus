import 'dart:convert';

import 'package:app/bloc/gym_bloc/gym_bloc.dart';
import 'package:app/resources/app_settings.dart';
import 'package:app/widgets/error/flexus_error.dart';
import 'package:app/widgets/flexus_scrollbar.dart';
import 'package:app/widgets/list_tiles/flexus_gym_expansion_tile.dart';
import 'package:app/widgets/list_tiles/flexus_gym_osm_expansion_tile.dart';
import 'package:app/widgets/style/flexus_default_icon.dart';
import 'package:app/widgets/style/flexus_default_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

class GymSearchDelegate extends SearchDelegate {
  ScrollController scrollController = ScrollController();
  GymBloc searchGymBloc = GymBloc();
  bool isAddNew = false;

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
      IconButton(
        onPressed: () {
          isAddNew = !isAddNew;
          query = '';
        },
        icon: FlexusDefaultIcon(
          iconData: Icons.add,
          iconColor: isAddNew ? AppSettings.primary : null,
        ),
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
    Size deviceSize = MediaQuery.of(context).size;

    if (!isAddNew) {
      if (query != "") {
        searchGymBloc.add(GetGymsSearch(query: query));

        return GestureDetector(
          onVerticalDragDown: (details) {
            FocusScope.of(context).unfocus();
          },
          child: BlocBuilder(
            bloc: searchGymBloc,
            builder: (context, state) {
              if (state is GymsSearchLoaded) {
                if (state.gyms.isNotEmpty) {
                  return Scaffold(
                    backgroundColor: AppSettings.background,
                    body: FlexusScrollBar(
                      scrollController: scrollController,
                      child: ListView.builder(
                        controller: scrollController,
                        itemBuilder: (context, index) {
                          return FlexusGymExpansionTile(
                            gym: state.gyms[index],
                            query: query,
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
      } else {
        return GestureDetector(
          onVerticalDragDown: (details) {
            FocusScope.of(context).unfocus();
          },
          child: Scaffold(
            backgroundColor: AppSettings.background,
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(50.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CustomDefaultTextStyle(
                      text: "Start searching in order to show results!",
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: deviceSize.height * 0.05),
                    const CustomDefaultTextStyle(
                      text: "If your gym does not yet exist, you can add it to the list of available gyms by clicking on the top right!",
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }
    } else {
      return GestureDetector(
        onVerticalDragDown: (details) {
          FocusScope.of(context).unfocus();
        },
        child: FutureBuilder(
          future: searchLocations(query),
          builder: (BuildContext context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Scaffold(
                backgroundColor: AppSettings.background,
                body: Center(child: CircularProgressIndicator(color: AppSettings.primary)),
              );
            } else if (snapshot.hasError) {
              return Scaffold(backgroundColor: AppSettings.background, body: FlexusError(text: snapshot.error.toString(), func: null));
            } else {
              final List<Map<String, dynamic>> searchResults = snapshot.data ?? [];

              if (searchResults.isNotEmpty) {
                return Scaffold(
                  backgroundColor: AppSettings.background,
                  body: FlexusScrollBar(
                    scrollController: scrollController,
                    child: ListView.builder(
                      controller: scrollController,
                      itemBuilder: (context, index) {
                        return FlexusGymOSMExpansionTile(
                          locationData: searchResults[index],
                          query: query,
                        );
                      },
                      itemCount: searchResults.length,
                    ),
                  ),
                );
              } else {
                return Scaffold(
                  backgroundColor: AppSettings.background,
                  body: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(50.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CustomDefaultTextStyle(
                            text: "No results found",
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: deviceSize.height * 0.05),
                          const CustomDefaultTextStyle(
                            text: "You can switch to the gym search by pressing the blue plus-sign at the top right.",
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
            }
          },
        ),
      );
    }
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

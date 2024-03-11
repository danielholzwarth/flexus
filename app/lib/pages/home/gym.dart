import 'dart:convert';

import 'package:app/bloc/gym_bloc/gym_bloc.dart';
import 'package:app/bloc/user_account_bloc/user_account_bloc.dart';
import 'package:app/hive/user_account.dart';
import 'package:app/pages/friends/add_friend.dart';
import 'package:app/pages/profile/profile.dart';
import 'package:app/resources/app_settings.dart';
import 'package:app/widgets/buttons/flexus_button.dart';
import 'package:app/widgets/buttons/flexus_floating_action_button.dart';
import 'package:app/widgets/flexus_sliver_appbar.dart';
import 'package:app/widgets/list_tiles/flexus_gym_expansion_tile.dart';
import 'package:app/widgets/list_tiles/flexus_gym_overview_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:page_transition/page_transition.dart';
import 'package:http/http.dart' as http;

class GymPage extends StatefulWidget {
  const GymPage({super.key});

  @override
  State<GymPage> createState() => _GymPageState();
}

class _GymPageState extends State<GymPage> {
  final ScrollController scrollController = ScrollController();
  final userBox = Hive.box('userBox');
  final GymBloc gymBloc = GymBloc();

  @override
  void initState() {
    gymBloc.add(GetGymOverviews());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppSettings.background,
      body: CustomScrollView(
        controller: scrollController,
        slivers: <Widget>[
          buildAppBar(context),
          buildGyms(),
        ],
      ),
      floatingActionButton: buildFloatingActionButton(context),
    );
  }

  Widget buildGyms() {
    return BlocBuilder(
      bloc: gymBloc,
      builder: (context, state) {
        if (state is GymOverviewsLoaded) {
          if (state.gymOverviews.isNotEmpty) {
            return SliverList(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  return FlexusGymOverviewListTile(
                    gymOverview: state.gymOverviews[index],
                  );
                },
                childCount: state.gymOverviews.length,
              ),
            );
          } else {
            return SliverFillRemaining(
              child: Center(
                child: Text(
                  'No gym found',
                  style: TextStyle(fontSize: AppSettings.fontSize),
                ),
              ),
            );
          }
        } else if (state is UserAccountsError) {
          return SliverFillRemaining(
            child: Center(
              child: Text(
                'Error: ${state.error}',
                style: TextStyle(fontSize: AppSettings.fontSize),
              ),
            ),
          );
        } else {
          return SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: AppSettings.primary)));
        }
      },
    );
  }

  FlexusFloatingActionButton buildFloatingActionButton(BuildContext context) {
    String selectedItem = 'Energym';
    List<String> items = ['Energym', 'Jumpers', 'CleverFit'];

    TimeOfDay selectedTime = TimeOfDay.now();

    return FlexusFloatingActionButton(
      onPressed: () {
        showModalBottomSheet(
          backgroundColor: AppSettings.background,
          context: context,
          builder: (BuildContext context) {
            return StatefulBuilder(
              builder: (context, setState) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Column(
                      children: [
                        Text(
                          "Send Notification",
                          style: TextStyle(
                            fontSize: AppSettings.fontSizeTitleSmall,
                            color: AppSettings.font,
                          ),
                        ),
                        SizedBox(height: AppSettings.screenHeight * 0.06),
                        Container(
                          width: AppSettings.screenWidth * 0.7,
                          height: AppSettings.screenHeight * 0.07,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppSettings.background,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                child: DropdownButton<String>(
                                  isExpanded: true,
                                  focusColor: AppSettings.error,
                                  underline: Container(),
                                  value: selectedItem,
                                  onChanged: (value) {
                                    setState(() {
                                      selectedItem = value!;
                                    });
                                  },
                                  items: items.map<DropdownMenuItem<String>>((String value) {
                                    return DropdownMenuItem<String>(
                                      alignment: Alignment.center,
                                      value: value,
                                      child: Text(
                                        value,
                                        style: TextStyle(
                                          fontSize: AppSettings.fontSizeTitleSmall,
                                          color: AppSettings.font,
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: AppSettings.screenHeight * 0.03),
                        GestureDetector(
                          onTap: () async {
                            final TimeOfDay? pickedTime = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                              initialEntryMode: TimePickerEntryMode.dial,
                              barrierColor: AppSettings.background,
                              builder: (BuildContext context, Widget? child) {
                                return Theme(
                                  data: ThemeData(
                                    colorScheme: ColorScheme.light(primary: AppSettings.primary),
                                    dialogBackgroundColor: Colors.white,
                                    timePickerTheme: TimePickerThemeData(
                                      dayPeriodTextColor: AppSettings.background,
                                      backgroundColor: AppSettings.primaryShade48,
                                      dayPeriodColor: AppSettings.primary,
                                    ),
                                    textSelectionTheme: TextSelectionThemeData(
                                      cursorColor: AppSettings.fontV1,
                                      selectionColor: AppSettings.fontV1.withOpacity(0.3),
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (pickedTime != null) {
                              setState(() {
                                selectedTime = pickedTime;
                              });
                            }
                          },
                          child: Container(
                            width: AppSettings.screenWidth * 0.7,
                            height: AppSettings.screenHeight * 0.07,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              decoration: BoxDecoration(
                                color: AppSettings.background,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Center(
                                child: Text(
                                  selectedTime.format(context),
                                  style: TextStyle(
                                    fontSize: AppSettings.fontSizeTitleSmall,
                                    color: AppSettings.font,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: AppSettings.screenHeight * 0.09),
                        FlexusButton(
                          function: () {
                            Navigator.pop(context);
                          },
                          text: "Send Notification",
                          fontColor: AppSettings.fontV1,
                          backgroundColor: AppSettings.primary,
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
        gymBloc.add(GetGymOverviews());
      },
      icon: Icons.notification_add_outlined,
    );
  }

  FlexusSliverAppBar buildAppBar(BuildContext context) {
    UserAccount userAccount = userBox.get("userAccount");
    return FlexusSliverAppBar(
      leading: SizedBox(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: userAccount.profilePicture != null
              ? GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      PageTransition(
                        type: PageTransitionType.fade,
                        child: ProfilePage(userID: userAccount.id),
                      ),
                    ).then((value) => setState(() {}));
                  },
                  child: CircleAvatar(
                    radius: AppSettings.fontSize,
                    backgroundImage: MemoryImage(userAccount.profilePicture!),
                  ),
                )
              : IconButton(
                  icon: Icon(
                    Icons.person,
                    size: AppSettings.fontSizeTitle,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      PageTransition(
                        type: PageTransitionType.fade,
                        child: ProfilePage(userID: userAccount.id),
                      ),
                    );
                  },
                ),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.people,
            size: AppSettings.fontSizeTitle,
          ),
          onPressed: () {
            Navigator.push(
              context,
              PageTransition(
                type: PageTransitionType.fade,
                child: const AddFriendPage(),
              ),
            ).then((value) {
              gymBloc.add(GetGymOverviews());
            });
          },
        ),
        IconButton(
          icon: Icon(
            Icons.add_business,
            size: AppSettings.fontSizeTitle,
          ),
          onPressed: () {
            showSearch(context: context, delegate: CustomSearchDelegate()).then((value) => gymBloc.add(GetGymOverviews()));
          },
        ),
      ],
    );
  }
}

class CustomSearchDelegate extends SearchDelegate {
  TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> searchResults = [];

  Future<List<Map<String, dynamic>>> searchLocations(String query) async {
    final response = await http.get(Uri.parse('https://nominatim.openstreetmap.org/search?q=$query&format=json'));

    if (response.statusCode == 200) {
      final List<dynamic> results = json.decode(response.body);
      final List<Map<String, dynamic>> firstFiveResults = results.take(10).cast<Map<String, dynamic>>().toList();
      return firstFiveResults;
    } else {
      throw Exception('Failed to load search results');
    }
  }

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
        close(context, null);
      },
      icon: const Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return FutureBuilder(
      future: searchLocations(query),
      builder: (BuildContext context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: AppSettings.background,
            body: Center(child: CircularProgressIndicator(color: AppSettings.primary)),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: AppSettings.background,
            body: Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: TextStyle(fontSize: AppSettings.fontSize),
              ),
            ),
          );
        } else {
          final List<Map<String, dynamic>> searchResults = snapshot.data ?? [];

          if (searchResults.isNotEmpty) {
            return Scaffold(
              backgroundColor: AppSettings.background,
              body: ListView.builder(
                itemBuilder: (context, index) {
                  return FlexusGymExpansionTile(locationData: searchResults[index]);
                },
                itemCount: searchResults.length,
              ),
            );
          } else {
            return Scaffold(
              backgroundColor: AppSettings.background,
              body: Center(
                child: Text(
                  'No results found',
                  style: TextStyle(fontSize: AppSettings.fontSize),
                ),
              ),
            );
          }
        }
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return FutureBuilder(
      future: searchLocations(query),
      builder: (BuildContext context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: AppSettings.background,
            body: Center(child: CircularProgressIndicator(color: AppSettings.primary)),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: AppSettings.background,
            body: Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: TextStyle(fontSize: AppSettings.fontSize),
              ),
            ),
          );
        } else {
          final List<Map<String, dynamic>> searchResults = snapshot.data ?? [];

          if (searchResults.isNotEmpty) {
            return Scaffold(
              backgroundColor: AppSettings.background,
              body: ListView.builder(
                itemBuilder: (context, index) {
                  return FlexusGymExpansionTile(locationData: searchResults[index]);
                },
                itemCount: searchResults.length,
              ),
            );
          } else {
            return Scaffold(
              backgroundColor: AppSettings.background,
              body: Center(
                child: Text(
                  'No results found',
                  style: TextStyle(fontSize: AppSettings.fontSize),
                ),
              ),
            );
          }
        }
      },
    );
  }
}

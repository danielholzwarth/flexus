import 'package:app/bloc/gym_bloc/gym_bloc.dart';
import 'package:app/bloc/user_account_bloc/user_account_bloc.dart';
import 'package:app/bloc/workout_bloc/workout_bloc.dart';
import 'package:app/hive/gym/gym_overview.dart';
import 'package:app/hive/user_account/user_account.dart';
import 'package:app/pages/friends/add_friend.dart';
import 'package:app/pages/profile/profile.dart';
import 'package:app/pages/sign_in/login.dart';
import 'package:app/resources/app_settings.dart';
import 'package:app/search_delegates/gym_search_delegate.dart';
import 'package:app/widgets/buttons/flexus_button.dart';
import 'package:app/widgets/buttons/flexus_floating_action_button.dart';
import 'package:app/widgets/flexus_scrollbar.dart';
import 'package:app/widgets/flexus_sliver_appbar.dart';
import 'package:app/widgets/flexuse_no_connection_scaffold.dart';
import 'package:app/widgets/list_tiles/flexus_gym_overview_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:page_transition/page_transition.dart';

class GymPage extends StatefulWidget {
  const GymPage({super.key});

  @override
  State<GymPage> createState() => _GymPageState();
}

class _GymPageState extends State<GymPage> {
  final ScrollController scrollController = ScrollController();
  final userBox = Hive.box('userBox');
  final GymBloc gymBloc = GymBloc();
  final WorkoutBloc workoutBloc = WorkoutBloc();

  @override
  Widget build(BuildContext context) {
    if (AppSettings.hasConnection) {
      gymBloc.add(GetGymOverviews());

      return Scaffold(
        backgroundColor: AppSettings.background,
        body: FlexusScrollBar(
          scrollController: scrollController,
          child: CustomScrollView(
            controller: scrollController,
            slivers: <Widget>[
              buildAppBar(context),
              buildGyms(),
            ],
          ),
        ),
        floatingActionButton: buildFloatingActionButton(context),
      );
    } else {
      return const FlexusNoConnectionScaffold();
    }
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
                    key: UniqueKey(),
                    gymOverview: state.gymOverviews[index],
                    func: () {
                      gymBloc.add(GetGymOverviews());
                    },
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
    Set<String> items = {"No Gym selected"};
    String selectedItem = "No Gym selected";

    dynamic selectedTimeHour = userBox.get("recentGymTimeHour");
    dynamic selectedTimeMinute = userBox.get("recentGymTimeMinute");
    TimeOfDay selectedTime;
    if (selectedTimeHour != null && selectedTimeMinute != null) {
      selectedTime = TimeOfDay(hour: selectedTimeHour, minute: selectedTimeMinute);
    } else {
      selectedTime = TimeOfDay.now();
    }

    return FlexusFloatingActionButton(
      onPressed: () async {
        List<GymOverview> gymOverviews = userBox.get("gymOverviews") ?? [];
        gymOverviews = gymOverviews.cast<GymOverview>();

        String recentName = userBox.get("recentGymName") ?? "";
        bool areGymNamesUnique = true;

        for (var gymOverview in gymOverviews) {
          String itemName = userBox.get("customGymName${gymOverview.gym.id}") ?? gymOverview.gym.name;

          if (areGymNamesUnique) {
            areGymNamesUnique = items.add(itemName);
          }

          if (itemName == recentName) {
            selectedItem = itemName;
          }
        }

        if (recentName != selectedItem) {
          userBox.delete("recentGymName");
        }

        if (areGymNamesUnique) {
          await showModalBottomSheet(
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
                                    alignment: Alignment.center,
                                    borderRadius: BorderRadius.circular(20),
                                    isExpanded: true,
                                    icon: Container(),
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
                              userBox.put("recentGymName", selectedItem);
                              userBox.put("recentGymTimeHour", selectedTime.hour);
                              userBox.put("recentGymTimeMinute", selectedTime.minute);

                              DateTime startTime = DateTime.now().copyWith(hour: selectedTime.hour, minute: selectedTime.minute);

                              GymOverview? pickedGymOverview = gymOverviews.firstWhereOrNull((element) => element.gym.name == selectedItem);
                              if (pickedGymOverview != null) {
                                workoutBloc.add(PostWorkout(gymID: pickedGymOverview.gym.id, startTime: startTime));
                              } else {
                                workoutBloc.add(PostWorkout(gymID: null, startTime: startTime));
                              }

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
          setState(() {});
        } else {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Center(
                child: Text("Gyms can not have the same name."),
              ),
            ),
          );
        }
      },
      icon: Icons.notification_add_outlined,
    );
  }

  FlexusSliverAppBar buildAppBar(BuildContext context) {
    UserAccount userAccount = userBox.get("userAccount");
    return FlexusSliverAppBar(
      isPinned: false,
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
        Visibility(
          visible: AppSettings.isTokenExpired,
          child: IconButton(
            icon: Icon(
              Icons.sync,
              size: AppSettings.fontSizeTitle,
              color: AppSettings.error,
            ),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                PageTransition(
                  type: PageTransitionType.fade,
                  child: const LoginPage(),
                ),
              );
            },
          ),
        ),
        Visibility(
          visible: !AppSettings.hasConnection,
          child: IconButton(
            icon: Icon(
              Icons.wifi_off,
              size: AppSettings.fontSizeTitle,
              color: AppSettings.error,
            ),
            onPressed: () {},
          ),
        ),
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
          onPressed: () async {
            await showSearch(context: context, delegate: GymsCustomSearchDelegate());
            gymBloc.add(GetGymOverviews());
          },
        ),
      ],
    );
  }
}

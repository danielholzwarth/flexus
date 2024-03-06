import 'package:app/bloc/gym_bloc/gym_bloc.dart';
import 'package:app/bloc/user_account_bloc/user_account_bloc.dart';
import 'package:app/hive/user_account.dart';
import 'package:app/pages/gym_and_friends/add_friend.dart';
import 'package:app/pages/gym_and_friends/add_gym.dart';
import 'package:app/pages/home/profile.dart';
import 'package:app/resources/app_settings.dart';
import 'package:app/widgets/buttons/flexus_button.dart';
import 'package:app/widgets/flexus_bottom_navigation_bar.dart';
import 'package:app/widgets/buttons/flexus_floating_action_button.dart';
import 'package:app/widgets/flexus_sliver_appbar.dart';
import 'package:app/widgets/list_tiles/flexus_gym_overview_list_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
      bottomNavigationBar: FlexusBottomNavigationBar(
        scrollController: scrollController,
        pageIndex: 2,
      ),
    );
  }

  Widget buildGyms() {
    return BlocBuilder(
      bloc: gymBloc,
      builder: (context, state) {
        if (state is GymOverviewsLoading) {
          return SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: AppSettings.primary)));
        } else if (state is GymOverviewsLoaded) {
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
                'Error loading workouts',
                style: TextStyle(fontSize: AppSettings.fontSize),
              ),
            ),
          );
        } else {
          return SliverFillRemaining(
            child: Center(
              child: Text(
                'Error XYZ',
                style: TextStyle(fontSize: AppSettings.fontSize),
              ),
            ),
          );
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
            Icons.person_add,
            size: AppSettings.fontSizeTitle,
          ),
          onPressed: () {
            Navigator.push(
              context,
              PageTransition(
                type: PageTransitionType.fade,
                child: const AddFriendPage(),
              ),
            );
          },
        ),
        IconButton(
          icon: Icon(
            Icons.add_business,
            size: AppSettings.fontSizeTitle,
          ),
          onPressed: () {
            Navigator.push(
              context,
              PageTransition(
                type: PageTransitionType.fade,
                child: const AddGymPage(),
              ),
            );
          },
        ),
      ],
    );
  }
}

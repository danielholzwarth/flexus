import 'package:app/hive/user_account.dart';
import 'package:app/pages/friends/add_friend.dart';
import 'package:app/pages/friends/add_location.dart';
import 'package:app/pages/home/profile.dart';
import 'package:app/resources/app_settings.dart';
import 'package:app/widgets/flexus_bottom_navigation_bar.dart';
import 'package:app/widgets/buttons/flexus_floating_action_button.dart';
import 'package:app/widgets/flexus_sliver_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hive/hive.dart';
import 'package:page_transition/page_transition.dart';

class LocationsPage extends StatefulWidget {
  const LocationsPage({super.key});

  @override
  State<LocationsPage> createState() => _LocationsPageState();
}

class _LocationsPageState extends State<LocationsPage> {
  final ScrollController scrollController = ScrollController();
  final userBox = Hive.box('userBox');

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppSettings.background,
      body: CustomScrollView(
        controller: scrollController,
        slivers: <Widget>[
          buildAppBar(context, screenWidth),
        ],
      ),
      floatingActionButton: buildFloatingActionButton(context, screenWidth, screenHeight),
      bottomNavigationBar: FlexusBottomNavigationBar(
        scrollController: scrollController,
        pageIndex: 2,
      ),
    );
  }

  FlexusFloatingActionButton buildFloatingActionButton(BuildContext context, double screenWidth, double screenHeight) {
    String selectedItem = 'Energym';
    List<String> items = ['Energym', 'Jumpers', 'CleverFit'];

    return FlexusFloatingActionButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return StatefulBuilder(
              builder: (context, setState) {
                return AlertDialog(
                  titleTextStyle: TextStyle(color: AppSettings.font),
                  backgroundColor: AppSettings.background,
                  title: Text(
                    textAlign: TextAlign.center,
                    "Send Notification?",
                    style: TextStyle(
                      color: AppSettings.font,
                      fontSize: AppSettings.fontSizeTitle,
                    ),
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text("Let your friends know when you arrive at your destination!"),
                      SizedBox(height: screenHeight * 0.02),
                      DropdownButton<String>(
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
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      Container(width: screenWidth / 2, height: 1, color: AppSettings.primaryShade80),
                      SizedBox(height: screenHeight * 0.01),
                      TextButton(
                        onPressed: () async {
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
                            debugPrint(pickedTime.toString());
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                          child: Text(
                            "30 min",
                            style: TextStyle(
                              fontSize: AppSettings.fontSize,
                              color: AppSettings.font,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                          child: Text(
                            "Send Notification",
                            style: TextStyle(
                              fontSize: AppSettings.fontSize,
                              color: AppSettings.font,
                            ),
                          ),
                        ),
                      ),
                    ],
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

  FlexusSliverAppBar buildAppBar(BuildContext context, double screenWidth) {
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
                child: const AddLocationPage(),
              ),
            );
          },
        ),
        IconButton(
          icon: Icon(
            Icons.search,
            size: AppSettings.fontSizeTitle,
          ),
          onPressed: () {
            debugPrint("search");
          },
        ),
      ],
    );
  }
}

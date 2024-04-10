// ignore_for_file: use_build_context_synchronously

import 'package:app/api/user_account/user_account_service.dart';
import 'package:app/api/user_list/user_list_service.dart';
import 'package:app/bloc/settings_bloc/settings_bloc.dart';
import 'package:app/bloc/user_list_bloc/user_list_bloc.dart';
import 'package:app/hive/user_account/user_account.dart';
import 'package:app/hive/user_settings/user_settings.dart';
import 'package:app/pages/sign_in/startup.dart';
import 'package:app/resources/app_settings.dart';
import 'package:app/search_delegates/user_list_search_delegate.dart';
import 'package:app/widgets/flexus_scrollbar.dart';
import 'package:app/widgets/list_tiles/flexus_settings_list_tile.dart';
import 'package:app/widgets/flexus_sliver_appbar.dart';
import 'package:chopper/chopper.dart' as chopper;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:page_transition/page_transition.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final userBox = Hive.box('userBox');
  final ScrollController scrollController = ScrollController();
  final SettingsBloc settingsBloc = SettingsBloc();
  UserListBloc pullUserListBloc = UserListBloc();
  UserListBloc notifyUserListBloc = UserListBloc();

  final TextEditingController textEditingController = TextEditingController();

  @override
  void initState() {
    settingsBloc.add(GetSettings());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppSettings.background,
      body: BlocBuilder(
        bloc: settingsBloc,
        builder: (context, state) {
          if (state is SettingsLoaded) {
            final UserAccount userAccount = userBox.get("userAccount");
            return FlexusScrollBar(
              scrollController: scrollController,
              child: CustomScrollView(
                controller: scrollController,
                slivers: <Widget>[
                  const FlexusSliverAppBar(
                    title: Text("Settings"),
                  ),
                  _buildSection("My Account"),
                  buildName(userAccount, context),
                  buildUsername(userAccount, context),
                  buildPassword(context),
                  _buildSection("Appearance"),
                  buildFontSize(state.userSettings, context),
                  buildDarkMode(state.userSettings),
                  buildQuickAccess(state.userSettings),
                  // buildFeatureCreep(userSettings),
                  _buildSection("Privacy"),
                  buildIsListed(state.userSettings),
                  buildIsPullFromEveryone(state.userSettings),
                  buildPullUserList(state.userSettings),
                  buildNotifyEveryone(state.userSettings),
                  buildNotifyUserList(state.userSettings),
                  SliverToBoxAdapter(child: SizedBox(height: AppSettings.screenHeight * 0.05)),
                  buildLogOut(context),
                  buildDeleteAccount(context),
                  SliverToBoxAdapter(child: SizedBox(height: AppSettings.screenHeight * 0.3)),
                ],
              ),
            );
          } else {
            return Center(child: CircularProgressIndicator(color: AppSettings.primary));
          }
        },
      ),
    );
  }

  SliverToBoxAdapter buildDeleteAccount(BuildContext context) {
    return SliverToBoxAdapter(
      child: Center(
        child: TextButton(
          style: ButtonStyle(backgroundColor: MaterialStateProperty.all(AppSettings.background)),
          child: Text(
            "Delete Account",
            style: TextStyle(
              fontSize: AppSettings.fontSize,
              color: AppSettings.error,
            ),
          ),
          onPressed: () async {
            if (AppSettings.hasConnection) {
              UserAccountService uas = UserAccountService.create();
              final response = await uas.deleteUserAccount(userBox.get("flexusjwt"));
              if (response.isSuccessful) {
                userBox.clear();
                Navigator.push(
                  context,
                  PageTransition(
                    type: PageTransitionType.fade,
                    child: const StartUpPage(),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Center(
                      child: Text(response.error.toString()),
                    ),
                  ),
                );
              }
            } else {
              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('This feature requires internet connection!'),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  SliverToBoxAdapter buildLogOut(BuildContext context) {
    return SliverToBoxAdapter(
      child: Center(
        child: TextButton(
          child: Text(
            "Log out",
            style: TextStyle(
              fontSize: AppSettings.fontSize,
              color: AppSettings.error,
            ),
          ),
          onPressed: () {
            userBox.clear();
            Navigator.push(
              context,
              PageTransition(
                type: PageTransitionType.fade,
                child: const StartUpPage(),
              ),
            );
          },
        ),
      ),
    );
  }

  SliverToBoxAdapter buildNotifyUserList(UserSettings userSettings) {
    if (userSettings.notifyUserListID != null) {
      notifyUserListBloc.add(GetEntireUserList(listID: userSettings.notifyUserListID!));
    }

    return SliverToBoxAdapter(
      child: Visibility(
        visible: !userSettings.isNotifyEveryone,
        child: BlocBuilder(
          bloc: notifyUserListBloc,
          builder: (context, state) {
            if (state is EntireUserListLoaded) {
              return FlexusSettingsListTile(
                title: "Notify User List",
                value: state.userList.isNotEmpty
                    ? state.userList.length > 1
                        ? "${state.userList.length} Friends"
                        : "${state.userList.length} Friend"
                    : "empty",
                isText: true,
                onPressed: () async {
                  if (AppSettings.hasConnection) {
                    if (userSettings.notifyUserListID != null) {
                      await showSearch(context: context, delegate: UserListCustomSearchDelegate(listID: userSettings.notifyUserListID!));
                      setState(() {});
                    } else {
                      ScaffoldMessenger.of(context).clearSnackBars();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Center(
                            child: Text("Error loading user list! Please open settings again!"),
                          ),
                        ),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('This feature requires internet connection!'),
                      ),
                    );
                  }
                },
              );
            } else {
              return ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: AppSettings.fontSize),
                tileColor: AppSettings.background,
                title: Text(
                  "Notify User List",
                  style: TextStyle(fontSize: AppSettings.fontSize, fontWeight: FontWeight.w500),
                ),
                trailing: CircularProgressIndicator(color: AppSettings.primary),
              );
            }
          },
        ),
      ),
    );
  }

  SliverToBoxAdapter buildNotifyEveryone(UserSettings userSettings) {
    return SliverToBoxAdapter(
      child: FlexusSettingsListTile(
        title: "Notify Everyone",
        subtitle: "Who do you want to notify about your status?",
        value: userSettings.isNotifyEveryone,
        isBool: true,
        onChanged: (value) async {
          if (userSettings.notifyUserListID == null) {
            final UserListService userListService = UserListService.create();

            chopper.Response response = await userListService.postUserList(userBox.get("flexusjwt"), {"columnName": "notify_user_list_id"});

            if (response.isSuccessful) {
              if (response.body != "null") {
                userSettings.notifyUserListID = response.body;
                userBox.put("userSettings", userSettings);

                settingsBloc.add(PatchSettings(name: "isNotifyEveryone", value: value));
              } else {
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Center(
                      child: Text("Error creating userlist. Was returned empty!"),
                    ),
                  ),
                );
              }
            } else {
              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Center(
                    child: Text('Error: ${response.error}'),
                  ),
                ),
              );
            }
          } else {
            settingsBloc.add(PatchSettings(name: "isNotifyEveryone", value: value));
          }
        },
      ),
    );
  }

  SliverToBoxAdapter buildPullUserList(UserSettings userSettings) {
    if (userSettings.pullUserListID != null) {
      pullUserListBloc.add(GetEntireUserList(listID: userSettings.pullUserListID!));
    }

    return SliverToBoxAdapter(
      child: Visibility(
        visible: !userSettings.isPullFromEveryone,
        child: BlocBuilder(
          bloc: pullUserListBloc,
          builder: (context, state) {
            if (state is EntireUserListLoaded) {
              return FlexusSettingsListTile(
                title: "Pull User List",
                value: state.userList.isNotEmpty
                    ? state.userList.length > 1
                        ? "${state.userList.length} Friends"
                        : "${state.userList.length} Friend"
                    : "empty",
                isText: true,
                onPressed: () async {
                  if (AppSettings.hasConnection) {
                    if (userSettings.pullUserListID != null) {
                      await showSearch(context: context, delegate: UserListCustomSearchDelegate(listID: userSettings.pullUserListID!));
                      setState(() {});
                    } else {
                      ScaffoldMessenger.of(context).clearSnackBars();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Center(
                            child: Text("Error loading user list! Please open settings again!"),
                          ),
                        ),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('This feature requires internet connection!'),
                      ),
                    );
                  }
                },
              );
            } else {
              return ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: AppSettings.fontSize),
                tileColor: AppSettings.background,
                title: Text(
                  "Pull User List",
                  style: TextStyle(fontSize: AppSettings.fontSize, fontWeight: FontWeight.w500),
                ),
                trailing: CircularProgressIndicator(color: AppSettings.primary),
              );
            }
          },
        ),
      ),
    );
  }

  SliverToBoxAdapter buildIsPullFromEveryone(UserSettings userSettings) {
    return SliverToBoxAdapter(
      child: FlexusSettingsListTile(
        title: "Pull From Everyone",
        subtitle: "Who do you want to be notified by about the status?",
        value: userSettings.isPullFromEveryone,
        isBool: true,
        onChanged: (value) async {
          if (userSettings.pullUserListID == null) {
            final UserListService userListService = UserListService.create();

            chopper.Response response = await userListService.postUserList(userBox.get("flexusjwt"), {"columnName": "pull_user_list_id"});

            if (response.isSuccessful) {
              if (response.body != "null") {
                userSettings.pullUserListID = response.body;
                userBox.put("userSettings", userSettings);

                settingsBloc.add(PatchSettings(name: "isPullFromEveryone", value: value));

                pullUserListBloc.add(GetEntireUserList(listID: response.body));
              } else {
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Center(
                      child: Text("Error creating userlist. Was returned empty!"),
                    ),
                  ),
                );
              }
            } else {
              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Center(
                    child: Text('Error: ${response.error}'),
                  ),
                ),
              );
            }
          } else {
            settingsBloc.add(PatchSettings(name: "isPullFromEveryone", value: value));
          }
        },
      ),
    );
  }

  SliverToBoxAdapter buildIsListed(UserSettings userSettings) {
    return SliverToBoxAdapter(
      child: FlexusSettingsListTile(
        title: "Is Listed",
        subtitle: "Do you want to be listed in the search of other users?",
        value: !userSettings.isUnlisted,
        isBool: true,
        onChanged: (value) {
          settingsBloc.add(PatchSettings(name: "isUnlisted", value: !value));
        },
      ),
    );
  }

  // SliverToBoxAdapter buildFeatureCreep(UserSettings userSettings) {
  //   return SliverToBoxAdapter(
  //     child: FlexusSettingsListTile(
  //       title: "Feature Creep",
  //       subtitle: "Choose which functions of Flexus you want to use. Deactivate what disturbs you.",
  //       isText: true,
  //       value: "",
  //       onPressed: () {
  //         ScaffoldMessenger.of(context).clearSnackBars();
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           const SnackBar(
  //             content: Center(
  //               child: Text("Not implemented yet :("),
  //             ),
  //           ),
  //         );
  //       },
  //     ),
  //   );
  // }

  SliverToBoxAdapter buildQuickAccess(UserSettings userSettings) {
    return SliverToBoxAdapter(
      child: FlexusSettingsListTile(
        title: "Quick Access",
        subtitle: "Display a Quick Access screen when you start the application.",
        value: userSettings.isQuickAccess,
        isBool: true,
        onChanged: (value) {
          settingsBloc.add(PatchSettings(name: "isQuickAccess", value: value));
        },
      ),
    );
  }

  SliverToBoxAdapter buildDarkMode(UserSettings userSettings) {
    return SliverToBoxAdapter(
      child: FlexusSettingsListTile(
        title: "Dark Mode",
        value: userSettings.isDarkMode,
        isBool: true,
        onChanged: (value) {
          settingsBloc.add(PatchSettings(name: "isDarkMode", value: value));
        },
      ),
    );
  }

  SliverToBoxAdapter buildFontSize(UserSettings userSettings, BuildContext context) {
    return SliverToBoxAdapter(
      child: FlexusSettingsListTile(
        title: "Fontsize",
        value: userSettings.fontSize,
        isText: true,
        onPressed: () => showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: AppSettings.background,
              content: TextField(
                autofocus: true,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Fontsize",
                  labelStyle: TextStyle(color: AppSettings.primary),
                  border: UnderlineInputBorder(borderSide: BorderSide(color: AppSettings.primary, width: 2)),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppSettings.primary, width: 2)),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppSettings.primary, width: 2)),
                ),
                controller: textEditingController,
                onEditingComplete: () {
                  double? fontSize = double.tryParse(textEditingController.text);
                  if (fontSize != null) {
                    settingsBloc.add(PatchSettings(name: "fontSize", value: fontSize));
                    textEditingController.clear();
                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Center(
                          child: Text('Invalid input for fontsize'),
                        ),
                      ),
                    );
                  }
                },
                onTapOutside: (event) {
                  textEditingController.clear();
                },
              ),
            );
          },
        ),
      ),
    );
  }

  SliverToBoxAdapter buildPassword(BuildContext context) {
    return SliverToBoxAdapter(
      child: FlexusSettingsListTile(
        title: "Password",
        value: "password",
        isObscure: true,
        onPressed: () {
          if (AppSettings.hasConnection) {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                final TextEditingController oldPasswordController = TextEditingController();
                final TextEditingController newPasswordController = TextEditingController();
                final TextEditingController confirmNewPasswordController = TextEditingController();

                return AlertDialog(
                  backgroundColor: AppSettings.background,
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        autofocus: true,
                        decoration: InputDecoration(
                          labelText: "Old Password",
                          labelStyle: TextStyle(color: AppSettings.primary),
                          border: UnderlineInputBorder(borderSide: BorderSide(color: AppSettings.primary, width: 2)),
                          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppSettings.primary, width: 2)),
                          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppSettings.primary, width: 2)),
                        ),
                        controller: oldPasswordController,
                        obscureText: true,
                      ),
                      SizedBox(height: AppSettings.screenHeight * 0.02),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: "New Password",
                          labelStyle: TextStyle(color: AppSettings.primary),
                          border: UnderlineInputBorder(borderSide: BorderSide(color: AppSettings.primary, width: 2)),
                          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppSettings.primary, width: 2)),
                          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppSettings.primary, width: 2)),
                        ),
                        controller: newPasswordController,
                        obscureText: true,
                      ),
                      SizedBox(height: AppSettings.screenHeight * 0.02),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: "Confirm New Password",
                          labelStyle: TextStyle(color: AppSettings.primary),
                          border: UnderlineInputBorder(borderSide: BorderSide(color: AppSettings.primary, width: 2)),
                          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppSettings.primary, width: 2)),
                          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppSettings.primary, width: 2)),
                        ),
                        controller: confirmNewPasswordController,
                        obscureText: true,
                        onEditingComplete: () {
                          final newPassword = newPasswordController.text;
                          final confirmedPassword = confirmNewPasswordController.text;

                          if (newPassword != confirmedPassword) {
                            ScaffoldMessenger.of(context).clearSnackBars();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Passwords do not match'),
                              ),
                            );
                          } else if (newPassword.length > 128) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Password cannot be longer than 128 characters'),
                              ),
                            );
                          } else if (newPassword.length < 8) {
                            ScaffoldMessenger.of(context).clearSnackBars();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Password must be at least 8 characters long'),
                              ),
                            );
                          } else {
                            settingsBloc.add(
                                PatchSettings(name: "password", value: newPasswordController.text.trim(), value2: oldPasswordController.text.trim()));

                            Navigator.pop(context);
                            oldPasswordController.clear();
                            newPasswordController.clear();
                            confirmNewPasswordController.clear();
                          }
                        },
                        onTapOutside: (_) {
                          oldPasswordController.clear();
                          newPasswordController.clear();
                          confirmNewPasswordController.clear();
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          } else {
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('This feature requires internet connection!'),
              ),
            );
          }
        },
      ),
    );
  }

  SliverToBoxAdapter buildUsername(UserAccount userAccount, BuildContext context) {
    return SliverToBoxAdapter(
      child: FlexusSettingsListTile(
        title: "Username",
        subtitle: "The username must be unique.",
        value: userAccount.username,
        isText: true,
        onPressed: () => showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: AppSettings.background,
              content: TextField(
                decoration: InputDecoration(
                  labelText: "Username",
                  labelStyle: TextStyle(color: AppSettings.primary),
                  border: UnderlineInputBorder(borderSide: BorderSide(color: AppSettings.primary, width: 2)),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppSettings.primary, width: 2)),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppSettings.primary, width: 2)),
                ),
                autofocus: true,
                controller: textEditingController,
                onEditingComplete: () {
                  if (textEditingController.text.length > 20) {
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Center(
                          child: Text('Username can not be longer than 20 characters'),
                        ),
                      ),
                    );
                  } else if (textEditingController.text.length < 6) {
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Center(
                          child: Text('Username must be at least 6 characters long'),
                        ),
                      ),
                    );
                  } else {
                    settingsBloc.add(PatchSettings(name: "username", value: textEditingController.text));
                    Navigator.pop(context);
                    textEditingController.clear();
                  }
                },
                onTapOutside: (event) {
                  textEditingController.clear();
                },
              ),
            );
          },
        ),
      ),
    );
  }

  SliverToBoxAdapter buildName(UserAccount userAccount, BuildContext context) {
    return SliverToBoxAdapter(
      child: FlexusSettingsListTile(
        title: "Name",
        subtitle: "This is the name mostly shown to your friendship.",
        value: userAccount.name,
        isText: true,
        onPressed: () => showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: AppSettings.background,
              content: TextField(
                autofocus: true,
                decoration: InputDecoration(
                  labelText: "Name",
                  labelStyle: TextStyle(color: AppSettings.primary),
                  border: UnderlineInputBorder(borderSide: BorderSide(color: AppSettings.primary, width: 2)),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppSettings.primary, width: 2)),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppSettings.primary, width: 2)),
                ),
                controller: textEditingController,
                onEditingComplete: () {
                  if (textEditingController.text.length > 20) {
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Center(
                          child: Text('Name can not be longer than 20 characters'),
                        ),
                      ),
                    );
                  } else if (textEditingController.text.isNotEmpty) {
                    settingsBloc.add(PatchSettings(name: "name", value: textEditingController.text));
                  }
                  Navigator.pop(context);
                  textEditingController.clear();
                },
                onTapOutside: (event) {
                  textEditingController.clear();
                },
              ),
            );
          },
        ),
      ),
    );
  }

  SliverAppBar _buildSection(String title) {
    return SliverAppBar(
      title: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          title,
          style: TextStyle(fontSize: AppSettings.fontSizeH3, fontWeight: FontWeight.bold),
        ),
      ),
      automaticallyImplyLeading: false,
      backgroundColor: AppSettings.background,
      elevation: 0,
      foregroundColor: AppSettings.font,
      surfaceTintColor: AppSettings.background,
    );
  }
}

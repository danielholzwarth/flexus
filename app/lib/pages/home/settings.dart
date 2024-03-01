// ignore_for_file: use_build_context_synchronously

import 'package:app/api/user_account_service.dart';
import 'package:app/bloc/settings_bloc/settings_bloc.dart';
import 'package:app/hive/user_account.dart';
import 'package:app/hive/user_settings.dart';
import 'package:app/pages/login/startup.dart';
import 'package:app/resources/app_settings.dart';
import 'package:app/widgets/flexus_settings_list_tile.dart';
import 'package:app/widgets/flexus_sliver_appbar.dart';
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
  final TextEditingController textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    settingsBloc.add(LoadSettings());
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: AppSettings.background,
      body: BlocBuilder(
        bloc: settingsBloc,
        builder: (context, state) {
          if (state is SettingsLoading || state is SettingsUpdating) {
            return Center(child: CircularProgressIndicator(color: AppSettings.primary));
          } else if (state is SettingsLoaded) {
            final UserSettings userSettings = userBox.get("userSettings");
            final UserAccount userAccount = userBox.get("userAccount");
            return CustomScrollView(
              controller: scrollController,
              slivers: <Widget>[
                const FlexusSliverAppBar(
                  title: Text("Settings"),
                ),
                _buildSection("My Account"),
                SliverToBoxAdapter(
                  child: FlexusSettingsListTile(
                    title: "Name",
                    subtitle: "This is the name mostly shown to your friends.",
                    value: userAccount.name,
                    isText: true,
                    onPressed: () => showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          content: TextField(
                            autofocus: true,
                            decoration: InputDecoration(hintText: userAccount.name),
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
                                settingsBloc.add(UpdateSettings(name: "name", value: textEditingController.text));
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
                ),
                SliverToBoxAdapter(
                  child: FlexusSettingsListTile(
                    title: "Username",
                    subtitle: "The username must be unique.",
                    value: userAccount.username,
                    isText: true,
                    onPressed: () => showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          content: TextField(
                            autofocus: true,
                            decoration: InputDecoration(hintText: userAccount.username),
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
                                settingsBloc.add(UpdateSettings(name: "username", value: textEditingController.text));
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
                ),
                SliverToBoxAdapter(
                  child: FlexusSettingsListTile(
                    title: "Password",
                    value: "password",
                    isObscure: true,
                    onPressed: () => showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          content: TextField(
                            autofocus: true,
                            decoration: const InputDecoration(hintText: "****************"),
                            controller: textEditingController,
                            onEditingComplete: () {
                              if (textEditingController.text.length > 128) {
                                ScaffoldMessenger.of(context).clearSnackBars();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Center(
                                      child: Text('Password can not be longer than 128 characters'),
                                    ),
                                  ),
                                );
                              } else if (textEditingController.text.length < 8) {
                                ScaffoldMessenger.of(context).clearSnackBars();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Center(
                                      child: Text('Username must be at least 8 characters long'),
                                    ),
                                  ),
                                );
                              } else {
                                //settingsBloc.add(UpdateSettings(name: "password", value: textEditingController.text));
                                ScaffoldMessenger.of(context).clearSnackBars();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Center(
                                      child: Text('Not implemented yet'),
                                    ),
                                  ),
                                );
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
                ),
                _buildSection("Appearance"),
                SliverToBoxAdapter(
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
                            decoration: InputDecoration(hintText: userSettings.fontSize.toString()),
                            controller: textEditingController,
                            onEditingComplete: () {
                              double? fontSize = double.tryParse(textEditingController.text);
                              if (fontSize != null) {
                                settingsBloc.add(UpdateSettings(name: "fontSize", value: fontSize));
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
                ),
                SliverToBoxAdapter(
                  child: FlexusSettingsListTile(
                    title: "Dark Mode",
                    value: userSettings.isDarkMode,
                    isBool: true,
                    onChanged: (value) {
                      settingsBloc.add(UpdateSettings(name: "dark_mode", value: value));
                    },
                  ),
                ),
                _buildSection("Status"),
                SliverToBoxAdapter(
                  child: FlexusSettingsListTile(
                    title: "Pull From Everyone",
                    subtitle: "Who do you want to be notified by about the status?",
                    value: userSettings.isPullFromEveryone,
                    isBool: true,
                  ),
                ),
                SliverToBoxAdapter(
                  child: Visibility(
                    visible: userSettings.isPullFromEveryone,
                    child: const FlexusSettingsListTile(
                      title: "Pull User List",
                      value: "not implemented yet",
                      isText: true,
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: FlexusSettingsListTile(
                    title: "Notify Everyone",
                    subtitle: "Who do you want to notify about your status?",
                    value: userSettings.isNotifyEveryone,
                    isBool: true,
                  ),
                ),
                const SliverToBoxAdapter(
                  child: Visibility(
                    visible: true,
                    child: FlexusSettingsListTile(
                      title: "Notify User List",
                      value: "not implemented yet",
                      isText: true,
                    ),
                  ),
                ),
                _buildSection("Data Storage"),
                const SliverToBoxAdapter(
                  child: FlexusSettingsListTile(
                    title: "Save all data on Server",
                    subtitle: "Should we store all your data on the server so you have a backup?",
                    value: true,
                    isBool: true,
                  ),
                ),
                const SliverToBoxAdapter(
                  child: Visibility(
                    visible: true,
                    child: FlexusSettingsListTile(
                      title: "Store only necessary data",
                      subtitle: "For some features to work (friends) we need to save some data on the server.",
                      value: false,
                      isBool: true,
                    ),
                  ),
                ),
                SliverToBoxAdapter(
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
                ),
                SliverToBoxAdapter(
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
                      },
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                    child: SizedBox(
                  height: screenHeight * 0.3,
                )),
              ],
            );
          } else {
            return const Text("err");
          }
        },
      ),
    );
  }

  SliverAppBar _buildSection(String title) {
    return SliverAppBar(
      title: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          title,
          style: TextStyle(fontSize: AppSettings.fontSizeTitle, fontWeight: FontWeight.bold),
        ),
      ),
      pinned: true,
      automaticallyImplyLeading: false,
      backgroundColor: AppSettings.background,
      elevation: 0,
      foregroundColor: AppSettings.font,
      surfaceTintColor: AppSettings.background,
    );
  }
}

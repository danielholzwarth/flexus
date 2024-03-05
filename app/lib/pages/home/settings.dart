// ignore_for_file: use_build_context_synchronously

import 'package:app/api/user_account_service.dart';
import 'package:app/bloc/settings_bloc/settings_bloc.dart';
import 'package:app/hive/user_account.dart';
import 'package:app/hive/user_settings.dart';
import 'package:app/pages/login/startup.dart';
import 'package:app/resources/app_settings.dart';
import 'package:app/widgets/list_tiles/flexus_settings_list_tile.dart';
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
    settingsBloc.add(GetSettings());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppSettings.background,
      body: BlocBuilder(
        bloc: settingsBloc,
        builder: (context, state) {
          if (state is SettingsLoading) {
            return Center(child: CircularProgressIndicator(color: AppSettings.primary));
          } else if (state is SettingsLoaded || state is SettingsUpdating) {
            final UserSettings userSettings = userBox.get("userSettings");
            final UserAccount userAccount = userBox.get("userAccount");
            return CustomScrollView(
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
                buildFontSize(userSettings, context),
                buildDarkMode(userSettings),
                _buildSection("Privacy"),
                buildIsListed(userSettings),
                buildIsPullFromEveryone(userSettings),
                buildPullUserList(userSettings),
                buildNotifyEveryone(userSettings),
                buildNotifyUserList(userSettings),
                buildLogOut(context),
                buildDeleteAccount(context),
                SliverToBoxAdapter(child: SizedBox(height: AppSettings.screenHeight * 0.3)),
              ],
            );
          } else {
            return const Text("err");
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
    return SliverToBoxAdapter(
      child: Visibility(
        visible: !userSettings.isNotifyEveryone,
        child: const FlexusSettingsListTile(
          title: "Notify User List",
          value: "not implemented yet",
          isText: true,
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
        onChanged: (value) {
          settingsBloc.add(PatchSettings(name: "isNotifyEveryone", value: value));
        },
      ),
    );
  }

  SliverToBoxAdapter buildPullUserList(UserSettings userSettings) {
    return SliverToBoxAdapter(
      child: Visibility(
        visible: !userSettings.isPullFromEveryone,
        child: const FlexusSettingsListTile(
          title: "Pull User List",
          value: "not implemented yet",
          isText: true,
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
        onChanged: (value) {
          settingsBloc.add(PatchSettings(name: "isPullFromEveryone", value: value));
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
        onPressed: () => showDialog(
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
        ),
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

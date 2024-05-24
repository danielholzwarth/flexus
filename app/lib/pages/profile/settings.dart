// ignore_for_file: use_build_context_synchronously

import 'package:app/api/user_account/user_account_service.dart';
import 'package:app/api/user_list/user_list_service.dart';
import 'package:app/bloc/settings_bloc/settings_bloc.dart';
import 'package:app/bloc/user_list_bloc/user_list_bloc.dart';
import 'package:app/hive/user_account/user_account.dart';
import 'package:app/hive/user_settings/user_settings.dart';
import 'package:app/pages/sign_in/start.dart';
import 'package:app/resources/app_settings.dart';
import 'package:app/search_delegates/user_list_search_delegate.dart';
import 'package:app/widgets/buttons/flexus_button_small.dart';
import 'package:app/widgets/flexus_scrollbar.dart';
import 'package:app/widgets/flexus_textfield.dart';
import 'package:app/widgets/list_tiles/flexus_settings_list_tile.dart';
import 'package:app/widgets/flexus_sliver_appbar.dart';
import 'package:app/widgets/sheets/flexus_show_modal_bottom_sheet_text_field.dart';
import 'package:app/widgets/style/flexus_default_icon.dart';
import 'package:app/widgets/style/flexus_default_text_style.dart';
import 'package:chopper/chopper.dart' as chopper;
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
  final TextEditingController oldPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmNewPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    settingsBloc.add(GetSettings());
  }

  @override
  void dispose() {
    scrollController.dispose();
    textEditingController.dispose();
    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmNewPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppSettings.background,
      body: BlocConsumer(
        bloc: settingsBloc,
        listener: (context, state) {
          if (state is SettingsLoaded) {
            setState(() {});
          }
          if (state is SettingsError) {
            Fluttertoast.cancel();
            Fluttertoast.showToast(
              msg: state.error,
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              backgroundColor: AppSettings.error,
              textColor: AppSettings.fontV1,
              fontSize: AppSettings.fontSize,
            );
          }
        },
        builder: (context, state) {
          if (state is SettingsLoaded) {
            final UserAccount userAccount = userBox.get("userAccount");
            return FlexusScrollBar(
              scrollController: scrollController,
              child: CustomScrollView(
                controller: scrollController,
                slivers: <Widget>[
                  FlexusSliverAppBar(
                    title: CustomDefaultTextStyle(
                      text: "Settings",
                      fontSize: AppSettings.fontSizeH3,
                    ),
                  ),
                  _buildSection("My Account"),
                  buildName(userAccount, context, deviceSize),
                  buildUsername(userAccount, context, deviceSize),
                  buildPassword(context, deviceSize),
                  _buildSection("Appearance"),
                  buildFontSize(state.userSettings, context),
                  buildDarkMode(state.userSettings),
                  // buildQuickAccess(state.userSettings),
                  // buildFeatureCreep(userSettings),
                  _buildSection("Privacy"),
                  buildIsListed(state.userSettings),
                  buildIsPullFromEveryone(state.userSettings),
                  buildPullUserList(state.userSettings),
                  // buildNotifyEveryone(state.userSettings),
                  // buildNotifyUserList(state.userSettings),
                  SliverToBoxAdapter(child: SizedBox(height: deviceSize.height * 0.05)),
                  buildLogOut(context),
                  buildDeleteAccount(context),
                  SliverToBoxAdapter(child: SizedBox(height: deviceSize.height * 0.1)),
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
          child: CustomDefaultTextStyle(
            text: "Delete Account",
            color: AppSettings.error,
          ),
          onPressed: () async {
            if (AppSettings.hasConnection) {
              UserAccountService uas = UserAccountService.create();
              final response = await uas.deleteUserAccount(userBox.get("flexusjwt"));
              if (response.isSuccessful) {
                FlutterBackgroundService().invoke('stopService');
                userBox.clear();
                Navigator.pushAndRemoveUntil(
                  context,
                  PageTransition(
                    type: PageTransitionType.fade,
                    child: const StartUpPage(),
                  ),
                  (route) => false,
                );
              } else {
                Fluttertoast.cancel();
                Fluttertoast.showToast(
                  msg: response.error.toString(),
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.CENTER,
                  backgroundColor: AppSettings.error,
                  textColor: AppSettings.fontV1,
                  fontSize: AppSettings.fontSize,
                );
              }
            } else {
              Fluttertoast.cancel();
              Fluttertoast.showToast(
                msg: 'This feature requires internet connection!',
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
                backgroundColor: AppSettings.error,
                textColor: AppSettings.fontV1,
                fontSize: AppSettings.fontSize,
              );
              Fluttertoast.cancel();
              Fluttertoast.showToast(
                msg: 'This feature requires internet connection!',
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
                backgroundColor: AppSettings.error,
                textColor: AppSettings.fontV1,
                fontSize: AppSettings.fontSize,
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
          child: CustomDefaultTextStyle(
            text: "Log out",
            color: AppSettings.error,
          ),
          onPressed: () {
            FlutterBackgroundService().invoke('stopService');
            userBox.clear();
            Navigator.pushAndRemoveUntil(
              context,
              PageTransition(
                type: PageTransitionType.fade,
                child: const StartUpPage(),
              ),
              (route) => false,
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
                      await showSearch(context: context, delegate: UserListSearchDelegate(listID: userSettings.notifyUserListID!));
                      setState(() {});
                    } else {
                      Fluttertoast.cancel();
                      Fluttertoast.showToast(
                        msg: 'Error loading user list! Please open settings again!',
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        backgroundColor: AppSettings.error,
                        textColor: AppSettings.fontV1,
                        fontSize: AppSettings.fontSize,
                      );
                    }
                  } else {
                    Fluttertoast.cancel();
                    Fluttertoast.showToast(
                      msg: 'This feature requires internet connection!',
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.CENTER,
                      backgroundColor: AppSettings.error,
                      textColor: AppSettings.fontV1,
                      fontSize: AppSettings.fontSize,
                    );
                  }
                },
              );
            }

            if (state is UserListError) {
              return ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: AppSettings.fontSize),
                tileColor: AppSettings.background,
                title: const CustomDefaultTextStyle(text: "Notify User List", fontWeight: FontWeight.w500),
                trailing: FlexusDefaultIcon(iconData: Icons.error, iconColor: AppSettings.error),
              );
            }

            return ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: AppSettings.fontSize),
              tileColor: AppSettings.background,
              title: const CustomDefaultTextStyle(text: "Notify User List", fontWeight: FontWeight.w500),
              trailing: CircularProgressIndicator(color: AppSettings.primary),
            );
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
        onChangedSwitch: (value) async {
          if (userSettings.notifyUserListID == null) {
            final UserListService userListService = UserListService.create();

            chopper.Response response = await userListService.postUserList(userBox.get("flexusjwt"), {"columnName": "notify_user_list_id"});

            if (response.isSuccessful) {
              if (response.body != "null") {
                userSettings.notifyUserListID = response.body;
                userBox.put("userSettings", userSettings);

                settingsBloc.add(PatchSettings(name: "isNotifyEveryone", value: value));
              } else {
                Fluttertoast.cancel();
                Fluttertoast.showToast(
                  msg: 'Error creating userlist. Was returned empty!',
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.CENTER,
                  backgroundColor: AppSettings.error,
                  textColor: AppSettings.fontV1,
                  fontSize: AppSettings.fontSize,
                );
              }
            } else {
              Fluttertoast.cancel();
              Fluttertoast.showToast(
                msg: 'Error: ${response.error}',
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
                backgroundColor: AppSettings.error,
                textColor: AppSettings.fontV1,
                fontSize: AppSettings.fontSize,
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
                      await showSearch(context: context, delegate: UserListSearchDelegate(listID: userSettings.pullUserListID!));
                      setState(() {});
                    } else {
                      Fluttertoast.cancel();
                      Fluttertoast.showToast(
                        msg: 'Error loading user list! Please open settings again!',
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        backgroundColor: AppSettings.error,
                        textColor: AppSettings.fontV1,
                        fontSize: AppSettings.fontSize,
                      );
                    }
                  } else {
                    Fluttertoast.showToast(
                      msg: 'This feature requires internet connection!',
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.CENTER,
                      backgroundColor: AppSettings.error,
                      textColor: AppSettings.fontV1,
                      fontSize: AppSettings.fontSize,
                    );
                  }
                },
              );
            }

            if (state is UserListError) {
              return ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: AppSettings.fontSize),
                tileColor: AppSettings.background,
                title: const CustomDefaultTextStyle(text: "Notify User List", fontWeight: FontWeight.w500),
                trailing: FlexusDefaultIcon(iconData: Icons.error, iconColor: AppSettings.error),
              );
            }

            return ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: AppSettings.fontSize),
              tileColor: AppSettings.background,
              title: const CustomDefaultTextStyle(text: "Pull User List", fontWeight: FontWeight.w500),
              trailing: CircularProgressIndicator(color: AppSettings.primary),
            );
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
        onChangedSwitch: (value) async {
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
                Fluttertoast.cancel();
                Fluttertoast.showToast(
                  msg: 'Error creating userlist. Was returned empty!',
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.CENTER,
                  backgroundColor: AppSettings.error,
                  textColor: AppSettings.fontV1,
                  fontSize: AppSettings.fontSize,
                );
              }
            } else {
              Fluttertoast.cancel();
              Fluttertoast.showToast(
                msg: 'Error: ${response.error}',
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
                backgroundColor: AppSettings.error,
                textColor: AppSettings.fontV1,
                fontSize: AppSettings.fontSize,
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
        onChangedSwitch: (value) {
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
  //         Fluttertoast.cancel();
  //         Fluttertoast.showToast(
  //           msg: 'not implemented yet',
  //           toastLength: Toast.LENGTH_SHORT,
  //           gravity: ToastGravity.CENTER,
  //           backgroundColor: AppSettings.error,
  //           textColor: AppSettings.fontV1,
  //           fontSize: AppSettings.fontSize,
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
        onChangedSwitch: (value) {
          settingsBloc.add(PatchSettings(name: "isQuickAccess", value: value));
        },
      ),
    );
  }

  SliverToBoxAdapter buildDarkMode(UserSettings userSettings) {
    return SliverToBoxAdapter(
      child: FlexusSettingsListTile(
        title: "Dark Mode",
        subtitle: "This is still under development!",
        value: userSettings.isDarkMode,
        isBool: true,
        onChangedSwitch: (value) {
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
        isSlider: true,
        onChangedSlider: (newFontSize) {
          settingsBloc.add(PatchSettings(name: "fontSize", value: newFontSize));
        },
      ),
    );
  }

  SliverToBoxAdapter buildPassword(BuildContext context, Size deviceSize) {
    return SliverToBoxAdapter(
      child: FlexusSettingsListTile(
        title: "Password",
        value: "password",
        isObscure: true,
        onPressed: () {
          if (AppSettings.hasConnection) {
            return showBottomSheet(
              backgroundColor: AppSettings.background,
              context: context,
              builder: (BuildContext context) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40.0),
                      child: CustomDefaultTextStyle(
                        text: "Change Password",
                        fontSize: AppSettings.fontSizeH3,
                      ),
                    ),
                    FlexusTextField(
                      hintText: "Old password",
                      textController: oldPasswordController,
                      isObscure: true,
                      onChanged: (String newValue) {},
                    ),
                    SizedBox(height: deviceSize.height * 0.02),
                    FlexusTextField(
                      hintText: "New password",
                      textController: newPasswordController,
                      isObscure: true,
                      onChanged: (String newValue) {},
                    ),
                    SizedBox(height: deviceSize.height * 0.02),
                    FlexusTextField(
                      hintText: "Confirm new password",
                      textController: confirmNewPasswordController,
                      isObscure: true,
                      onChanged: (String newValue) {},
                    ),
                    SizedBox(height: deviceSize.height * 0.05),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        FlexusButtonSmall(
                          text: "Cancel",
                          width: deviceSize.width * 0.3,
                          fontColor: AppSettings.error,
                          onPressed: () {
                            oldPasswordController.clear();
                            newPasswordController.clear();
                            confirmNewPasswordController.clear();
                            Navigator.pop(context);
                          },
                        ),
                        FlexusButtonSmall(
                          text: "Confirm",
                          width: deviceSize.width * 0.3,
                          onPressed: () {
                            final newPassword = newPasswordController.text;
                            final confirmedPassword = confirmNewPasswordController.text;

                            if (newPassword != confirmedPassword) {
                              Fluttertoast.cancel();
                              Fluttertoast.showToast(
                                msg: 'Passwords do not match',
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.CENTER,
                                backgroundColor: AppSettings.error,
                                textColor: AppSettings.fontV1,
                                fontSize: AppSettings.fontSize,
                              );
                              return;
                            }

                            if (newPassword.length > 128) {
                              Fluttertoast.cancel();
                              Fluttertoast.showToast(
                                msg: 'Password cannot be longer than 128 characters.',
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.CENTER,
                                backgroundColor: AppSettings.error,
                                textColor: AppSettings.fontV1,
                                fontSize: AppSettings.fontSize,
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: CustomDefaultTextStyle(text: 'Password cannot be longer than 128 characters'),
                                ),
                              );
                              return;
                            }

                            if (newPassword.length < 8) {
                              Fluttertoast.cancel();
                              Fluttertoast.showToast(
                                msg: 'Password must be at least 8 characters long',
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.CENTER,
                                backgroundColor: AppSettings.error,
                                textColor: AppSettings.fontV1,
                                fontSize: AppSettings.fontSize,
                              );
                              return;
                            }

                            settingsBloc.add(PatchSettings(
                              name: "password",
                              value: newPasswordController.text.trim(),
                              value2: oldPasswordController.text.trim(),
                            ));

                            oldPasswordController.clear();
                            newPasswordController.clear();
                            confirmNewPasswordController.clear();
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    )
                  ],
                );
              },
            );
          }

          Fluttertoast.cancel();
          Fluttertoast.showToast(
            msg: 'This feature requires internet connection!',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            backgroundColor: AppSettings.error,
            textColor: AppSettings.fontV1,
            fontSize: AppSettings.fontSize,
          );
        },
      ),
    );
  }

  SliverToBoxAdapter buildUsername(UserAccount userAccount, BuildContext context, Size deviceSize) {
    return SliverToBoxAdapter(
      child: FlexusSettingsListTile(
        title: "Username",
        subtitle: "The username must be unique.",
        value: userAccount.username,
        isText: true,
        onPressed: () => FlexusShowModalBottomSheetTextField.show(
          context: context,
          title: "Change Username",
          hintText: userAccount.username,
          textEditingController: textEditingController,
          onCancel: () {
            textEditingController.clear();
            Navigator.pop(context);
          },
          onConfirm: () {
            if (textEditingController.text.length > 20) {
              Fluttertoast.cancel();
              Fluttertoast.showToast(
                msg: 'Username can not be longer than 20 characters',
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
                backgroundColor: AppSettings.error,
                textColor: AppSettings.fontV1,
                fontSize: AppSettings.fontSize,
              );
              return;
            }

            if (textEditingController.text.length < 6) {
              Fluttertoast.cancel();
              Fluttertoast.showToast(
                msg: 'Username must be at least 6 characters long',
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
                backgroundColor: AppSettings.error,
                textColor: AppSettings.fontV1,
                fontSize: AppSettings.fontSize,
              );
              return;
            }

            settingsBloc.add(PatchSettings(name: "username", value: textEditingController.text));
            textEditingController.clear();
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  SliverToBoxAdapter buildName(UserAccount userAccount, BuildContext context, Size deviceSize) {
    return SliverToBoxAdapter(
      child: FlexusSettingsListTile(
        title: "Name",
        subtitle: "This is the name mostly shown to your friendship.",
        value: userAccount.name,
        isText: true,
        onPressed: () => FlexusShowModalBottomSheetTextField.show(
          context: context,
          title: "Change Name",
          hintText: userAccount.name,
          textEditingController: textEditingController,
          onCancel: () {
            textEditingController.clear();
            Navigator.pop(context);
          },
          onConfirm: () {
            if (textEditingController.text.length > 20) {
              Fluttertoast.cancel();
              Fluttertoast.showToast(
                msg: 'Name can not be longer than 20 characters',
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
                backgroundColor: AppSettings.error,
                textColor: AppSettings.fontV1,
                fontSize: AppSettings.fontSize,
              );
              return;
            }

            if (textEditingController.text.isEmpty) {
              Fluttertoast.cancel();
              Fluttertoast.showToast(
                msg: 'Name can not be empty',
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
                backgroundColor: AppSettings.error,
                textColor: AppSettings.fontV1,
                fontSize: AppSettings.fontSize,
              );
              return;
            }

            settingsBloc.add(PatchSettings(name: "name", value: textEditingController.text));
            textEditingController.clear();
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  SliverAppBar _buildSection(String title) {
    return SliverAppBar(
      title: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CustomDefaultTextStyle(
          text: title,
          fontSize: AppSettings.fontSizeH3,
          fontWeight: FontWeight.bold,
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

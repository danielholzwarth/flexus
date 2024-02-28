import 'package:app/bloc/settings_bloc/settings_bloc.dart';
import 'package:app/hive/user_account.dart';
import 'package:app/resources/app_settings.dart';
import 'package:app/widgets/flexus_settings_list_tile.dart';
import 'package:app/widgets/flexus_sliver_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final userBox = Hive.box('userBox');
  final ScrollController scrollController = ScrollController();
  final SettingsBloc settingsBloc = SettingsBloc();

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
      body: BlocConsumer(
        bloc: settingsBloc,
        listener: (context, state) {},
        builder: (context, state) {
          if (state is SettingsLoading) {
            return Center(child: CircularProgressIndicator(color: AppSettings.primary));
          } else if (state is SettingsLoaded) {
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
                  ),
                ),
                SliverToBoxAdapter(
                  child: FlexusSettingsListTile(
                    title: "Username",
                    subtitle: "The username must be unique.",
                    value: userAccount.username,
                    isText: true,
                  ),
                ),
                const SliverToBoxAdapter(
                  child: FlexusSettingsListTile(
                    title: "Password",
                    value: "password",
                    isObscure: true,
                  ),
                ),
                _buildSection("Appearance"),
                SliverToBoxAdapter(
                  child: FlexusSettingsListTile(
                    title: "Fontsize",
                    value: state.userSettings.fontSize,
                    isText: true,
                  ),
                ),
                SliverToBoxAdapter(
                  child: FlexusSettingsListTile(
                    title: "Dark Mode",
                    value: state.userSettings.isDarkMode,
                    isBool: true,
                  ),
                ),
                _buildSection("Status"),
                SliverToBoxAdapter(
                  child: FlexusSettingsListTile(
                    title: "Pull From Everyone",
                    subtitle: "Who do you want to be notified by about the status?",
                    value: state.userSettings.isPullFromEveryone,
                    isBool: true,
                  ),
                ),
                SliverToBoxAdapter(
                  child: Visibility(
                    visible: !state.userSettings.isPullFromEveryone,
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
                    value: state.userSettings.isNotifyEveryone,
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
                      //Alle lokalen Daten löschen aber auf dem Server behalten
                      child: Text(
                        "Log out",
                        style: TextStyle(
                          fontSize: AppSettings.fontSize,
                          color: AppSettings.error,
                        ),
                      ),
                      onPressed: () => null,
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Center(
                    child: TextButton(
                      style: ButtonStyle(backgroundColor: MaterialStateProperty.all(AppSettings.background)),
                      //Alle Daten löschen. Sowohl auf dem Server als auch lokal
                      child: Text(
                        "Delete Account",
                        style: TextStyle(
                          fontSize: AppSettings.fontSize,
                          color: AppSettings.error,
                        ),
                      ),
                      onPressed: () => null,
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

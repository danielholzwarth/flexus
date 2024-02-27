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
    return Scaffold(
      body: BlocConsumer(
        bloc: settingsBloc,
        listener: (context, state) {},
        builder: (context, state) {
          if (state is SettingsLoading) {
            return const Center(child: CircularProgressIndicator());
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
                    label: "Name",
                    value: userAccount.name,
                    isText: true,
                  ),
                ),
                SliverToBoxAdapter(
                  child: FlexusSettingsListTile(
                    label: "Username",
                    value: userAccount.username,
                    isText: true,
                  ),
                ),
                const SliverToBoxAdapter(
                  child: FlexusSettingsListTile(
                    label: "Password",
                    value: "password",
                    isObscure: true,
                  ),
                ),
                _buildSection("Appearance"),
                SliverToBoxAdapter(
                  child: FlexusSettingsListTile(
                    label: "Fontsize",
                    value: state.userSettings.fontSize,
                    isText: true,
                  ),
                ),
                SliverToBoxAdapter(
                  child: FlexusSettingsListTile(
                    label: "Dark Mode",
                    value: state.userSettings.isDarkMode,
                    isBool: true,
                  ),
                ),
                _buildSection("Privacy"),
                SliverToBoxAdapter(
                  child: FlexusSettingsListTile(
                    label: "Pull From Everyone",
                    value: state.userSettings.isPullFromEveryone,
                    isBool: true,
                  ),
                ),
                SliverToBoxAdapter(
                  child: Visibility(
                    visible: !state.userSettings.isPullFromEveryone,
                    child: const FlexusSettingsListTile(
                      label: "Pull User List",
                      value: "not implemented yet",
                      isText: true,
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: FlexusSettingsListTile(
                    label: "Notify Everyone",
                    value: state.userSettings.isNotifyEveryone,
                    isBool: true,
                  ),
                ),
                SliverToBoxAdapter(
                  child: Visibility(
                    visible: !state.userSettings.isNotifyEveryone,
                    child: const FlexusSettingsListTile(
                      label: "Notify User List",
                      value: "not implemented yet",
                      isText: true,
                    ),
                  ),
                ),
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
      backgroundColor: Colors.white,
      elevation: 0,
    );
  }
}

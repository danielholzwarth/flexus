// ignore_for_file: use_build_context_synchronously

import 'package:app/api/user_settings_service.dart';
import 'package:app/widgets/flexus_button.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userBox = Hive.box('userBox');
    final userSettingsService = UserSettingsService.create();

    return Scaffold(
      appBar: AppBar(
        title: const Text('HomePage'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          children: [
            const Text("hello"),
            FlexusButton(
              text: "Get Settings",
              function: () async {
                final response = await userSettingsService.getUserSettings(userBox.get("flexusjwt"));
                if (response.isSuccessful) {
                  /*                  
                  final Map<String, dynamic> jsonMap = jsonDecode(response.bodyString);

                  final userSettings = UserSettings(
                    id: jsonMap['id'],
                    userAccountID: jsonMap['userAccountID'],
                    fontSize: double.parse(jsonMap['fontSize'].toString()),
                    isDarkMode: jsonMap['isDarkMode'],
                    languageID: jsonMap['languageID'],
                    isUnlisted: jsonMap['isUnlisted'],
                    isPullFromEveryone: jsonMap['isPullFromEveryone'],
                    pullUserListID: jsonMap['pullUserListID'],
                    isNotifyEveryone: jsonMap['isNotifyEveryone'],
                    notifyUserListID: jsonMap['notifyUserListID'],
                  );
                  */
                } else {
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Center(
                        child: Text('Settings could not be load!?!'),
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:app/resources/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FlexusSettingsListTile extends StatelessWidget {
  final dynamic value;
  final String label;
  final bool isBool;
  final bool isDate;
  final bool isText;
  final bool isObscure;
  final Function()? onPressed;
  final Function(bool)? onChanged;

  const FlexusSettingsListTile({
    super.key,
    required this.value,
    required this.label,
    this.isBool = false,
    this.isDate = false,
    this.isText = false,
    this.isObscure = false,
    this.onPressed,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: AppSettings.fontSize),
      onTap: onPressed,
      tileColor: AppSettings.background,
      leading: Text(
        label,
        style: TextStyle(fontSize: AppSettings.fontSize),
      ),
      trailing: buildTrailing(),
    );
  }

  Widget buildTrailing() {
    if (isBool) {
      return Switch(
        value: value,
        onChanged: (bool value) {
          print(value);
        },
        activeColor: AppSettings.primary,
        activeTrackColor: AppSettings.primaryShade48,
        inactiveThumbColor: AppSettings.primary,
        inactiveTrackColor: AppSettings.primaryShade48,
        trackOutlineColor: MaterialStateProperty.resolveWith(
          (final Set<MaterialState> states) {
            if (states.contains(MaterialState.selected)) {
              return null;
            }

            return AppSettings.primaryShade48;
          },
        ),
      );
    }

    if (isDate) {
      return Text(
        DateFormat('dd.MM.yyyy').format(value),
        style: TextStyle(fontSize: AppSettings.fontSize),
      );
    }

    if (isObscure) {
      return Text(
        "****************",
        style: TextStyle(fontSize: AppSettings.fontSize),
      );
    }

    if (isText) {
      return Text(
        value.toString(),
        style: TextStyle(fontSize: AppSettings.fontSize),
      );
    }

    return const SizedBox();
  }
}

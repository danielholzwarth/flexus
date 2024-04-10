import 'package:app/resources/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FlexusSettingsListTile extends StatelessWidget {
  final dynamic value;
  final String title;
  final String subtitle;
  final bool isBool;
  final bool isDate;
  final bool isText;
  final bool isObscure;
  final Function()? onPressed;
  final Function(bool)? onChanged;

  const FlexusSettingsListTile({
    super.key,
    required this.value,
    required this.title,
    this.subtitle = "",
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
      title: Text(
        title,
        style: TextStyle(fontSize: AppSettings.fontSize, fontWeight: FontWeight.w500),
      ),
      subtitle: subtitle != ""
          ? Text(subtitle,
              style: TextStyle(
                fontSize: AppSettings.fontSizeT2,
              ))
          : null,
      trailing: buildTrailing(),
    );
  }

  Widget buildTrailing() {
    if (isBool) {
      return Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppSettings.primary,
        activeTrackColor: AppSettings.primaryShade80,
        inactiveThumbColor: AppSettings.primary,
        inactiveTrackColor: AppSettings.background,
        trackOutlineColor: MaterialStateProperty.resolveWith(
          (final Set<MaterialState> states) {
            if (states.contains(MaterialState.selected)) {
              return null;
            }

            return AppSettings.primaryShade80;
          },
        ),
      );
    }

    if (isDate) {
      return Padding(
        padding: const EdgeInsets.only(right: 10),
        child: Text(
          DateFormat('dd.MM.yyyy').format(value),
          style: TextStyle(fontSize: AppSettings.fontSize),
        ),
      );
    }

    if (isObscure) {
      return Padding(
        padding: const EdgeInsets.only(right: 10),
        child: Text(
          "****************",
          style: TextStyle(fontSize: AppSettings.fontSize),
        ),
      );
    }

    if (isText) {
      return Padding(
        padding: const EdgeInsets.only(right: 10),
        child: Text(
          value.toString(),
          style: TextStyle(fontSize: AppSettings.fontSize),
        ),
      );
    }

    return const SizedBox();
  }
}

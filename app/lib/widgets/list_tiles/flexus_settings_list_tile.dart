import 'package:app/resources/app_settings.dart';
import 'package:app/widgets/style/flexus_default_text_style.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FlexusSettingsListTile extends StatefulWidget {
  final dynamic value;
  final String title;
  final String subtitle;
  final bool isBool;
  final bool isDate;
  final bool isText;
  final bool isSlider;
  final bool isObscure;
  final Function()? onPressed;
  final Function(bool)? onChangedSwitch;
  final Function(double)? onChangedSlider;

  const FlexusSettingsListTile({
    super.key,
    required this.value,
    required this.title,
    this.subtitle = "",
    this.isBool = false,
    this.isDate = false,
    this.isText = false,
    this.isSlider = false,
    this.isObscure = false,
    this.onPressed,
    this.onChangedSwitch,
    this.onChangedSlider,
  });

  @override
  State<FlexusSettingsListTile> createState() => _FlexusSettingsListTileState();
}

class _FlexusSettingsListTileState extends State<FlexusSettingsListTile> {
  @override
  Widget build(BuildContext context) {
    Size deviceSize = MediaQuery.of(context).size;

    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: AppSettings.fontSize),
      onTap: widget.onPressed,
      tileColor: AppSettings.background,
      title: CustomDefaultTextStyle(text: widget.title, fontWeight: FontWeight.w500),
      subtitle: widget.subtitle != ""
          ? CustomDefaultTextStyle(
              text: widget.subtitle,
              fontSize: AppSettings.fontSizeT2,
            )
          : null,
      trailing: buildTrailing(deviceSize),
    );
  }

  Widget buildTrailing(Size deviceSize) {
    if (widget.isBool) {
      return Switch(
        value: widget.value,
        onChanged: widget.onChangedSwitch,
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

    if (widget.isDate) {
      return Padding(
        padding: const EdgeInsets.only(right: 10),
        child: CustomDefaultTextStyle(
          text: DateFormat('dd.MM.yyyy').format(widget.value),
        ),
      );
    }

    if (widget.isObscure) {
      return const Padding(
        padding: EdgeInsets.only(right: 10),
        child: CustomDefaultTextStyle(
          text: "****************",
        ),
      );
    }

    if (widget.isText) {
      return Padding(
        padding: const EdgeInsets.only(right: 10),
        child: CustomDefaultTextStyle(
          text: widget.value.toString(),
        ),
      );
    }

    if (widget.isSlider) {
      double sliderVal = widget.value;
      return SizedBox(
        height: deviceSize.width * 0.01,
        width: deviceSize.width * 0.3,
        child: Padding(
          padding: const EdgeInsets.only(right: 0),
          child: Slider(
            activeColor: AppSettings.primary,
            inactiveColor: AppSettings.primaryShade48,
            value: sliderVal,
            divisions: 4,
            min: 13,
            max: 17,
            label: getSliderLabel(sliderVal),
            onChanged: widget.onChangedSlider!,
          ),
        ),
      );
    }

    return const SizedBox();
  }

  String getSliderLabel(double sliderVal) {
    switch (sliderVal) {
      case 13:
        return "XS";
      case 14:
        return "S";
      case 15:
        return "M";
      case 16:
        return "L";
      case 17:
        return "XL";

      default:
        return "99";
    }
  }
}

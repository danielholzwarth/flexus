import 'package:app/bloc/user_account_gym_bloc/user_account_gym_bloc.dart';
import 'package:app/hive/gym/gym.dart';
import 'package:app/resources/app_settings.dart';
import 'package:app/widgets/style/flexus_default_text_style.dart';
import 'package:flutter/material.dart';

class FlexusMyGymSearchListTile extends StatefulWidget {
  final Gym gym;
  final String? query;
  final Function()? onTap;

  const FlexusMyGymSearchListTile({
    super.key,
    required this.gym,
    this.query,
    this.onTap,
  });

  @override
  State<FlexusMyGymSearchListTile> createState() => _FlexusMyGymSearchListTileState();
}

class _FlexusMyGymSearchListTileState extends State<FlexusMyGymSearchListTile> {
  final UserAccountGymBloc userAccountGymBloc = UserAccountGymBloc();

  @override
  void initState() {
    userAccountGymBloc.add(GetUserAccountGym(gymID: widget.gym.id));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: widget.onTap,
      title: highlightText(widget.gym.name, AppSettings.fontSizeH4),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomDefaultTextStyle(
            text: '${widget.gym.streetName} ${widget.gym.houseNumber}',
            color: AppSettings.font.withOpacity(0.5),
          ),
          CustomDefaultTextStyle(
            text: '${widget.gym.zipCode} ${widget.gym.cityName}',
            color: AppSettings.font.withOpacity(0.5),
          ),
        ],
      ),
    );
  }

  Widget highlightText(String text, double fontSize) {
    if (widget.query != null && widget.query != "") {
      if (text.toLowerCase().contains(widget.query!.toLowerCase())) {
        int startIndex = text.toLowerCase().indexOf(widget.query!.toLowerCase());
        int endIndex = startIndex + widget.query!.length;

        return Row(
          children: [
            CustomDefaultTextStyle(
              text: startIndex > 0 ? text.substring(0, startIndex) : "",
              color: AppSettings.font.withOpacity(0.5),
            ),
            CustomDefaultTextStyle(text: text.substring(startIndex, endIndex)),
            CustomDefaultTextStyle(
              text: endIndex < text.length ? text.substring(endIndex) : "",
              color: AppSettings.font.withOpacity(0.5),
            ),
          ],
        );
      }
      return CustomDefaultTextStyle(
        text: text,
        color: AppSettings.font.withOpacity(0.5),
      );
    }
    return CustomDefaultTextStyle(text: text);
  }
}

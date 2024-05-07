import 'package:app/bloc/user_account_gym_bloc/user_account_gym_bloc.dart';
import 'package:app/hive/gym/gym.dart';
import 'package:app/resources/app_settings.dart';
import 'package:app/widgets/style/flexus_default_icon.dart';
import 'package:app/widgets/style/flexus_default_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

class FlexusGymExpansionTile extends StatefulWidget {
  final Gym gym;
  final String? query;

  const FlexusGymExpansionTile({
    super.key,
    required this.gym,
    this.query,
  });

  @override
  State<FlexusGymExpansionTile> createState() => _FlexusGymExpansionTileState();
}

class _FlexusGymExpansionTileState extends State<FlexusGymExpansionTile> {
  final UserAccountGymBloc userAccountGymBloc = UserAccountGymBloc();

  @override
  void initState() {
    super.initState();
    userAccountGymBloc.add(GetUserAccountGym(gymID: widget.gym.id));
  }

  @override
  Widget build(BuildContext context) {
    Size deviceSize = MediaQuery.of(context).size;
    return ExpansionTile(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          highlightText(widget.gym.name, AppSettings.fontSizeH4),
          SizedBox(height: deviceSize.height * 0.01),
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
      children: <Widget>[
        SizedBox(height: deviceSize.height * 0.02),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            BlocBuilder(
              bloc: userAccountGymBloc,
              builder: (context, state) {
                if (state is UserAccountGymCreated || state is UserAccountGymLoaded && state.isExisting) {
                  return ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(AppSettings.background),
                      surfaceTintColor: MaterialStateProperty.all(AppSettings.background),
                      overlayColor: MaterialStateProperty.all(AppSettings.primaryShade48),
                      foregroundColor: MaterialStateProperty.all(AppSettings.primary),
                      fixedSize: MaterialStateProperty.all(Size.fromWidth(deviceSize.width * 0.4)),
                    ),
                    onPressed: () {
                      userAccountGymBloc.add(DeleteUserAccountGym(gymID: widget.gym.id));
                    },
                    child: FlexusDefaultIcon(
                      iconData: Icons.check,
                      iconColor: AppSettings.primary,
                      iconSize: AppSettings.fontSize,
                    ),
                  );
                } else {
                  return ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(AppSettings.background),
                      surfaceTintColor: MaterialStateProperty.all(AppSettings.background),
                      overlayColor: MaterialStateProperty.all(AppSettings.primaryShade48),
                      foregroundColor: MaterialStateProperty.all(AppSettings.primary),
                      fixedSize: MaterialStateProperty.all(Size.fromWidth(deviceSize.width * 0.4)),
                    ),
                    onPressed: () {
                      userAccountGymBloc.add(PostUserAccountGym(gymID: widget.gym.id));
                    },
                    child: const CustomDefaultTextStyle(text: 'Add to Gyms'),
                  );
                }
              },
            ),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(AppSettings.background),
                surfaceTintColor: MaterialStateProperty.all(AppSettings.background),
                overlayColor: MaterialStateProperty.all(AppSettings.primaryShade48),
                foregroundColor: MaterialStateProperty.all(AppSettings.primary),
                fixedSize: MaterialStateProperty.all(Size.fromWidth(deviceSize.width * 0.4)),
              ),
              onPressed: () {
                openMaps(widget.gym.latitude, widget.gym.longitude);
              },
              child: const CustomDefaultTextStyle(text: 'Open in Maps'),
            ),
          ],
        ),
        SizedBox(height: deviceSize.height * 0.01),
      ],
    );
  }

  Future<void> openMaps(double latitude, double longitude) async {
    Uri uri = Uri.parse('https://www.google.com/maps?q=$latitude,$longitude');
    await launchUrl(uri);
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

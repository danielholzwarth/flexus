import 'package:app/bloc/user_account_gym_bloc/user_account_gym_bloc.dart';
import 'package:app/hive/gym/gym.dart';
import 'package:app/resources/app_settings.dart';
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
    userAccountGymBloc.add(GetUserAccountGym(gymID: widget.gym.id));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          highlightText(widget.gym.name, AppSettings.fontSizeH4),
          SizedBox(height: AppSettings.screenHeight * 0.01),
          Text(
            '${widget.gym.streetName} ${widget.gym.houseNumber}',
            style: TextStyle(fontSize: AppSettings.fontSize, color: AppSettings.font.withOpacity(0.5)),
          ),
          Text(
            '${widget.gym.zipCode} ${widget.gym.cityName}',
            style: TextStyle(fontSize: AppSettings.fontSize, color: AppSettings.font.withOpacity(0.5)),
          ),
        ],
      ),
      children: <Widget>[
        SizedBox(height: AppSettings.screenHeight * 0.02),
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
                      fixedSize: MaterialStateProperty.all(Size.fromWidth(AppSettings.screenWidth * 0.4)),
                    ),
                    onPressed: () {
                      userAccountGymBloc.add(DeleteUserAccountGym(gymID: widget.gym.id));
                    },
                    child: Icon(Icons.check, color: AppSettings.primary, size: AppSettings.fontSize),
                  );
                } else {
                  return ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(AppSettings.background),
                      surfaceTintColor: MaterialStateProperty.all(AppSettings.background),
                      overlayColor: MaterialStateProperty.all(AppSettings.primaryShade48),
                      foregroundColor: MaterialStateProperty.all(AppSettings.primary),
                      fixedSize: MaterialStateProperty.all(Size.fromWidth(AppSettings.screenWidth * 0.4)),
                    ),
                    onPressed: () {
                      userAccountGymBloc.add(PostUserAccountGym(gymID: widget.gym.id));
                    },
                    child: const Text('Add to Gyms'),
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
                fixedSize: MaterialStateProperty.all(Size.fromWidth(AppSettings.screenWidth * 0.4)),
              ),
              onPressed: () {
                openMaps(widget.gym.latitude, widget.gym.longitude);
              },
              child: const Text('Open in Maps'),
            ),
          ],
        ),
        SizedBox(height: AppSettings.screenHeight * 0.01),
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

        return RichText(
          text: TextSpan(
            text: startIndex > 0 ? text.substring(0, startIndex) : "",
            style: TextStyle(
              fontSize: fontSize,
              color: Colors.grey,
            ),
            children: [
              TextSpan(
                text: text.substring(startIndex, endIndex),
                style: TextStyle(
                  fontSize: fontSize,
                  color: AppSettings.font,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                text: endIndex < text.length ? text.substring(endIndex) : "",
                style: TextStyle(
                  fontSize: fontSize,
                  color: Colors.grey,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
        );
      }
      return RichText(
        text: TextSpan(
          text: text,
          style: TextStyle(
            fontSize: fontSize,
            color: Colors.grey,
          ),
        ),
      );
    }
    return RichText(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: fontSize,
          color: AppSettings.font,
        ),
      ),
    );
  }
}

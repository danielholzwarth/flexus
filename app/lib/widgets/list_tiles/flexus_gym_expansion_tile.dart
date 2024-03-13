import 'package:app/bloc/user_account_gym_bloc/user_account_gym_bloc.dart';
import 'package:app/hive/gym.dart';
import 'package:app/resources/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

class FlexusGymExpansionTile extends StatefulWidget {
  final Gym gym;

  const FlexusGymExpansionTile({
    super.key,
    required this.gym,
  });

  @override
  State<FlexusGymExpansionTile> createState() => _FlexusGymExpansionTileState();
}

class _FlexusGymExpansionTileState extends State<FlexusGymExpansionTile> {
  @override
  Widget build(BuildContext context) {
    final UserAccountGymBloc userAccountGymBloc = UserAccountGymBloc();

    return ExpansionTile(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.gym.name,
              style: TextStyle(
                fontSize: AppSettings.fontSizeTitleSmall,
                fontWeight: FontWeight.bold,
                color: AppSettings.font,
              )),
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
                if (state is UserAccountGymCreating || state is UserAccountGymDeleting) {
                  return ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(AppSettings.background),
                      surfaceTintColor: MaterialStateProperty.all(AppSettings.background),
                      overlayColor: MaterialStateProperty.all(AppSettings.primaryShade48),
                      foregroundColor: MaterialStateProperty.all(AppSettings.primary),
                      fixedSize: MaterialStateProperty.all(Size.fromWidth(AppSettings.screenWidth * 0.4)),
                    ),
                    onPressed: null,
                    child: Center(child: CircularProgressIndicator(color: AppSettings.primary)),
                  );
                } else if (state is UserAccountGymCreated) {
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
}

import 'package:app/bloc/gym_bloc/gym_bloc.dart';
import 'package:app/resources/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

class FlexusGymExpansionTile extends StatefulWidget {
  final Map<String, dynamic> locationData;

  const FlexusGymExpansionTile({
    super.key,
    required this.locationData,
  });

  @override
  State<FlexusGymExpansionTile> createState() => _FlexusGymExpansionTileState();
}

class _FlexusGymExpansionTileState extends State<FlexusGymExpansionTile> {
  @override
  Widget build(BuildContext context) {
    final GymBloc gymBloc = GymBloc();

    return ExpansionTile(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.locationData['name'],
              style: TextStyle(
                fontSize: AppSettings.fontSizeTitleSmall,
                fontWeight: FontWeight.bold,
                color: AppSettings.font,
              )),
          SizedBox(height: AppSettings.screenHeight * 0.01),
          Text(
            '${widget.locationData['display_name']}',
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
              bloc: gymBloc,
              builder: (context, state) {
                if (state is GymCreating) {
                  return ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(AppSettings.background),
                      surfaceTintColor: MaterialStateProperty.all(AppSettings.background),
                      overlayColor: MaterialStateProperty.all(AppSettings.primaryShade48),
                      foregroundColor: MaterialStateProperty.all(AppSettings.primary),
                    ),
                    onPressed: null,
                    child: Center(child: CircularProgressIndicator(color: AppSettings.primary)),
                  );
                } else if (state is GymCreated) {
                  return ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(AppSettings.background),
                      surfaceTintColor: MaterialStateProperty.all(AppSettings.background),
                      overlayColor: MaterialStateProperty.all(AppSettings.primaryShade48),
                      foregroundColor: MaterialStateProperty.all(AppSettings.primary),
                    ),
                    onPressed: () {
                      gymBloc.add(DeleteGym(gymID: state.gym.id));
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
                    ),
                    onPressed: () {
                      gymBloc.add(PostGym(locationData: widget.locationData));
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
              ),
              onPressed: () {
                openMaps(double.parse(widget.locationData['lat']), double.parse(widget.locationData['lon']));
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

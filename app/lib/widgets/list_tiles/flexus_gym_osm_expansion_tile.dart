import 'package:app/bloc/gym_bloc/gym_bloc.dart';
import 'package:app/resources/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

class FlexusGymOSMExpansionTile extends StatefulWidget {
  final Map<String, dynamic> locationData;

  const FlexusGymOSMExpansionTile({
    super.key,
    required this.locationData,
  });

  @override
  State<FlexusGymOSMExpansionTile> createState() => _FlexusGymOSMExpansionTileState();
}

class _FlexusGymOSMExpansionTileState extends State<FlexusGymOSMExpansionTile> {
  @override
  Widget build(BuildContext context) {
    final GymBloc gymBloc = GymBloc();

    final String name = widget.locationData['name'] ?? "";
    final String streetName = widget.locationData['address']['road'] ?? "";
    final String houseNumber = widget.locationData['address']['house_number'] ?? "";
    final String zipCode = widget.locationData['address']['postcode'] ?? "";
    final String cityName =
        widget.locationData['address']['city'] ?? widget.locationData['address']['town'] ?? widget.locationData['address']['village'] ?? "";
    final double latitude = double.parse(widget.locationData['lat']);
    final double longitude = double.parse(widget.locationData['lon']);

    return ExpansionTile(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: TextStyle(
              fontSize: AppSettings.fontSizeTitleSmall,
              fontWeight: FontWeight.bold,
              color: AppSettings.font,
            ),
          ),
          SizedBox(height: AppSettings.screenHeight * 0.01),
          Text(
            '$streetName $houseNumber',
            style: TextStyle(fontSize: AppSettings.fontSize, color: AppSettings.font.withOpacity(0.5)),
          ),
          Text(
            '$zipCode $cityName',
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
                      fixedSize: MaterialStateProperty.all(Size.fromWidth(AppSettings.screenWidth * 0.4)),
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
                      fixedSize: MaterialStateProperty.all(Size.fromWidth(AppSettings.screenWidth * 0.4)),
                    ),
                    onPressed: () {},
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
                fixedSize: MaterialStateProperty.all(Size.fromWidth(AppSettings.screenWidth * 0.4)),
              ),
              onPressed: () {
                openMaps(latitude, longitude);
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

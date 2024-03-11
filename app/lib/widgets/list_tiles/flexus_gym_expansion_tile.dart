import 'package:app/resources/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class FlexusGymExpansionTile extends StatelessWidget {
  final Map<String, dynamic> locationData; // Data for the gym location

  const FlexusGymExpansionTile({
    super.key,
    required this.locationData,
  });

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(locationData['name'],
              style: TextStyle(
                fontSize: AppSettings.fontSizeTitleSmall,
                fontWeight: FontWeight.bold,
                color: AppSettings.font,
              )),
          SizedBox(height: AppSettings.screenHeight * 0.01),
          Text(
            '${locationData['display_name']}',
            style: TextStyle(fontSize: AppSettings.fontSize, color: AppSettings.font.withOpacity(0.5)),
          ),
        ],
      ),
      children: <Widget>[
        SizedBox(height: AppSettings.screenHeight * 0.02),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(AppSettings.background),
                surfaceTintColor: MaterialStateProperty.all(AppSettings.background),
                overlayColor: MaterialStateProperty.all(AppSettings.primaryShade48),
                foregroundColor: MaterialStateProperty.all(AppSettings.primary),
              ),
              onPressed: () {
                //Add to my gyms
              },
              child: const Text('Add to Gyms'),
            ),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(AppSettings.background),
                surfaceTintColor: MaterialStateProperty.all(AppSettings.background),
                overlayColor: MaterialStateProperty.all(AppSettings.primaryShade48),
                foregroundColor: MaterialStateProperty.all(AppSettings.primary),
              ),
              onPressed: () {
                debugPrint(locationData['lat'] + "  " + locationData['lon']);
                openMaps(double.parse(locationData['lat']), double.parse(locationData['lon']));
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

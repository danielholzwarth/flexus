import 'package:app/resources/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ProfilePicturePage extends StatelessWidget {
  final bool isOwnProfile;

  const ProfilePicturePage({
    super.key,
    required this.isOwnProfile,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          Visibility(
            visible: isOwnProfile,
            child: PopupMenuButton<String>(
              icon: Icon(
                Icons.menu,
                color: AppSettings.font,
                size: AppSettings.fontSizeTitle,
              ),
              itemBuilder: (BuildContext context) {
                return ['Take new picture', 'Choose new picture', 'Delete picture'].map((String choice) {
                  IconData icon;
                  switch (choice) {
                    case 'Take new picture':
                      icon = Icons.camera_alt;
                      break;
                    case 'Choose new picture':
                      icon = Icons.photo_library;
                      break;
                    case 'Delete picture':
                      icon = Icons.delete;
                      break;
                    default:
                      icon = Icons.error;
                  }
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(choice),
                        Icon(icon),
                      ],
                    ),
                  );
                }).toList();
              },
              onSelected: (String choice) {
                switch (choice) {
                  case "Take new picture":
                  case "Choose new picture":
                  case "Delete picture":
                  default:
                    print("not implemented yet");
                }
              },
            ),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: Center(
          child: Hero(
            tag: 'profile_picture',
            child: Image.network(
              'https://www.anthropics.com/portraitpro/img/page-images/homepage/v22/what-can-it-do-2A.jpg',
            ),
          ),
        ),
      ),
    );
  }
}

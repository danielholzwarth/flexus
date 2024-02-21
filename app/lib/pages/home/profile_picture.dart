import 'dart:convert';

import 'package:app/hive/user_account.dart';
import 'package:app/resources/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePicturePage extends StatefulWidget {
  final bool isOwnProfile;

  const ProfilePicturePage({
    super.key,
    required this.isOwnProfile,
  });

  @override
  State<ProfilePicturePage> createState() => _ProfilePicturePageState();
}

class _ProfilePicturePageState extends State<ProfilePicturePage> {
  final userBox = Hive.box('userBox');
  final ImagePicker imagePicker = ImagePicker();
  XFile? imageFile;

  @override
  Widget build(BuildContext context) {
    final UserAccount userAccount = userBox.get("userAccount");
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          Visibility(
            visible: widget.isOwnProfile,
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
                    //Upload to Backend
                    getImage();
                    setState(() {});
                    break;

                  case "Delete picture":
                    //Upload to Backend
                    UserAccount userAccount = userBox.get("userAccount");
                    userAccount.profilePicture = null;
                    userBox.put("userAccount", userAccount);
                    setState(() {});
                    break;

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
            child: userAccount.profilePicture != null
                ? Image.memory(base64.decode(userAccount.profilePicture!))
                : Icon(
                    Icons.hide_image_outlined,
                    size: screenWidth * 0.7,
                  ),
          ),
        ),
      ),
    );
  }

  Future<void> getImage() async {
    try {
      final XFile? pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          imageFile = pickedFile;
        });

        List<int> imageBytes = await pickedFile.readAsBytes();
        String base64Image = base64Encode(imageBytes);

        UserAccount userAccount = userBox.get("userAccount");
        userAccount.profilePicture = base64Image;

        userBox.put("userAccount", userAccount);
      }
    } catch (e) {
      print("Error picking image from gallery: $e");
    }
  }
}

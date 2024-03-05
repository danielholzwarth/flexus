import 'dart:typed_data';

import 'package:app/bloc/user_account_bloc/user_account_bloc.dart';
import 'package:app/hive/user_account.dart';
import 'package:app/resources/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePicturePage extends StatefulWidget {
  final int userID;
  final Uint8List? profilePicture;

  const ProfilePicturePage({
    super.key,
    required this.userID,
    required this.profilePicture,
  });

  @override
  State<ProfilePicturePage> createState() => _ProfilePicturePageState();
}

class _ProfilePicturePageState extends State<ProfilePicturePage> {
  final userBox = Hive.box('userBox');
  final ImagePicker imagePicker = ImagePicker();
  XFile? imageFile;
  final UserAccountBloc userAccountBloc = UserAccountBloc();

  @override
  Widget build(BuildContext context) {
    final UserAccount userAccount = userBox.get("userAccount");

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          Visibility(
            visible: widget.userID == userAccount.id,
            child: PopupMenuButton<String>(
              color: AppSettings.background,
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
                    takeImage();
                    break;
                  case "Choose new picture":
                    getImageFromGallery();
                    break;
                  case "Delete picture":
                    deleteImage();
                    break;
                  default:
                    debugPrint("not implemented yet");
                }
              },
            ),
          ),
        ],
      ),
      body: BlocBuilder(
        bloc: userAccountBloc,
        builder: (context, state) {
          if (state is UserAccountUpdating) {
            return Center(child: CircularProgressIndicator(color: AppSettings.primary));
          } else if (state is UserAccountLoaded) {
            return GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Center(
                child: Hero(
                  tag: 'profile_picture',
                  child: state.userAccount.profilePicture != null
                      ? Image.memory(state.userAccount.profilePicture!)
                      : Icon(
                          Icons.hide_image_outlined,
                          size: AppSettings.screenWidth * 0.7,
                        ),
                ),
              ),
            );
          } else {
            return GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Center(
                child: Hero(
                  tag: 'profile_picture',
                  child: widget.profilePicture != null
                      ? Image.memory(widget.profilePicture!)
                      : Icon(
                          Icons.hide_image_outlined,
                          size: AppSettings.screenWidth * 0.7,
                        ),
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Future<void> getImageFromGallery() async {
    try {
      final XFile? pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        imageFile = pickedFile;

        List<int> imageBytes = await pickedFile.readAsBytes();
        Uint8List uint8List = Uint8List.fromList(imageBytes);

        userAccountBloc.add(PatchUserAccount(name: "profilePicture", value: uint8List));
      }
    } catch (e) {
      debugPrint("Error picking image from gallery: $e");
    }
  }

  void deleteImage() {
    userAccountBloc.add(PatchUserAccount(name: "profilePicture", value: null));
  }

  Future<void> takeImage() async {
    try {
      final XFile? pickedFile = await imagePicker.pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        List<int> imageBytes = await pickedFile.readAsBytes();
        Uint8List uint8List = Uint8List.fromList(imageBytes);

        userAccountBloc.add(PatchUserAccount(name: "profilePicture", value: uint8List));
      }
    } catch (e) {
      debugPrint("Error taking image: $e");
    }
  }
}

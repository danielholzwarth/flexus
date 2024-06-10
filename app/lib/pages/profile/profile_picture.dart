import 'dart:typed_data';

import 'package:app/bloc/user_account_bloc/user_account_bloc.dart';
import 'package:app/hive/user_account/user_account.dart';
import 'package:app/resources/app_settings.dart';
import 'package:app/widgets/style/flexus_default_icon.dart';
import 'package:app/widgets/style/flexus_default_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
  final int maxImageSize = 3 * 1024 * 1024; //3 MB

  @override
  Widget build(BuildContext context) {
    Size deviceSize = MediaQuery.of(context).size;
    final UserAccount userAccount = userBox.get("userAccount");

    return Scaffold(
      backgroundColor: AppSettings.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          buildMenu(userAccount),
        ],
      ),
      body: buildPicture(deviceSize),
    );
  }

  Widget buildPicture(Size deviceSize) {
    return BlocConsumer(
      bloc: userAccountBloc,
      listener: (context, state) {
        if (state is UserAccountError) {
          Fluttertoast.cancel();
          Fluttertoast.showToast(
            msg: state.error,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            backgroundColor: AppSettings.error,
            textColor: AppSettings.fontV1,
            fontSize: AppSettings.fontSize,
          );
        }
      },
      builder: (context, state) {
        if (state is UserAccountLoaded) {
          return GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Center(
              child: Hero(
                tag: 'profile_picture',
                child: state.userAccount.profilePicture != null
                    ? Image.memory(state.userAccount.profilePicture!)
                    : FlexusDefaultIcon(
                        iconData: Icons.hide_image_outlined,
                        iconSize: deviceSize.width * 0.7,
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
                    : FlexusDefaultIcon(
                        iconData: Icons.hide_image_outlined,
                        iconSize: deviceSize.width * 0.7,
                      ),
              ),
            ),
          );
        }
      },
    );
  }

  Visibility buildMenu(UserAccount userAccount) {
    return Visibility(
      visible: widget.userID == userAccount.id,
      child: PopupMenuButton<String>(
        color: AppSettings.background,
        icon: const FlexusDefaultIcon(iconData: Icons.menu),
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
                  CustomDefaultTextStyle(text: choice),
                  FlexusDefaultIcon(iconData: icon),
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
    );
  }

  Future<void> getImageFromGallery() async {
    try {
      final XFile? pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        imageFile = pickedFile;

        List<int> imageBytes = await pickedFile.readAsBytes();

        if (imageBytes.length <= maxImageSize) {
          Uint8List uint8List = Uint8List.fromList(imageBytes);
          userAccountBloc.add(PatchUserAccount(name: "profilePicture", value: uint8List));
        } else {
          Fluttertoast.cancel();
          Fluttertoast.showToast(
            msg: "Filesize is to big. Max. 3MB allowed!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            backgroundColor: AppSettings.error,
            textColor: AppSettings.fontV1,
            fontSize: AppSettings.fontSize,
          );
          setState(() {});
        }
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
        if (imageBytes.length <= maxImageSize) {
          Uint8List uint8List = Uint8List.fromList(imageBytes);
          userAccountBloc.add(PatchUserAccount(name: "profilePicture", value: uint8List));
          setState(() {});
        } else {
          Fluttertoast.cancel();
          Fluttertoast.showToast(
            msg: "Filesize is to big. Max 3MB allowed!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            backgroundColor: AppSettings.error,
            textColor: AppSettings.fontV1,
            fontSize: AppSettings.fontSize,
          );
        }
      }
    } catch (e) {
      debugPrint("Error taking image: $e");
    }
  }
}

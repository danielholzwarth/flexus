import 'package:app/hive/user_account/user_account.dart';
import 'package:app/pages/friends/scan_qr.dart';
import 'package:app/resources/app_settings.dart';
import 'package:app/widgets/style/flexus_default_text_style.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:page_transition/page_transition.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ShowQRPage extends StatelessWidget {
  const ShowQRPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userBox = Hive.box('userBox');
    final UserAccount userAccount = userBox.get("userAccount");

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: CustomDefaultTextStyle(
          text: 'QR Code',
          fontSize: AppSettings.fontSizeH3,
        ),
        backgroundColor: AppSettings.background,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                PageTransition(
                  type: PageTransitionType.fade,
                  child: const ScanQRPage(),
                ),
              );
            },
            icon: const Icon(Icons.camera),
          )
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: AppSettings.background,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black,
                    width: 15.0,
                  ),
                ),
                child: QrImageView(
                  data: userAccount.id.toString(),
                  version: QrVersions.auto,
                ),
              ),
              const SizedBox(height: 16),
              CustomDefaultTextStyle(
                text: userAccount.name,
                fontSize: AppSettings.fontSizeH3,
              ),
              CustomDefaultTextStyle(
                text: "@${userAccount.username}",
              )
            ],
          ),
        ),
      ),
    );
  }
}

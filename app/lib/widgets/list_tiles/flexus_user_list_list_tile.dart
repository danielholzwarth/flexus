import 'package:app/bloc/user_list_bloc/user_list_bloc.dart';
import 'package:app/hive/user_account/user_account.dart';
import 'package:app/pages/profile/profile.dart';
import 'package:app/resources/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:page_transition/page_transition.dart';

class FlexusUserListListTile extends StatefulWidget {
  final UserAccount userAccount;
  final String? query;
  final int listID;

  const FlexusUserListListTile({
    super.key,
    required this.userAccount,
    this.query,
    required this.listID,
  });

  @override
  State<FlexusUserListListTile> createState() => _FlexusUserListListTileState();
}

class _FlexusUserListListTileState extends State<FlexusUserListListTile> {
  final UserListBloc userListBloc = UserListBloc();

  @override
  void initState() {
    userListBloc.add(GetHasUserList(listID: widget.listID, userID: widget.userAccount.id));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: AppSettings.fontSize),
      tileColor: AppSettings.background,
      leading: buildPicture(context),
      title: highlightText(widget.userAccount.name),
      trailing: buildTrailing(context),
      subtitle: highlightText("@${widget.userAccount.username}"),
    );
  }

  Widget buildTrailing(BuildContext context) {
    return BlocBuilder(
      bloc: userListBloc,
      builder: (context, state) {
        if (state is HasUserListLoaded && state.isCreated || state is UserListUpdated && state.isCreated) {
          return IconButton(
            style: ButtonStyle(
              overlayColor: MaterialStateProperty.all(AppSettings.primaryShade48),
              shape: MaterialStateProperty.all(
                RoundedRectangleBorder(
                  side: BorderSide(
                    color: AppSettings.error.withOpacity(0.1),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            onPressed: () => {
              userListBloc.add(PatchUserList(isDeleting: true, listID: widget.listID, userID: widget.userAccount.id)),
            },
            icon: Icon(
              Icons.remove,
              color: AppSettings.error,
              size: AppSettings.fontSizeH4,
            ),
          );
        } else if (state is HasUserListLoaded || state is UserListUpdated) {
          return IconButton(
            style: ButtonStyle(
              overlayColor: MaterialStateProperty.all(AppSettings.primaryShade48),
              shape: MaterialStateProperty.all(
                RoundedRectangleBorder(
                  side: BorderSide(
                    color: AppSettings.primaryShade48,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            onPressed: () => {
              userListBloc.add(PatchUserList(isDeleting: false, listID: widget.listID, userID: widget.userAccount.id)),
            },
            icon: Icon(
              Icons.add,
              color: AppSettings.primary,
              size: AppSettings.fontSizeH4,
            ),
          );
        } else {
          return CircularProgressIndicator(color: AppSettings.primary);
        }
      },
    );
  }

  Widget buildPicture(BuildContext context) {
    return widget.userAccount.profilePicture != null
        ? GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                PageTransition(
                  type: PageTransitionType.fade,
                  child: ProfilePage(userID: widget.userAccount.id),
                ),
              );
            },
            child: CircleAvatar(
              radius: AppSettings.fontSizeH3,
              backgroundColor: AppSettings.primaryShade48,
              backgroundImage: MemoryImage(widget.userAccount.profilePicture!),
            ))
        : IconButton(
            icon: Icon(
              Icons.person,
              size: AppSettings.fontSizeH3,
            ),
            onPressed: () {
              Navigator.push(
                context,
                PageTransition(
                  type: PageTransitionType.fade,
                  child: ProfilePage(userID: widget.userAccount.id),
                ),
              );
            },
          );
  }

  Widget highlightText(String text) {
    if (widget.query != null && widget.query != "") {
      if (text.toLowerCase().contains(widget.query!.toLowerCase())) {
        int startIndex = text.toLowerCase().indexOf(widget.query!.toLowerCase());
        int endIndex = startIndex + widget.query!.length;

        return RichText(
          text: TextSpan(
            text: startIndex > 0 ? text.substring(0, startIndex) : "",
            style: TextStyle(
              fontSize: AppSettings.fontSize,
              color: Colors.grey,
            ),
            children: [
              TextSpan(
                text: text.substring(startIndex, endIndex),
                style: TextStyle(
                  fontSize: AppSettings.fontSize,
                  color: AppSettings.font,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                text: endIndex < text.length ? text.substring(endIndex) : "",
                style: TextStyle(
                  fontSize: AppSettings.fontSize,
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
            fontSize: AppSettings.fontSize,
            color: Colors.grey,
          ),
        ),
      );
    }
    return RichText(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: AppSettings.fontSize,
          color: AppSettings.font,
        ),
      ),
    );
  }
}

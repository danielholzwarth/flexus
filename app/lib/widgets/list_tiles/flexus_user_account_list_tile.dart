import 'package:app/bloc/friendship_bloc/friendship_bloc.dart';
import 'package:app/hive/user_account/user_account.dart';
import 'package:app/pages/profile/profile.dart';
import 'package:app/resources/app_settings.dart';
import 'package:app/widgets/style/flexus_default_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:page_transition/page_transition.dart';

class FlexusUserAccountListTile extends StatefulWidget {
  final UserAccount userAccount;
  final String? query;

  const FlexusUserAccountListTile({
    super.key,
    required this.userAccount,
    this.query,
  });

  @override
  State<FlexusUserAccountListTile> createState() => _FlexusUserAccountListTileState();
}

class _FlexusUserAccountListTileState extends State<FlexusUserAccountListTile> {
  final FriendshipBloc friendshipBloc = FriendshipBloc();

  @override
  void initState() {
    friendshipBloc.add(GetFriendship(requestedID: widget.userAccount.id));
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
      bloc: friendshipBloc,
      builder: (context, state) {
        if (state is FriendshipLoaded) {
          if (state.friendship != null) {
            if (state.friendship!.isAccepted) {
              return TextButton(
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
                  friendshipBloc.add(DeleteFriendship(requestedID: widget.userAccount.id)),
                },
                child: CustomDefaultTextStyle(text: "Remove", color: AppSettings.error),
              );
            } else {
              if (state.friendship!.requestedID == widget.userAccount.id) {
                return TextButton(
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
                    friendshipBloc.add(DeleteFriendship(requestedID: widget.userAccount.id)),
                  },
                  child: CustomDefaultTextStyle(text: "Request sent", color: AppSettings.primary),
                );
              } else {
                return TextButton(
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
                    friendshipBloc.add(PatchFriendship(requestedID: widget.userAccount.id, name: "isAccepted", value: true)),
                  },
                  child: CustomDefaultTextStyle(text: "Accept Request", color: AppSettings.primary),
                );
              }
            }
          } else {
            return TextButton(
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
              onPressed: () {
                friendshipBloc.add(PostFriendship(requestedID: widget.userAccount.id));
              },
              child: CustomDefaultTextStyle(text: "Add", color: AppSettings.primary),
            );
          }
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

        return Row(
          children: [
            CustomDefaultTextStyle(
              text: startIndex > 0 ? text.substring(0, startIndex) : "",
              color: AppSettings.font.withOpacity(0.5),
            ),
            CustomDefaultTextStyle(text: text.substring(startIndex, endIndex)),
            CustomDefaultTextStyle(
              text: endIndex < text.length ? text.substring(endIndex) : "",
              color: AppSettings.font.withOpacity(0.5),
            ),
          ],
        );
      }
      return CustomDefaultTextStyle(
        text: text,
        color: AppSettings.font.withOpacity(0.5),
      );
    }
    return CustomDefaultTextStyle(text: text);
  }
}

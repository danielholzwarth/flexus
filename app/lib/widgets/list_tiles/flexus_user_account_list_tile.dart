import 'package:app/bloc/friendship_bloc/friendship_bloc.dart';
import 'package:app/hive/user_account.dart';
import 'package:app/pages/home/profile.dart';
import 'package:app/resources/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:page_transition/page_transition.dart';

class FlexusUserAccountListTile extends StatefulWidget {
  final UserAccount userAccount;

  const FlexusUserAccountListTile({
    super.key,
    required this.userAccount,
  });

  @override
  State<FlexusUserAccountListTile> createState() => _FlexusUserAccountListTileState();
}

class _FlexusUserAccountListTileState extends State<FlexusUserAccountListTile> {
  final FriendshipBloc friendshipBloc = FriendshipBloc();

  @override
  void initState() {
    friendshipBloc.add(LoadFriendship(requestedID: widget.userAccount.id));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: AppSettings.fontSize),
      tileColor: AppSettings.background,
      leading: buildPicture(context),
      title: Text("@${widget.userAccount.name}"),
      trailing: buildTrailing(context),
      subtitle: Text("@${widget.userAccount.username}"),
    );
  }

  Widget buildTrailing(BuildContext context) {
    return BlocBuilder(
      bloc: friendshipBloc,
      builder: (context, state) {
        if (state is FriendshipCreating || state is FriendshipLoading || state is FriendshipUpdating || state is FriendshipDeleting) {
          return CircularProgressIndicator(color: AppSettings.primary);
        } else if (state is FriendshipLoaded) {
          if (state.friendship != null) {
            if (state.friendship!.isAccepted) {
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
                child: Text(
                  "Remove",
                  style: TextStyle(color: AppSettings.error),
                ),
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
                  child: Text(
                    "Request sent",
                    style: TextStyle(color: AppSettings.primary),
                  ),
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
                  child: Text(
                    "Accept Request",
                    style: TextStyle(color: AppSettings.primary),
                  ),
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
                friendshipBloc.add(CreateFriendship(requestedID: widget.userAccount.id));
              },
              child: Text(
                "Add",
                style: TextStyle(color: AppSettings.primary),
              ),
            );
          }
        } else {
          return Text(
            'Error XYZ',
            style: TextStyle(fontSize: AppSettings.fontSize),
          );
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
              radius: AppSettings.fontSizeTitle,
              backgroundColor: AppSettings.primaryShade48,
              backgroundImage: MemoryImage(widget.userAccount.profilePicture!),
            ))
        : IconButton(
            icon: Icon(
              Icons.person,
              size: AppSettings.fontSizeTitle,
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
}

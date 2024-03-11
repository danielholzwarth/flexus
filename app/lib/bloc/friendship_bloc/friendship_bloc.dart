import 'dart:convert';

import 'package:app/api/friendship_service.dart';
import 'package:app/hive/friendship.dart';
import 'package:app/hive/user_account.dart';
import 'package:chopper/chopper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'friendship_event.dart';
part 'friendship_state.dart';

class FriendshipBloc extends Bloc<FriendshipEvent, FriendshipState> {
  final FriendshipService _friendshipService = FriendshipService.create();
  final userBox = Hive.box('userBox');

  FriendshipBloc() : super(FriendshipInitial()) {
    on<PostFriendship>(_onPostFriendship);
    on<GetFriendship>(_onGetFriendship);
    on<PatchFriendship>(_onPatchFriendship);
    on<DeleteFriendship>(_onDeleteFriendship);
  }

  void _onPostFriendship(PostFriendship event, Emitter<FriendshipState> emit) async {
    emit(FriendshipCreating());

    Response<dynamic> response;
    response = await _friendshipService.postFriendship(userBox.get("flexusjwt"), event.requestedID);

    if (response.isSuccessful) {
      UserAccount userAccount = userBox.get("userAccount");

      final friendship = Friendship(
        requestorID: userAccount.id,
        requestedID: event.requestedID,
        isAccepted: false,
      );

      emit(FriendshipLoaded(friendship: friendship));
    } else {
      emit(FriendshipError());
    }
  }

  void _onGetFriendship(GetFriendship event, Emitter<FriendshipState> emit) async {
    emit(FriendshipLoading());

    Response<dynamic> response;
    response = await _friendshipService.getFriendship(userBox.get("flexusjwt"), event.requestedID);

    if (response.isSuccessful) {
      if (response.bodyString != "null") {
        final Map<String, dynamic> jsonMap = jsonDecode(response.bodyString);

        final friendship = Friendship(
          requestorID: jsonMap['requestorID'],
          requestedID: jsonMap['requestedID'],
          isAccepted: jsonMap['isAccepted'],
        );

        emit(FriendshipLoaded(friendship: friendship));
      } else {
        emit(FriendshipLoaded(friendship: null));
      }
    } else {
      emit(FriendshipError());
    }
  }

  void _onPatchFriendship(PatchFriendship event, Emitter<FriendshipState> emit) async {
    emit(FriendshipPatching());

    switch (event.name) {
      case "isAccepted":
        final response = await _friendshipService.patchFriendship(userBox.get("flexusjwt"), event.requestedID, {"isAccepted": event.value});
        if (response.isSuccessful) {
          UserAccount userAccount = userBox.get("userAccount");

          final friendship = Friendship(
            requestorID: userAccount.id,
            requestedID: event.requestedID,
            isAccepted: event.value,
          );
          emit(FriendshipLoaded(friendship: friendship));
        } else {
          emit(FriendshipLoaded(friendship: null));
        }
        break;

      default:
        emit(FriendshipLoaded(friendship: null));
        break;
    }
  }

  void _onDeleteFriendship(DeleteFriendship event, Emitter<FriendshipState> emit) async {
    emit(FriendshipDeleting());

    final response = await _friendshipService.deleteFriendship(userBox.get("flexusjwt"), event.requestedID);

    if (response.isSuccessful) {
      emit(FriendshipLoaded(friendship: null));
    } else {
      emit(FriendshipError());
    }
  }
}

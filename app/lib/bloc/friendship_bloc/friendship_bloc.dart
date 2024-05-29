import 'package:app/api/friendship/friendship_service.dart';
import 'package:app/hive/friendship/friendship.dart';
import 'package:app/hive/user_account/user_account.dart';
import 'package:app/resources/app_settings.dart';
import 'package:app/resources/jwt_helper.dart';
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
    String? jwt = JWTHelper.getActiveJWT();
    if (jwt == null) {
      emit(FriendshipError(error: "Token is invalid. You need to log in again!"));
    }

    final flexusjwt = JWTHelper.getActiveJWT();
    if (flexusjwt == null) {
      //NO-VALID-JWT-ERROR
      return;
    }

    final response = await _friendshipService.postFriendship(flexusjwt, event.requestedID);

    if (!response.isSuccessful) {
      emit(FriendshipError(error: response.error.toString()));
      return;
    }

    JWTHelper.saveJWTsFromResponse(response);

    UserAccount userAccount = userBox.get("userAccount");
    final friendship = Friendship(requestorID: userAccount.id, requestedID: event.requestedID, isAccepted: false);
    emit(FriendshipLoaded(friendship: friendship));
  }

  void _onGetFriendship(GetFriendship event, Emitter<FriendshipState> emit) async {
    emit(FriendshipLoading());
    Friendship? friendship;

    if (!AppSettings.hasConnection) {
      emit(FriendshipLoaded(friendship: friendship));
      return;
    }

    final flexusjwt = JWTHelper.getActiveJWT();
    if (flexusjwt == null) {
      //NO-VALID-JWT-ERROR
      return;
    }

    final response = await _friendshipService.getFriendshipFromUserID(flexusjwt, event.requestedID);

    if (!response.isSuccessful) {
      emit(FriendshipError(error: response.error.toString()));
      return;
    }

    JWTHelper.saveJWTsFromResponse(response);

    if (response.body != "null") {
      friendship = Friendship.fromJson(response.body);
    }

    emit(FriendshipLoaded(friendship: friendship));
  }

  void _onPatchFriendship(PatchFriendship event, Emitter<FriendshipState> emit) async {
    Friendship? friendship;

    switch (event.name) {
      case "isAccepted":
        final flexusjwt = JWTHelper.getActiveJWT();
        if (flexusjwt == null) {
          //NO-VALID-JWT-ERROR
          return;
        }

        final response = await _friendshipService.patchFriendship(flexusjwt, event.requestedID, {"isAccepted": event.value});

        if (!response.isSuccessful) {
          emit(FriendshipLoaded(friendship: null));
          break;
        }

        JWTHelper.saveJWTsFromResponse(response);

        UserAccount userAccount = userBox.get("userAccount");
        friendship = Friendship(requestorID: userAccount.id, requestedID: event.requestedID, isAccepted: event.value);
        emit(FriendshipLoaded(friendship: friendship));
        break;

      default:
        emit(FriendshipLoaded(friendship: friendship));
        break;
    }
  }

  void _onDeleteFriendship(DeleteFriendship event, Emitter<FriendshipState> emit) async {
    final flexusjwt = JWTHelper.getActiveJWT();
    if (flexusjwt == null) {
      //NO-VALID-JWT-ERROR
      return;
    }

    final response = await _friendshipService.deleteFriendship(flexusjwt, event.requestedID);

    if (!response.isSuccessful) {
      emit(FriendshipError(error: response.error.toString()));
      return;
    }

    JWTHelper.saveJWTsFromResponse(response);

    emit(FriendshipLoaded(friendship: null));
  }
}

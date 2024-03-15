import 'dart:convert';

import 'package:app/api/user_list_service.dart';
import 'package:chopper/chopper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'user_list_event.dart';
part 'user_list_state.dart';

class UserListBloc extends Bloc<UserListEvent, UserListState> {
  final UserListService userListService = UserListService.create();
  final userBox = Hive.box('userBox');

  UserListBloc() : super(UserListInitial()) {
    on<PostUserList>(_onPostUserList);
    on<GetHasUserList>(_onGetHasUserList);
    on<PatchUserList>(_onPatchUserList);
    on<GetEntireUserList>(_onGetEntireUserList);
  }

  void _onPostUserList(PostUserList event, Emitter<UserListState> emit) async {
    emit(UserListCreating());

    Response<dynamic> response = await userListService.postUserList(
      userBox.get("flexusjwt"),
      {"columnName": event.columnName},
    );

    if (response.isSuccessful) {
      if (response.bodyString != "null") {
        emit(UserListCreated(listID: int.parse(response.bodyString)));
      } else {
        emit(UserListError(error: "Error creating userlist. Was returned empty!"));
      }
    } else {
      emit(UserListError(error: response.error.toString()));
    }
  }

  void _onGetHasUserList(GetHasUserList event, Emitter<UserListState> emit) async {
    emit(HasUserListLoading());

    Response<dynamic> response = await userListService.getHasUserList(userBox.get("flexusjwt"), {
      "listID": event.listID,
      "userID": event.userID,
    });

    if (response.isSuccessful) {
      if (response.bodyString != "null") {
        emit(HasUserListLoaded(isCreated: bool.parse(response.bodyString)));
      } else {
        emit(UserListError(error: "Error creating userlist. Was returned empty!"));
      }
    } else {
      emit(UserListError(error: response.error.toString()));
    }
  }

  void _onPatchUserList(PatchUserList event, Emitter<UserListState> emit) async {
    emit(UserListUpdating());

    final response = await userListService.patchUserList(userBox.get("flexusjwt"), {
      "listID": event.listID,
      "userID": event.userID,
    });

    if (response.isSuccessful) {
      emit(UserListUpdated(isCreated: !event.isDeleting));
    } else {
      emit(UserListError(error: "Failed patching Userlist ${event.listID}"));
    }
  }

  void _onGetEntireUserList(GetEntireUserList event, Emitter<UserListState> emit) async {
    emit(EntireUserListLoading());

    Response<dynamic> response = await userListService.getEntireUserList(userBox.get("flexusjwt"), event.listID);

    List<int> userList = [];
    if (response.isSuccessful) {
      if (response.bodyString != "null") {
        userList = List<int>.from(json.decode(response.bodyString));
      }
      emit(EntireUserListLoaded(userList: userList));
    } else {
      emit(UserListError(error: response.error.toString()));
    }
  }
}

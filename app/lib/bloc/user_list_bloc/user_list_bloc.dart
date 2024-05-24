import 'package:app/api/user_list/user_list_service.dart';
import 'package:app/resources/app_settings.dart';
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
    if (!AppSettings.hasConnection) {
      emit(UserListError(error: "No internet connection!"));
      return;
    }

    Response<dynamic> response = await userListService.postUserList(
      userBox.get("flexusjwt"),
      {"columnName": event.columnName},
    );

    if (!response.isSuccessful) {
      emit(UserListError(error: response.error.toString()));
      return;
    }

    if (response.body == "null") {
      emit(UserListError(error: "Error creating userlist. Was returned empty!"));
      return;
    }

    emit(UserListCreated(listID: response.body));
  }

  void _onGetHasUserList(GetHasUserList event, Emitter<UserListState> emit) async {
    emit(HasUserListLoading());

    if (!AppSettings.hasConnection) {
      emit(UserListError(error: "No internet connection!"));
      return;
    }

    Response<dynamic> response = await userListService.getHasUserList(userBox.get("flexusjwt"), {
      "listID": event.listID,
      "userID": event.userID,
    });

    if (!response.isSuccessful) {
      emit(UserListError(error: response.error.toString()));
      return;
    }

    if (response.body == "null") {
      emit(UserListError(error: "Error creating userlist. Was returned empty!"));
      return;
    }

    emit(HasUserListLoaded(isCreated: response.body));
  }

  void _onPatchUserList(PatchUserList event, Emitter<UserListState> emit) async {
    if (!AppSettings.hasConnection) {
      emit(UserListError(error: "No internet connection!"));
      return;
    }

    final response = await userListService.patchUserList(userBox.get("flexusjwt"), {
      "listID": event.listID,
      "userID": event.userID,
    });

    if (!response.isSuccessful) {
      emit(UserListError(error: "Failed patching Userlist ${event.listID}"));
      return;
    }

    emit(UserListUpdated(isCreated: !event.isDeleting));
  }

  void _onGetEntireUserList(GetEntireUserList event, Emitter<UserListState> emit) async {
    if (!AppSettings.hasConnection) {
      emit(UserListError(error: "No internet connection!"));
      return;
    }

    emit(EntireUserListLoading());

    List<int> userList = [];

    Response<dynamic> response = await userListService.getUserListFromListID(userBox.get("flexusjwt"), event.listID);

    if (!response.isSuccessful) {
      emit(UserListError(error: response.error.toString()));
      return;
    }

    if (response.body != "null") {
      userList = List<int>.from(response.body);
    }

    emit(EntireUserListLoaded(userList: userList));
  }
}

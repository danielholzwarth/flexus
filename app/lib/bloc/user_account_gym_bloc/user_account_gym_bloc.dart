import 'package:app/api/user_account_gym_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'user_account_gym_event.dart';
part 'user_account_gym_state.dart';

class UserAccountGymBloc extends Bloc<UserAccountGymEvent, UserAccountGymState> {
  final UserAccountGymService userAccountGymService = UserAccountGymService.create();
  final userBox = Hive.box('userBox');

  UserAccountGymBloc() : super(UserAccountGymInitial()) {
    on<PostUserAccountGym>(_onPostUserAccountGym);
    on<DeleteUserAccountGym>(_onDeleteUserAccountGym);
  }

  void _onPostUserAccountGym(PostUserAccountGym event, Emitter<UserAccountGymState> emit) async {
    emit(UserAccountGymCreating());

    final response = await userAccountGymService.postUserAccountGym(userBox.get("flexusjwt"), {"gymID": event.gymID});

    if (response.isSuccessful) {
      emit(UserAccountGymCreated());
    } else {
      emit(UserAccountGymError(error: response.error.toString()));
    }
  }

  void _onDeleteUserAccountGym(DeleteUserAccountGym event, Emitter<UserAccountGymState> emit) async {
    emit(UserAccountGymDeleting());

    final response = await userAccountGymService.deleteUserAccountGym(userBox.get("flexusjwt"), event.gymID);

    if (response.isSuccessful) {
      emit(UserAccountGymDeleted());
    } else {
      emit(UserAccountGymError(error: response.error.toString()));
    }
  }
}

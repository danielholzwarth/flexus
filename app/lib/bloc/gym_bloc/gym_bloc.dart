import 'dart:convert';

import 'package:app/api/gym_service.dart';
import 'package:app/hive/gym.dart';
import 'package:app/hive/gym_overview.dart';
import 'package:app/hive/user_account.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'gym_event.dart';
part 'gym_state.dart';

class GymBloc extends Bloc<GymEvent, GymState> {
  final GymService _gymService = GymService.create();
  final userBox = Hive.box('userBox');

  GymBloc() : super(GymInitial()) {
    on<GetGymOverviews>(_onGetGymOverviews);
  }

  void _onGetGymOverviews(GetGymOverviews event, Emitter<GymState> emit) async {
    emit(GymOverviewsLoading());

    final response = await _gymService.getGymOverviews(userBox.get("flexusjwt"));
    List<GymOverview> gymOverviews = [];

    if (response.isSuccessful) {
      debugPrint(response.bodyString);

      final List<dynamic> jsonList = jsonDecode(response.bodyString);

      gymOverviews = jsonList.map((json) {
        List<UserAccount> userAccounts = [];
        if (json['currentUserAccounts'] != null) {
          userAccounts = List<UserAccount>.from(json['currentUserAccounts'].map((accountJson) {
            return UserAccount(
              id: accountJson['userAccountID'],
              username: accountJson['username'],
              name: accountJson['name'],
              createdAt: DateTime.parse(accountJson['createdAt']),
              level: accountJson['level'],
              profilePicture: accountJson['profilePicture'] != null ? base64Decode(accountJson['profilePicture']) : null,
            );
          }));
        }
        return GymOverview(
          gym: Gym(
            id: json['gym']['id'],
            name: json['gym']['name'],
            country: json['gym']['country'],
            cityName: json['gym']['cityName'],
            zipCode: json['gym']['zipCode'],
            streetName: json['gym']['streetName'],
            houseNumber: json['gym']['houseNumber'],
            latitude: json['gym']['latitude'],
            longitude: json['gym']['longitude'],
          ),
          userAccounts: userAccounts,
          totalFriends: json['totalFriends'],
        );
      }).toList();
    }

    emit(GymOverviewsLoaded(gymOverviews: gymOverviews));
  }
}

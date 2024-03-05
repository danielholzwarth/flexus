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
    // on<CreateGym>(_onCreateGym);
    // on<GetGymOverview>(_onGetGymOverview);
    on<GetGymOverviews>(_onGetGymOverviews);
    // on<DeleteGym>(_onDeleteGym);
  }

  // void _onCreateGym(CreateGym event, Emitter<GymState> emit) async {
  //   emit(GymCreating());

  //   //simulate backend request delay
  //   // await Future.delayed(const Duration(seconds: 1));

  //   Response<dynamic> response = await _gymService.postGym(userBox.get("flexusjwt"), {"geoPint": event.gym});

  //   if (response.isSuccessful) {
  //     emit(GymCreated());
  //   } else {
  //     emit(GymError());
  //   }
  // }

  // void _onGetGymOverview(GetGymOverview event, Emitter<GymState> emit) async {
  //   emit(GymLoading());

  //   //simulate backend request delay
  //   await Future.delayed(const Duration(seconds: 1));

  //   Response<dynamic> response = await _gymService.getGymOverview(userBox.get("flexusjwt"), event.gym);
  //   if (response.isSuccessful) {
  //     if (response.bodyString != "null") {
  //       //final Map<String, dynamic> jsonMap = jsonDecode(response.bodyString);

  //       final gymOverview = GymOverview(
  //         id: 1,
  //         name: "name",
  //         cityName: "cityName",
  //         zipCode: "zipCode",
  //         streetName: "streetName",
  //         houseNumber: "houseNumber",
  //         userAccounts: [UserAccount(id: 1, username: "username", name: "name", createdAt: DateTime.now(), level: 1)],
  //         totalFriends: 5,
  //       );

  //       emit(GymOverviewLoaded(gymOverview: gymOverview));
  //     } else {
  //       emit(GymOverviewLoaded(gymOverview: null));
  //     }
  //   } else {
  //     emit(GymError());
  //   }
  // }

  // void _onDeleteGym(DeleteGym event, Emitter<GymState> emit) async {
  //   emit(GymDeleting());

  //   //simulate backend request delay
  //   // await Future.delayed(const Duration(seconds: 1));

  //   final response = await _gymService.deleteGym(userBox.get("flexusjwt"), {"geoPoint": event.gym});

  //   if (response.isSuccessful) {
  //     emit(GymDeleted());
  //   } else {
  //     emit(GymError());
  //   }
  // }

  void _onGetGymOverviews(GetGymOverviews event, Emitter<GymState> emit) async {
    emit(GymOverviewsLoading());

    //simulate backend request delay
    // await Future.delayed(const Duration(seconds: 1));

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

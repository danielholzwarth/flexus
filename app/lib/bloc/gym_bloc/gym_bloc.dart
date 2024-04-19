import 'dart:convert';

import 'package:app/api/gym/gym_service.dart';
import 'package:app/hive/gym/gym.dart';
import 'package:app/hive/gym/gym_overview.dart';
import 'package:app/hive/user_account/user_account.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'gym_event.dart';
part 'gym_state.dart';

class GymBloc extends Bloc<GymEvent, GymState> {
  final GymService _gymService = GymService.create();
  final userBox = Hive.box('userBox');

  GymBloc() : super(GymInitial()) {
    on<PostGym>(_onPostGym);
    on<GetGym>(_onGetGym);
    on<GetGymsSearch>(_onGetGymsSearch);
    on<GetGymOverviews>(_onGetGymOverviews);
  }

  void _onPostGym(PostGym event, Emitter<GymState> emit) async {
    final response = await _gymService.postGym(userBox.get("flexusjwt"), {
      "name": event.locationData['name'],
      "streetName": event.locationData['address']['road'],
      "houseNumber": event.locationData['address']['house_number'],
      "zipCode": event.locationData['address']['postcode'],
      "cityName": event.locationData['address']['city'] ?? event.locationData['address']['town'] ?? event.locationData['address']['village'],
      "latitude": double.parse(event.locationData['lat']),
      "longitude": double.parse(event.locationData['lon']),
    });

    if (response.isSuccessful) {
      emit(GymCreated());
    } else {
      emit(GymError(error: response.error.toString()));
    }
  }

  void _onGetGym(GetGym event, Emitter<GymState> emit) async {
    final response = await _gymService.getGym(userBox.get("flexusjwt"), event.name, event.lat, event.lon);

    if (response.isSuccessful) {
      bool exists = response.body;
      emit(GymLoaded(exists: exists));
    } else {
      emit(GymError(error: response.error.toString()));
    }
  }

  void _onGetGymsSearch(GetGymsSearch event, Emitter<GymState> emit) async {
    final response = await _gymService.getGymsSearch(userBox.get("flexusjwt"), keyword: event.query);

    if (response.isSuccessful) {
      List<Gym> gyms = [];
      if (response.body != "null") {
        final List<dynamic> jsonList = response.body;

        for (final gymData in jsonList) {
          final Gym gym = Gym(
            id: gymData['id'],
            name: gymData['name'],
            streetName: gymData['streetName'],
            houseNumber: gymData['houseNumber'],
            zipCode: gymData['zipCode'],
            cityName: gymData['cityName'],
            latitude: gymData['latitude'],
            longitude: gymData['longitude'],
          );
          gyms.add(gym);
        }

        emit(GymsSearchLoaded(gyms: gyms));
      } else {
        emit(GymsSearchLoaded(gyms: gyms));
      }
    } else {
      emit(GymError(error: response.error.toString()));
    }
  }

  void _onGetGymOverviews(GetGymOverviews event, Emitter<GymState> emit) async {
    final response = await _gymService.getGymOverviews(userBox.get("flexusjwt"));
    List<GymOverview> gymOverviews = [];

    if (response.isSuccessful) {
      if (response.body != "null") {
        final List<dynamic> jsonList = response.body;

        print(response.body);

        gymOverviews = jsonList.map((json) {
          List<UserAccount> userAccounts = [];
          if (json['currentUserAccounts'] != null) {
            userAccounts = List<UserAccount>.from(
              json['currentUserAccounts'].map(
                (accountJson) {
                  return UserAccount(
                    id: accountJson['userAccountID'],
                    username: accountJson['username'],
                    name: accountJson['name'],
                    createdAt: DateTime.parse(accountJson['createdAt']),
                    level: accountJson['level'],
                    profilePicture: accountJson['profilePicture'] != null ? base64Decode(accountJson['profilePicture']) : null,
                  );
                },
              ),
            );
          }
          return GymOverview(
            gym: Gym(
              id: json['gym']['id'],
              name: json['gym']['name'],
              streetName: json['gym']['streetName'],
              zipCode: json['gym']['zipCode'],
              houseNumber: json['gym']['houseNumber'],
              cityName: json['gym']['cityName'],
              latitude: json['gym']['latitude'],
              longitude: json['gym']['longitude'],
            ),
            userAccounts: userAccounts,
            totalFriends: json['totalFriends'],
          );
        }).toList();
      }

      userBox.put("gymOverviews", gymOverviews);

      emit(GymOverviewsLoaded(gymOverviews: gymOverviews));
    } else {
      emit(GymError(error: response.error.toString()));
    }
  }
}

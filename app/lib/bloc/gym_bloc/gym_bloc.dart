import 'package:app/api/gym/gym_service.dart';
import 'package:app/hive/gym/gym.dart';
import 'package:app/hive/gym/gym_overview.dart';
import 'package:app/resources/app_settings.dart';
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
    on<GetMyGyms>(_onGetMyGyms);
    on<GetGymOverviews>(_onGetGymOverviews);
  }

  void _onPostGym(PostGym event, Emitter<GymState> emit) async {
    if (!AppSettings.hasConnection) {
      emit(GymError(error: "No internet connection!"));
      return;
    }

    final response = await _gymService.postGym(userBox.get("flexusjwt"), {
      "name": event.locationData['name'],
      "streetName": event.locationData['address']['road'],
      "houseNumber": event.locationData['address']['house_number'],
      "zipCode": event.locationData['address']['postcode'],
      "cityName": event.locationData['address']['city'] ?? event.locationData['address']['town'] ?? event.locationData['address']['village'],
      "latitude": double.parse(event.locationData['lat']),
      "longitude": double.parse(event.locationData['lon']),
    });

    if (!response.isSuccessful) {
      emit(GymError(error: response.error.toString()));
      return;
    }

    emit(GymCreated());
  }

  void _onGetGym(GetGym event, Emitter<GymState> emit) async {
    if (!AppSettings.hasConnection) {
      emit(GymError(error: "No internet connection!"));
      return;
    }

    final response = await _gymService.getGymExisting(userBox.get("flexusjwt"), event.name, event.lat, event.lon);

    if (!response.isSuccessful) {
      emit(GymError(error: response.error.toString()));
      return;
    }

    bool exists = response.body;
    emit(GymLoaded(exists: exists));
  }

  void _onGetMyGyms(GetMyGyms event, Emitter<GymState> emit) async {
    List<Gym> myGyms = [];

    if (!AppSettings.hasConnection) {
      myGyms = userBox.get("myGyms")?.cast<Gym>() ?? [];
      emit(MyGymsLoaded(gyms: myGyms));
      return;
    }

    final response = await _gymService.getMyGyms(userBox.get("flexusjwt"), keyword: event.query);

    if (!response.isSuccessful) {
      emit(GymError(error: response.error.toString()));
      return;
    }

    if (response.body != "null") {
      final List<dynamic> jsonList = response.body;

      for (final gymData in jsonList) {
        myGyms.add(Gym.fromJson(gymData));
      }
    }

    emit(MyGymsLoaded(gyms: myGyms));
  }

  void _onGetGymsSearch(GetGymsSearch event, Emitter<GymState> emit) async {
    if (!AppSettings.hasConnection) {
      emit(GymError(error: "No internet connection!"));
      return;
    }

    final response = await _gymService.getGymsSearch(userBox.get("flexusjwt"), keyword: event.query);

    if (!response.isSuccessful) {
      emit(GymError(error: response.error.toString()));
      return;
    }

    List<Gym> gyms = [];
    if (response.body != "null") {
      final List<dynamic> jsonList = response.body;

      for (final gymData in jsonList) {
        gyms.add(Gym.fromJson(gymData));
      }
    }

    emit(GymsSearchLoaded(gyms: gyms));
  }

  void _onGetGymOverviews(GetGymOverviews event, Emitter<GymState> emit) async {
    List<GymOverview> gymOverviews = [];

    if (!AppSettings.hasConnection) {
      emit(GymError(error: "No internet connection!"));
      return;
    }

    final response = await _gymService.getGymOverviews(userBox.get("flexusjwt"));

    if (!response.isSuccessful) {
      emit(GymError(error: response.error.toString()));
      return;
    }

    if (response.body != "null") {
      gymOverviews = List<GymOverview>.from(response.body.map((json) {
        return GymOverview.fromJson(json);
      }));

      userBox.put("gymOverviews", gymOverviews);
    }

    emit(GymOverviewsLoaded(gymOverviews: gymOverviews));
  }
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gym_service.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
final class _$GymService extends GymService {
  _$GymService([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final Type definitionType = GymService;

  @override
  Future<Response<dynamic>> postGym(
    String flexusJWTString,
    Map<String, dynamic> gym,
  ) {
    final Uri $url = Uri.parse('/gyms/');
    final Map<String, String> $headers = {
      'flexusjwt': flexusJWTString,
    };
    final $body = gym;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
      headers: $headers,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> getGym(
    String flexusJWTString,
    String name,
    double lat,
    double lon,
  ) {
    final Uri $url = Uri.parse('/gyms/exists');
    final Map<String, dynamic> $params = <String, dynamic>{
      'name': name,
      'lat': lat,
      'lon': lon,
    };
    final Map<String, String> $headers = {
      'flexusjwt': flexusJWTString,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
      headers: $headers,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> getGymsSearch(
    String flexusJWTString, {
    String? keyword,
  }) {
    final Uri $url = Uri.parse('/gyms/search');
    final Map<String, dynamic> $params = <String, dynamic>{'keyword': keyword};
    final Map<String, String> $headers = {
      'flexusjwt': flexusJWTString,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
      headers: $headers,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> getGymOverviews(String flexusJWTString) {
    final Uri $url = Uri.parse('/gyms/overviews');
    final Map<String, String> $headers = {
      'flexusjwt': flexusJWTString,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      headers: $headers,
    );
    return client.send<dynamic, dynamic>($request);
  }
}

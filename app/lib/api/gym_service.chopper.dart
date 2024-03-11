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
  Future<Response<dynamic>> getGymOverviews(String flexusJWTString) {
    final Uri $url = Uri.parse('/gyms/');
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

  @override
  Future<Response<dynamic>> deleteGym(
    String flexusJWTString,
    int gymID,
  ) {
    final Uri $url = Uri.parse('/gyms/${gymID}');
    final Map<String, String> $headers = {
      'flexusjwt': flexusJWTString,
    };
    final Request $request = Request(
      'DELETE',
      $url,
      client.baseUrl,
      headers: $headers,
    );
    return client.send<dynamic, dynamic>($request);
  }
}

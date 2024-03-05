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
}

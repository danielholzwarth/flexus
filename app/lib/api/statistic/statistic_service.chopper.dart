// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'statistic_service.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
final class _$StatisticService extends StatisticService {
  _$StatisticService([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final Type definitionType = StatisticService;

  @override
  Future<Response<dynamic>> getTotalMovedWeight(
    String flexusJWTString,
    int periodInDays,
  ) {
    final Uri $url = Uri.parse('/statistics/total-moved-weight');
    final Map<String, dynamic> $params = <String, dynamic>{
      'periodInDays': periodInDays
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
  Future<Response<dynamic>> getTotalReps(
    String flexusJWTString,
    int periodInDays,
  ) {
    final Uri $url = Uri.parse('/statistics/total-reps');
    final Map<String, dynamic> $params = <String, dynamic>{
      'periodInDays': periodInDays
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
  Future<Response<dynamic>> getWorkoutDays(
    String flexusJWTString,
    int periodInDays,
  ) {
    final Uri $url = Uri.parse('/statistics/workout-days');
    final Map<String, dynamic> $params = <String, dynamic>{
      'periodInDays': periodInDays
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
  Future<Response<dynamic>> getWorkoutDuration(
    String flexusJWTString,
    int periodInDays,
  ) {
    final Uri $url = Uri.parse('/statistics/workout-duration');
    final Map<String, dynamic> $params = <String, dynamic>{
      'periodInDays': periodInDays
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
}

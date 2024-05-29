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
    String flexusJWTAccess,
    int period,
  ) {
    final Uri $url = Uri.parse('/statistics/total-moved-weight');
    final Map<String, dynamic> $params = <String, dynamic>{'period': period};
    final Map<String, String> $headers = {
      'flexus-jwt': flexusJWTAccess,
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
    String flexusJWTAccess,
    int period,
  ) {
    final Uri $url = Uri.parse('/statistics/total-reps');
    final Map<String, dynamic> $params = <String, dynamic>{'period': period};
    final Map<String, String> $headers = {
      'flexus-jwt': flexusJWTAccess,
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
    String flexusJWTAccess,
    int period,
  ) {
    final Uri $url = Uri.parse('/statistics/workout-days');
    final Map<String, dynamic> $params = <String, dynamic>{'period': period};
    final Map<String, String> $headers = {
      'flexus-jwt': flexusJWTAccess,
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
    String flexusJWTAccess,
    int period,
  ) {
    final Uri $url = Uri.parse('/statistics/workout-duration');
    final Map<String, dynamic> $params = <String, dynamic>{'period': period};
    final Map<String, String> $headers = {
      'flexus-jwt': flexusJWTAccess,
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

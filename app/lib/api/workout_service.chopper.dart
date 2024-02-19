// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_service.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
final class _$WorkoutService extends WorkoutService {
  _$WorkoutService([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final Type definitionType = WorkoutService;

  @override
  Future<Response<dynamic>> getWorkouts(String flexusJWTString) {
    final Uri $url = Uri.parse('/workouts/');
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
  Future<Response<dynamic>> getSearchedWorkouts(
    String flexusJWTString,
    String keyWord,
  ) {
    final Uri $url = Uri.parse('/workouts/search');
    final Map<String, dynamic> $params = <String, dynamic>{'keyword': keyWord};
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
  Future<Response<dynamic>> getArchivedWorkouts(String flexusJWTString) {
    final Uri $url = Uri.parse('/workouts/archive');
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
  Future<Response<dynamic>> getSearchedArchivedWorkouts(
    String flexusJWTString,
    String keyWord,
  ) {
    final Uri $url = Uri.parse('/workouts/archive/search');
    final Map<String, dynamic> $params = <String, dynamic>{'keyword': keyWord};
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
  Future<Response<dynamic>> getWorkoutDetails(
    String flexusJWTString,
    int workoutID,
  ) {
    final Uri $url = Uri.parse('/workouts/${workoutID}');
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

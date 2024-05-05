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
  Future<Response<dynamic>> postWorkout(
    String flexusJWTString,
    Map<String, dynamic> workout,
  ) {
    final Uri $url = Uri.parse('/workouts');
    final Map<String, String> $headers = {
      'flexusjwt': flexusJWTString,
    };
    final $body = workout;
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
  Future<Response<dynamic>> getWorkoutOverviews(String flexusJWTString) {
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
  Future<Response<dynamic>> getWorkoutFromID(
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

  @override
  Future<Response<dynamic>> patchWorkout(
    String flexusJWTString,
    int workoutID,
    Map<String, dynamic> body,
  ) {
    final Uri $url = Uri.parse('/workouts/${workoutID}');
    final Map<String, String> $headers = {
      'flexusjwt': flexusJWTString,
    };
    final $body = body;
    final Request $request = Request(
      'PATCH',
      $url,
      client.baseUrl,
      body: $body,
      headers: $headers,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> patchStartWorkout(
    String flexusJWTString,
    int workoutID,
    Map<String, dynamic> body,
  ) {
    final Uri $url = Uri.parse('/workouts/start/${workoutID}');
    final Map<String, String> $headers = {
      'flexusjwt': flexusJWTString,
    };
    final $body = body;
    final Request $request = Request(
      'PATCH',
      $url,
      client.baseUrl,
      body: $body,
      headers: $headers,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> patchFinishWorkout(
    String flexusJWTString,
    Map<String, dynamic> body,
  ) {
    final Uri $url = Uri.parse('/workouts/finish');
    final Map<String, String> $headers = {
      'flexusjwt': flexusJWTString,
    };
    final $body = body;
    final Request $request = Request(
      'PATCH',
      $url,
      client.baseUrl,
      body: $body,
      headers: $headers,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> deleteWorkout(
    String flexusJWTString,
    int workoutID,
  ) {
    final Uri $url = Uri.parse('/workouts/${workoutID}');
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

  @override
  Future<Response<dynamic>> getWorkoutDetailsFromWorkoutID(
    String flexusJWTString,
    int workoutID,
  ) {
    final Uri $url = Uri.parse('/workouts/details/${workoutID}');
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
  Future<Response<dynamic>> patchEntireWorkouts(
    String flexusJWTString,
    Map<String, dynamic> body,
  ) {
    final Uri $url = Uri.parse('/workouts/sync');
    final Map<String, String> $headers = {
      'flexusjwt': flexusJWTString,
    };
    final $body = body;
    final Request $request = Request(
      'PATCH',
      $url,
      client.baseUrl,
      body: $body,
      headers: $headers,
    );
    return client.send<dynamic, dynamic>($request);
  }
}

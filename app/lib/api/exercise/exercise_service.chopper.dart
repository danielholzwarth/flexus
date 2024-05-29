// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_service.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
final class _$ExerciseService extends ExerciseService {
  _$ExerciseService([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final Type definitionType = ExerciseService;

  @override
  Future<Response<dynamic>> postExercise(
    String flexusJWTAccess,
    Map<String, dynamic> exercise,
  ) {
    final Uri $url = Uri.parse('/exercises/');
    final Map<String, String> $headers = {
      'flexus-jwt': flexusJWTAccess,
    };
    final $body = exercise;
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
  Future<Response<dynamic>> getExercises(String flexusJWTAccess) {
    final Uri $url = Uri.parse('/exercises/');
    final Map<String, String> $headers = {
      'flexus-jwt': flexusJWTAccess,
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
  Future<Response<dynamic>> getExerciseFromExerciseID(
    String flexusJWTAccess,
    int exerciseID,
  ) {
    final Uri $url = Uri.parse('/exercises/single/${exerciseID}');
    final Map<String, String> $headers = {
      'flexus-jwt': flexusJWTAccess,
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
  Future<Response<dynamic>> getExercisesFromSplitID(
    String flexusJWTAccess,
    int splitID,
  ) {
    final Uri $url = Uri.parse('/exercises/${splitID}');
    final Map<String, String> $headers = {
      'flexus-jwt': flexusJWTAccess,
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

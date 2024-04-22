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
    String flexusJWTString,
    Map<String, dynamic> exercise,
  ) {
    final Uri $url = Uri.parse('/exercises/');
    final Map<String, String> $headers = {
      'flexusjwt': flexusJWTString,
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
  Future<Response<dynamic>> getExercises(String flexusJWTString) {
    final Uri $url = Uri.parse('/exercises/');
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

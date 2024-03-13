// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_account_gym_service.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
final class _$UserAccountGymService extends UserAccountGymService {
  _$UserAccountGymService([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final Type definitionType = UserAccountGymService;

  @override
  Future<Response<dynamic>> postUserAccountGym(
    String flexusJWTString,
    Map<String, dynamic> body,
  ) {
    final Uri $url = Uri.parse('/user_account_gym/');
    final Map<String, String> $headers = {
      'flexusjwt': flexusJWTString,
    };
    final $body = body;
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
  Future<Response<dynamic>> getUserAccountGym(
    String flexusJWTString, {
    int? gymID,
  }) {
    final Uri $url = Uri.parse('/user_account_gym/');
    final Map<String, dynamic> $params = <String, dynamic>{'gymID': gymID};
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
  Future<Response<dynamic>> deleteUserAccountGym(
    String flexusJWTString,
    int gymID,
  ) {
    final Uri $url = Uri.parse('/user_account_gym/${gymID}');
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

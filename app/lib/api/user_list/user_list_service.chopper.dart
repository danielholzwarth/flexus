// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_list_service.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
final class _$UserListService extends UserListService {
  _$UserListService([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final Type definitionType = UserListService;

  @override
  Future<Response<dynamic>> postUserList(
    String flexusJWTString,
    Map<String, dynamic> body,
  ) {
    final Uri $url = Uri.parse('/user_lists/');
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
  Future<Response<dynamic>> getHasUserList(
    String flexusJWTString,
    Map<String, dynamic> body,
  ) {
    final Uri $url = Uri.parse('/user_lists/');
    final Map<String, String> $headers = {
      'flexusjwt': flexusJWTString,
    };
    final $body = body;
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      body: $body,
      headers: $headers,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> patchUserList(
    String flexusJWTString,
    Map<String, dynamic> body,
  ) {
    final Uri $url = Uri.parse('/user_lists/');
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
  Future<Response<dynamic>> getUserListFromListID(
    String flexusJWTString,
    int listID,
  ) {
    final Uri $url = Uri.parse('/user_lists/${listID}');
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

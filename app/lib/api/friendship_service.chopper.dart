// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'friendship_service.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
final class _$FriendshipService extends FriendshipService {
  _$FriendshipService([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final Type definitionType = FriendshipService;

  @override
  Future<Response<dynamic>> postFriendship(
    String flexusJWTString,
    int userAccountID,
  ) {
    final Uri $url = Uri.parse('/friendships/${userAccountID}');
    final Map<String, String> $headers = {
      'flexusjwt': flexusJWTString,
    };
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      headers: $headers,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> getFriendship(
    String flexusJWTString,
    int userAccountID,
  ) {
    final Uri $url = Uri.parse('/friendships/${userAccountID}');
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
  Future<Response<dynamic>> patchFriendship(
    String flexusJWTString,
    int userAccountID,
    Map<String, dynamic> body,
  ) {
    final Uri $url = Uri.parse('/friendships/${userAccountID}');
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
  Future<Response<dynamic>> deleteFriendship(
    String flexusJWTString,
    int userAccountID,
  ) {
    final Uri $url = Uri.parse('/friendships/${userAccountID}');
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

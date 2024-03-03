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
    int userID,
  ) {
    final Uri $url = Uri.parse('/friendships/${userID}');
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
}

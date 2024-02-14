// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_settings_service.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
final class _$UserSettingsService extends UserSettingsService {
  _$UserSettingsService([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final Type definitionType = UserSettingsService;

  @override
  Future<Response<dynamic>> getUserSettings(String tokenString) {
    final Uri $url = Uri.parse('/user_settings/');
    final Map<String, String> $headers = {
      'token': tokenString,
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

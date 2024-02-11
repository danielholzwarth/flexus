// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_account_service.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
final class _$UserAccountService extends UserAccountService {
  _$UserAccountService([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final Type definitionType = UserAccountService;

  @override
  Future<Response<dynamic>> postUserAccount(Map<String, dynamic> userAccount) {
    final Uri $url = Uri.parse('/useraccounts');
    final $body = userAccount;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> getUsernameAvailability(String username) {
    final Uri $url = Uri.parse('/useraccounts/');
    final Map<String, dynamic> $params = <String, dynamic>{
      'username': username
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
    );
    return client.send<dynamic, dynamic>($request);
  }
}

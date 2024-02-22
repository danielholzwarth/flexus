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
  Future<Response<dynamic>> getUserAccountOverview(
    String flexusJWTString,
    int userAccountID,
  ) {
    final Uri $url = Uri.parse('/user_accounts/${userAccountID}/overview');
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

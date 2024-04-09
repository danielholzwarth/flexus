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
  Future<Response<dynamic>> getUserAccount(
    String flexusJWTString,
    int userAccountID,
  ) {
    final Uri $url = Uri.parse('/user_accounts/${userAccountID}');
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
  Future<Response<dynamic>> patchUserAccount(
    String flexusJWTString,
    Map<String, dynamic> body,
  ) {
    final Uri $url = Uri.parse('/user_accounts/');
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
  Future<Response<dynamic>> deleteUserAccount(String flexusJWTString) {
    final Uri $url = Uri.parse('/user_accounts/');
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
  Future<Response<dynamic>> getUserAccounts(
    String flexusJWTString, {
    String? keyword,
    bool? isFriend,
    bool? hasRequest,
    int? gymID,
    bool? isWorkingOut,
  }) {
    final Uri $url = Uri.parse('/user_accounts/');
    final Map<String, dynamic> $params = <String, dynamic>{
      'keyword': keyword,
      'isFriend': isFriend,
      'hasRequest': hasRequest,
      'gymID': gymID,
      'isWorkingOut': isWorkingOut,
    };
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
  Future<Response<dynamic>> patchEntireUserAccount(
    String flexusJWTString,
    Map<String, dynamic> body,
  ) {
    final Uri $url = Uri.parse('/user_accounts/sync');
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

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'best_lifts_service.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
final class _$BestLiftsService extends BestLiftsService {
  _$BestLiftsService([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final Type definitionType = BestLiftsService;

  @override
  Future<Response<dynamic>> postBestLift(
    String flexusJWTAccess,
    Map<String, dynamic> body,
  ) {
    final Uri $url = Uri.parse('/best_lifts/');
    final Map<String, String> $headers = {
      'flexus-jwt': flexusJWTAccess,
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
  Future<Response<dynamic>> patchBestLift(
    String flexusJWTAccess,
    Map<String, dynamic> body,
  ) {
    final Uri $url = Uri.parse('/best_lifts/');
    final Map<String, String> $headers = {
      'flexus-jwt': flexusJWTAccess,
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
  Future<Response<dynamic>> getBestLiftsFromUserID(
    String flexusJWTAccess,
    int userAccountID,
  ) {
    final Uri $url = Uri.parse('/best_lifts/${userAccountID}');
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

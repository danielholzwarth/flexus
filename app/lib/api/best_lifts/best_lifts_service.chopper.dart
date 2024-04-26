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
  Future<Response<dynamic>> getBestLiftsFromUserID(
    String flexusJWTString,
    int userAccountID,
  ) {
    final Uri $url = Uri.parse('/best_lifts/${userAccountID}');
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

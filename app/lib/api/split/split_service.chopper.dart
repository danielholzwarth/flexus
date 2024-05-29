// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'split_service.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
final class _$SplitService extends SplitService {
  _$SplitService([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final Type definitionType = SplitService;

  @override
  Future<Response<dynamic>> getSplitsFromPlanID(
    String flexusJWTAccess,
    int planID,
  ) {
    final Uri $url = Uri.parse('/splits/${planID}');
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

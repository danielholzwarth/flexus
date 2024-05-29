// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_service.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
final class _$ReportService extends ReportService {
  _$ReportService([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final Type definitionType = ReportService;

  @override
  Future<Response<dynamic>> postReport(
    String flexusJWTAccess,
    Map<String, dynamic> body,
  ) {
    final Uri $url = Uri.parse('/reports');
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
}

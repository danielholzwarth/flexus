// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plan_service.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
final class _$PlanService extends PlanService {
  _$PlanService([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final Type definitionType = PlanService;

  @override
  Future<Response<dynamic>> postPlan(
    String flexusJWTString,
    Map<String, dynamic> plan,
  ) {
    final Uri $url = Uri.parse('/plans');
    final Map<String, String> $headers = {
      'flexusjwt': flexusJWTString,
    };
    final $body = plan;
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
  Future<Response<dynamic>> getPlans(String flexusJWTString) {
    final Uri $url = Uri.parse('/plans');
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
  Future<Response<dynamic>> getActivePlan(String flexusJWTString) {
    final Uri $url = Uri.parse('/plans/active');
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
  Future<Response<dynamic>> deletePlan(
    String flexusJWTString,
    int planID,
  ) {
    final Uri $url = Uri.parse('/plans/${planID}');
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
  Future<Response<dynamic>> patchPlan(
    String flexusJWTString,
    int planID,
    Map<String, dynamic> body,
  ) {
    final Uri $url = Uri.parse('/plans/${planID}');
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
  Future<Response<dynamic>> getPlanOverview(String flexusJWTString) {
    final Uri $url = Uri.parse('/plans/overview');
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
  Future<Response<dynamic>> patchEntirePlans(
    String flexusJWTString,
    Map<String, dynamic> body,
  ) {
    final Uri $url = Uri.parse('/plans/sync');
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

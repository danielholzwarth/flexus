import 'package:app/resources/app_settings.dart';
import 'package:chopper/chopper.dart';

part 'plan_service.chopper.dart';

@ChopperApi(baseUrl: '/plans')
abstract class PlanService extends ChopperService {
  @Post()
  Future<Response> postPlan(
    @Header('flexus-jwt') String flexusJWTAccess,
    @Body() Map<String, dynamic> plan,
  );

  @Get()
  Future<Response> getPlans(
    @Header('flexus-jwt') String flexusJWTAccess,
  );

  @Get(path: '/active')
  Future<Response> getActivePlan(
    @Header('flexus-jwt') String flexusJWTAccess,
  );

  @Delete(path: '/{planID}')
  Future<Response> deletePlan(
    @Header('flexus-jwt') String flexusJWTAccess,
    @Path('planID') int planID,
  );

  @Patch(path: '/{planID}')
  Future<Response> patchPlan(
    @Header('flexus-jwt') String flexusJWTAccess,
    @Path('planID') int planID,
    @Body() Map<String, dynamic> body,
  );

  @Get(path: '/overview')
  Future<Response> getPlanOverview(
    @Header('flexus-jwt') String flexusJWTAccess,
  );

  @Patch(path: '/sync')
  Future<Response> patchEntirePlans(
    @Header('flexus-jwt') String flexusJWTAccess,
    @Body() Map<String, dynamic> body,
  );

  static PlanService create() {
    final client = ChopperClient(
        baseUrl: AppSettings.useIPv4 ? Uri.parse('http://${AppSettings.ipv4}:8080') : Uri.parse('http://10.0.2.2:8080'),
        services: [
          _$PlanService(),
        ],
        converter: const JsonConverter());
    return _$PlanService(client);
  }
}

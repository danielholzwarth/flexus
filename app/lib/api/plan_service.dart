import 'package:app/resources/app_settings.dart';
import 'package:chopper/chopper.dart';

part 'plan_service.chopper.dart';

@ChopperApi(baseUrl: '/plans')
abstract class PlanService extends ChopperService {
  @Post()
  Future<Response> postPlan(
    @Header('flexusjwt') String flexusJWTString,
    @Body() Map<String, dynamic> plan,
  );

  @Get()
  Future<Response> getPlans(
    @Header('flexusjwt') String flexusJWTString,
  );

  @Get(path: '/active')
  Future<Response> getActivePlan(
    @Header('flexusjwt') String flexusJWTString,
  );

  @Delete(path: '/{planID}')
  Future<Response> deletePlan(
    @Header('flexusjwt') String flexusJWTString,
    @Path('planID') int planID,
  );

  @Patch(path: '/{planID}')
  Future<Response> patchPlan(
    @Header('flexusjwt') String flexusJWTString,
    @Path('planID') int planID,
    @Body() Map<String, dynamic> body,
  );

  @Get(path: '/overview')
  Future<Response> getPlanOverview(
    @Header('flexusjwt') String flexusJWTString,
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

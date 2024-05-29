import 'package:app/resources/app_settings.dart';
import 'package:chopper/chopper.dart';

part 'best_lifts_service.chopper.dart';

@ChopperApi(baseUrl: '/best_lifts')
abstract class BestLiftsService extends ChopperService {
  @Post(path: '/')
  Future<Response> postBestLift(
    @Header('flexus-jwt') String flexusJWTAccess,
    @Body() Map<String, dynamic> body,
  );

  @Patch(path: '/')
  Future<Response> patchBestLift(
    @Header('flexus-jwt') String flexusJWTAccess,
    @Body() Map<String, dynamic> body,
  );

  @Get(path: '/{userAccountID}')
  Future<Response> getBestLiftsFromUserID(
    @Header('flexus-jwt') String flexusJWTAccess,
    @Path('userAccountID') int userAccountID,
  );

  static BestLiftsService create() {
    final client = ChopperClient(
        baseUrl: AppSettings.useIPv4 ? Uri.parse('http://${AppSettings.ipv4}:8080') : Uri.parse('http://10.0.2.2:8080'),
        services: [
          _$BestLiftsService(),
        ],
        converter: const JsonConverter());
    return _$BestLiftsService(client);
  }
}

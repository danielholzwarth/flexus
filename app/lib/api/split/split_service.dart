import 'package:app/resources/app_settings.dart';
import 'package:chopper/chopper.dart';

part 'split_service.chopper.dart';

@ChopperApi(baseUrl: '/splits')
abstract class SplitService extends ChopperService {
  @Get(path: '/{planID}')
  Future<Response> getSplitsFromPlanID(
    @Header('flexus-jwt') String flexusJWTAccess,
    @Path('planID') int planID,
  );

  static SplitService create() {
    final client = ChopperClient(
        baseUrl: AppSettings.useIPv4 ? Uri.parse('http://${AppSettings.ipv4}:8080') : Uri.parse('http://10.0.2.2:8080'),
        services: [
          _$SplitService(),
        ],
        converter: const JsonConverter());
    return _$SplitService(client);
  }
}

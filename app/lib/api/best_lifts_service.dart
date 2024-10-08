import 'package:app/resources/app_settings.dart';
import 'package:chopper/chopper.dart';

part 'best_lifts_service.chopper.dart';

@ChopperApi(baseUrl: '/best_lifts')
abstract class BestLiftsService extends ChopperService {
  @Get(path: '/{userAccountID}')
  Future<Response> getBestLifts(
    @Header('flexusjwt') String flexusJWTString,
    @Path('userAccountID') int userAccountID,
  );

  static BestLiftsService create() {
    final client = ChopperClient(
        //For local device    ipv4:8080
        //For virtual device  10.0.2.2:8080
        //For Web             localhost:8080
        baseUrl: AppSettings.ipv4 != "" ? Uri.parse('http://${AppSettings.ipv4}:8080') : Uri.parse('http://10.0.2.2:8080'),
        services: [
          _$BestLiftsService(),
        ],
        converter: const JsonConverter());
    return _$BestLiftsService(client);
  }
}

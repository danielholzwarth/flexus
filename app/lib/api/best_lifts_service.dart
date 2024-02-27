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
        baseUrl: Uri.parse('http://10.0.2.2:8080'),
        //baseUrl: Uri.parse('http://localhost:8080'),
        services: [
          _$BestLiftsService(),
        ],
        converter: const JsonConverter());
    return _$BestLiftsService(client);
  }
}

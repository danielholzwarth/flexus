import 'package:app/resources/app_settings.dart';
import 'package:chopper/chopper.dart';

part 'gym_service.chopper.dart';

@ChopperApi(baseUrl: '/gyms')
abstract class GymService extends ChopperService {
  @Post(path: '/')
  Future<Response> postGym(
    @Header('flexus-jwt') String flexusJWTAccess,
    @Body() Map<String, dynamic> gym,
  );

  @Get(path: '/exists')
  Future<Response> getGymExisting(
    @Header('flexus-jwt') String flexusJWTAccess,
    @Query('name') String name,
    @Query('lat') double lat,
    @Query('lon') double lon,
  );

  @Get(path: '/search')
  Future<Response> getGymsSearch(
    @Header('flexus-jwt') String flexusJWTAccess, {
    @Query('keyword') String? keyword,
  });

  @Get(path: '/')
  Future<Response> getMyGyms(
    @Header('flexus-jwt') String flexusJWTAccess, {
    @Query('keyword') String? keyword,
  });

  @Get(path: '/overviews')
  Future<Response> getGymOverviews(
    @Header('flexus-jwt') String flexusJWTAccess,
  );

  static GymService create() {
    final client = ChopperClient(
        baseUrl: AppSettings.useIPv4 ? Uri.parse('http://${AppSettings.ipv4}:8080') : Uri.parse('http://10.0.2.2:8080'),
        services: [
          _$GymService(),
        ],
        converter: const JsonConverter());
    return _$GymService(client);
  }
}

import 'package:app/resources/app_settings.dart';
import 'package:chopper/chopper.dart';

part 'gym_service.chopper.dart';

@ChopperApi(baseUrl: '/gyms')
abstract class GymService extends ChopperService {
  @Post(path: '/')
  Future<Response> postGym(
    @Header('flexusjwt') String flexusJWTString,
    @Body() Map<String, dynamic> gym,
  );

  @Get(path: '/exists')
  Future<Response> getGym(
    @Header('flexusjwt') String flexusJWTString,
    @Query('name') String name,
    @Query('lat') double lat,
    @Query('lon') double lon,
  );

  @Get(path: '/search')
  Future<Response> getGymsSearch(
    @Header('flexusjwt') String flexusJWTString, {
    @Query('keyword') String? keyword,
  });

  @Get(path: '/overviews')
  Future<Response> getGymOverviews(
    @Header('flexusjwt') String flexusJWTString,
  );

  static GymService create() {
    final client = ChopperClient(
        //For local device    ipv4:8080
        //For virtual device  10.0.2.2:8080
        //For Web             localhost:8080
        baseUrl: AppSettings.ipv4 != "" ? Uri.parse('http://${AppSettings.ipv4}:8080') : Uri.parse('http://10.0.2.2:8080'),
        services: [
          _$GymService(),
        ],
        converter: const JsonConverter());
    return _$GymService(client);
  }
}

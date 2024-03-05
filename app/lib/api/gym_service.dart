import 'package:chopper/chopper.dart';

part 'gym_service.chopper.dart';

@ChopperApi(baseUrl: '/gyms')
abstract class GymService extends ChopperService {
  @Get(path: '/')
  Future<Response> getGymOverviews(
    @Header('flexusjwt') String flexusJWTString,
  );

  static GymService create() {
    final client = ChopperClient(
        //For local device
        //baseUrl: Uri.parse('http://ipv4:8080'),
        //For virtual device
        baseUrl: Uri.parse('http://10.0.2.2:8080'),
        //For Web
        //baseUrl: Uri.parse('http://localhost:8080'),
        services: [
          _$GymService(),
        ],
        converter: const JsonConverter());
    return _$GymService(client);
  }
}

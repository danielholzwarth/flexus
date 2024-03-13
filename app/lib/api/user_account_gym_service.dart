import 'package:chopper/chopper.dart';

part 'user_account_gym_service.chopper.dart';

@ChopperApi(baseUrl: '/user_account_gym')
abstract class UserAccountGymService extends ChopperService {
  @Post(path: '/')
  Future<Response> postUserAccountGym(
    @Header('flexusjwt') String flexusJWTString,
    @Body() Map<String, dynamic> body,
  );

  @Delete(path: '/{gymID}')
  Future<Response> deleteUserAccountGym(
    @Header('flexusjwt') String flexusJWTString,
    @Path('gymID') int gymID,
  );

  static UserAccountGymService create() {
    final client = ChopperClient(
        //For local device
        //baseUrl: Uri.parse('http://ipv4:8080'),
        //For virtual device
        baseUrl: Uri.parse('http://10.0.2.2:8080'),
        //For Web
        //baseUrl: Uri.parse('http://localhost:8080'),
        services: [
          _$UserAccountGymService(),
        ],
        converter: const JsonConverter());
    return _$UserAccountGymService(client);
  }
}

import 'package:app/resources/app_settings.dart';
import 'package:chopper/chopper.dart';

part 'user_account_gym_service.chopper.dart';

@ChopperApi(baseUrl: '/user_account_gym')
abstract class UserAccountGymService extends ChopperService {
  @Post(path: '/')
  Future<Response> postUserAccountGym(
    @Header('flexus-jwt') String flexusJWTAccess,
    @Body() Map<String, dynamic> body,
  );

  @Get(path: '/')
  Future<Response> getUserAccountGym(
    @Header('flexus-jwt') String flexusJWTAccess, {
    @Query('gymID') int? gymID,
  });

  @Delete(path: '/{gymID}')
  Future<Response> deleteUserAccountGym(
    @Header('flexus-jwt') String flexusJWTAccess,
    @Path('gymID') int gymID,
  );

  static UserAccountGymService create() {
    final client = ChopperClient(
        baseUrl: AppSettings.useIPv4 ? Uri.parse('http://${AppSettings.ipv4}:8080') : Uri.parse('http://10.0.2.2:8080'),
        services: [
          _$UserAccountGymService(),
        ],
        converter: const JsonConverter());
    return _$UserAccountGymService(client);
  }
}

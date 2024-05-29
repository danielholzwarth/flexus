import 'package:app/resources/app_settings.dart';
import 'package:chopper/chopper.dart';

part 'user_settings_service.chopper.dart';

@ChopperApi(baseUrl: '/user_settings')
abstract class UserSettingsService extends ChopperService {
  @Get(path: '/')
  Future<Response> getUserSettings(
    @Header('flexus-jwt') String flexusJWTAccess,
  );

  @Patch(path: '/')
  Future<Response> patchUserSettings(
    @Header('flexus-jwt') String flexusJWTAccess,
    @Body() Map<String, dynamic> body,
  );

  @Patch(path: '/sync')
  Future<Response> patchEntireUserSettings(
    @Header('flexus-jwt') String flexusJWTAccess,
    @Body() Map<String, dynamic> body,
  );

  static UserSettingsService create() {
    final client = ChopperClient(
        baseUrl: AppSettings.useIPv4 ? Uri.parse('http://${AppSettings.ipv4}:8080') : Uri.parse('http://10.0.2.2:8080'),
        services: [
          _$UserSettingsService(),
        ],
        converter: const JsonConverter());
    return _$UserSettingsService(client);
  }
}

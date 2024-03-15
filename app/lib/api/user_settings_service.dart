import 'package:app/resources/app_settings.dart';
import 'package:chopper/chopper.dart';

part 'user_settings_service.chopper.dart';

@ChopperApi(baseUrl: '/user_settings')
abstract class UserSettingsService extends ChopperService {
  @Get(path: '/')
  Future<Response> getUserSettings(
    @Header('flexusjwt') String flexusJWTString,
  );

  @Patch(path: '/')
  Future<Response> patchUserSettings(
    @Header('flexusjwt') String flexusJWTString,
    @Body() Map<String, dynamic> body,
  );

  static UserSettingsService create() {
    final client = ChopperClient(
        //For local device    ipv4:8080
        //For virtual device  10.0.2.2:8080
        //For Web             localhost:8080
        baseUrl: AppSettings.ipv4 != "" ? Uri.parse('http://${AppSettings.ipv4}:8080') : Uri.parse('http://10.0.2.2:8080'),
        services: [
          _$UserSettingsService(),
        ],
        converter: const JsonConverter());
    return _$UserSettingsService(client);
  }
}

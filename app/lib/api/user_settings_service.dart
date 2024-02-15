import 'package:chopper/chopper.dart';

part 'user_settings_service.chopper.dart';

@ChopperApi(baseUrl: '/user_settings')
abstract class UserSettingsService extends ChopperService {
  @Get(path: '/')
  Future<Response> getUserSettings(
    @Header('flexusjwt') String flexusJWTString,
  );

  static UserSettingsService create() {
    final client = ChopperClient(
        baseUrl: Uri.parse('http://10.0.2.2:8080'),
        //baseUrl: Uri.parse('http://localhost:8080'),
        services: [
          _$UserSettingsService(),
        ],
        converter: const JsonConverter());
    return _$UserSettingsService(client);
  }
}

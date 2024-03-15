import 'package:app/resources/app_settings.dart';
import 'package:chopper/chopper.dart';

part 'user_list_service.chopper.dart';

@ChopperApi(baseUrl: '/user_lists')
abstract class UserListService extends ChopperService {
  @Post(path: '/')
  Future<Response> postUserList(
    @Header('flexusjwt') String flexusJWTString,
    @Body() Map<String, dynamic> body,
  );

  @Get(path: '/')
  Future<Response> getHasUserList(
    @Header('flexusjwt') String flexusJWTString,
    @Body() Map<String, dynamic> body,
  );

  @Patch(path: '/')
  Future<Response> patchUserList(
    @Header('flexusjwt') String flexusJWTString,
    @Body() Map<String, dynamic> body,
  );

  @Get(path: '/{listID}')
  Future<Response> getEntireUserList(
    @Header('flexusjwt') String flexusJWTString,
    @Path('listID') int listID,
  );

  static UserListService create() {
    final client = ChopperClient(
        //For local device    ipv4:8080
        //For virtual device  10.0.2.2:8080
        //For Web             localhost:8080
        baseUrl: AppSettings.ipv4 != "" ? Uri.parse('http://${AppSettings.ipv4}:8080') : Uri.parse('http://10.0.2.2:8080'),
        services: [
          _$UserListService(),
        ],
        converter: const JsonConverter());
    return _$UserListService(client);
  }
}

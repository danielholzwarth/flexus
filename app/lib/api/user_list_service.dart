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

  static UserListService create() {
    final client = ChopperClient(
        //For local device
        //baseUrl: Uri.parse('http://ipv4:8080'),
        //For virtual device
        baseUrl: Uri.parse('http://10.0.2.2:8080'),
        //For Web
        //baseUrl: Uri.parse('http://localhost:8080'),
        services: [
          _$UserListService(),
        ],
        converter: const JsonConverter());
    return _$UserListService(client);
  }
}

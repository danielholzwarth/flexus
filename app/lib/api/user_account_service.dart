import 'package:chopper/chopper.dart';

part 'user_account_service.chopper.dart';

@ChopperApi(baseUrl: '/user_accounts')
abstract class UserAccountService extends ChopperService {
  @Get(path: '/{userAccountID}')
  Future<Response> getUserAccount(
    @Header('flexusjwt') String flexusJWTString,
    @Path('userAccountID') int userAccountID,
  );

  @Put(path: '/')
  Future<Response> putUserAccount(
    @Header('flexusjwt') String flexusJWTString,
    @Body() Map<String, dynamic> body,
  );

  static UserAccountService create() {
    final client = ChopperClient(
        baseUrl: Uri.parse('http://10.0.2.2:8080'),
        //baseUrl: Uri.parse('http://localhost:8080'),
        services: [
          _$UserAccountService(),
        ],
        converter: const JsonConverter());
    return _$UserAccountService(client);
  }
}

import 'package:chopper/chopper.dart';

part 'login_user_account_service.chopper.dart';

@ChopperApi(baseUrl: '/login_user_accounts')
abstract class LoginUserAccountService extends ChopperService {
  @Post()
  Future<Response> postUserAccount(
    @Body() Map<String, dynamic> userAccount,
  );

  @Get(path: '/availability')
  Future<Response> getUsernameAvailability(
    @Query('username') String username,
  );

  @Get(path: '/login')
  Future<Response> getLogin(
    @Body() Map<String, dynamic> loginData,
  );

  static LoginUserAccountService create() {
    final client = ChopperClient(
        baseUrl: Uri.parse('http://10.0.2.2:8080'),
        //baseUrl: Uri.parse('http://localhost:8080'),
        services: [
          _$LoginUserAccountService(),
        ],
        converter: const JsonConverter());
    return _$LoginUserAccountService(client);
  }
}

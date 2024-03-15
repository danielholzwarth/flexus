import 'package:app/resources/app_settings.dart';
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
    //TODO CHANGE TO QUERY
    @Body() Map<String, dynamic> body,
  );

  static LoginUserAccountService create() {
    final client = ChopperClient(
        //For local device    ipv4:8080
        //For virtual device  10.0.2.2:8080
        //For Web             localhost:8080
        baseUrl: AppSettings.ipv4 != "" ? Uri.parse('http://${AppSettings.ipv4}:8080') : Uri.parse('http://10.0.2.2:8080'),
        services: [
          _$LoginUserAccountService(),
        ],
        converter: const JsonConverter());
    return _$LoginUserAccountService(client);
  }
}

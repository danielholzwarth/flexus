import 'package:chopper/chopper.dart';

part 'user_account_service.chopper.dart';

@ChopperApi(baseUrl: '/useraccounts')
abstract class UserAccountService extends ChopperService {
  @Post()
  Future<Response> postUserAccount(
    @Body() Map<String, dynamic> username,
  );

  static UserAccountService create() {
    final client = ChopperClient(
        //baseUrl: Uri.parse('http://10.0.2.2:8080'),
        baseUrl: Uri.parse('http://localhost:8080'),
        services: [
          _$UserAccountService(),
        ],
        converter: const JsonConverter());
    return _$UserAccountService(client);
  }
}

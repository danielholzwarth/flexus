import 'package:app/resources/app_settings.dart';
import 'package:chopper/chopper.dart';

part 'user_account_service.chopper.dart';

@ChopperApi(baseUrl: '/user_accounts')
abstract class UserAccountService extends ChopperService {
  @Get(path: '/{userAccountID}')
  Future<Response> getUserAccount(
    @Header('flexusjwt') String flexusJWTString,
    @Path('userAccountID') int userAccountID,
  );

  @Patch(path: '/')
  Future<Response> patchUserAccount(
    @Header('flexusjwt') String flexusJWTString,
    @Body() Map<String, dynamic> body,
  );

  @Delete(path: '/')
  Future<Response> deleteUserAccount(
    @Header('flexusjwt') String flexusJWTString,
  );

  @Get(path: '/')
  Future<Response> getUserAccounts(
    @Header('flexusjwt') String flexusJWTString, {
    @Query('keyword') String? keyword,
    @Query('isFriend') bool? isFriend,
    @Query('hasRequest') bool? hasRequest,
  });

  @Get(path: '/gym/{gymID}')
  Future<Response> getUserAccountsGym(
    @Header('flexusjwt') String flexusJWTString,
    @Path('gymID') int gymID, {
    @Query('isWorkingOut') bool? isWorkingOut,
  });

  @Patch(path: '/sync')
  Future<Response> patchEntireUserAccount(
    @Header('flexusjwt') String flexusJWTString,
    @Body() Map<String, dynamic> body,
  );

  static UserAccountService create() {
    final client = ChopperClient(
        baseUrl: AppSettings.useIPv4 ? Uri.parse('http://${AppSettings.ipv4}:8080') : Uri.parse('http://10.0.2.2:8080'),
        services: [
          _$UserAccountService(),
        ],
        converter: const JsonConverter());
    return _$UserAccountService(client);
  }
}

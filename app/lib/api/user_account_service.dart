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
    @Query('gymID') int? gymID,
    @Query('isWorkingOut') bool? isWorkingOut,
  });

  static UserAccountService create() {
    final client = ChopperClient(
        //For local device
        //baseUrl: Uri.parse('http://ipv4:8080'),
        //For virtual device
        baseUrl: Uri.parse('http://10.0.2.2:8080'),
        //For Web
        //baseUrl: Uri.parse('http://localhost:8080'),
        services: [
          _$UserAccountService(),
        ],
        converter: const JsonConverter());
    return _$UserAccountService(client);
  }
}

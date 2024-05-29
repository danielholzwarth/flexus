import 'package:app/resources/app_settings.dart';
import 'package:chopper/chopper.dart';

part 'friendship_service.chopper.dart';

@ChopperApi(baseUrl: '/friendships')
abstract class FriendshipService extends ChopperService {
  @Post(path: '/{userAccountID}')
  Future<Response> postFriendship(
    @Header('flexus-jwt') String flexusJWTAccess,
    @Path('userAccountID') int userAccountID,
  );

  @Get(path: '/{userAccountID}')
  Future<Response> getFriendshipFromUserID(
    @Header('flexus-jwt') String flexusJWTAccess,
    @Path('userAccountID') int userAccountID,
  );

  @Patch(path: '/{userAccountID}')
  Future<Response> patchFriendship(
    @Header('flexus-jwt') String flexusJWTAccess,
    @Path('userAccountID') int userAccountID,
    @Body() Map<String, dynamic> body,
  );

  @Delete(path: '/{userAccountID}')
  Future<Response> deleteFriendship(
    @Header('flexus-jwt') String flexusJWTAccess,
    @Path('userAccountID') int userAccountID,
  );

  static FriendshipService create() {
    final client = ChopperClient(
        baseUrl: AppSettings.useIPv4 ? Uri.parse('http://${AppSettings.ipv4}:8080') : Uri.parse('http://10.0.2.2:8080'),
        services: [
          _$FriendshipService(),
        ],
        converter: const JsonConverter());
    return _$FriendshipService(client);
  }
}

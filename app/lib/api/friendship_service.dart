import 'package:app/resources/app_settings.dart';
import 'package:chopper/chopper.dart';

part 'friendship_service.chopper.dart';

@ChopperApi(baseUrl: '/friendships')
abstract class FriendshipService extends ChopperService {
  @Post(path: '/{userAccountID}')
  Future<Response> postFriendship(
    @Header('flexusjwt') String flexusJWTString,
    @Path('userAccountID') int userAccountID,
  );

  @Get(path: '/{userAccountID}')
  Future<Response> getFriendship(
    @Header('flexusjwt') String flexusJWTString,
    @Path('userAccountID') int userAccountID,
  );

  @Patch(path: '/{userAccountID}')
  Future<Response> patchFriendship(
    @Header('flexusjwt') String flexusJWTString,
    @Path('userAccountID') int userAccountID,
    @Body() Map<String, dynamic> body,
  );

  @Delete(path: '/{userAccountID}')
  Future<Response> deleteFriendship(
    @Header('flexusjwt') String flexusJWTString,
    @Path('userAccountID') int userAccountID,
  );

  static FriendshipService create() {
    final client = ChopperClient(
        //For local device    ipv4:8080
        //For virtual device  10.0.2.2:8080
        //For Web             localhost:8080
        baseUrl: AppSettings.ipv4 != "" ? Uri.parse('http://${AppSettings.ipv4}:8080') : Uri.parse('http://10.0.2.2:8080'),
        services: [
          _$FriendshipService(),
        ],
        converter: const JsonConverter());
    return _$FriendshipService(client);
  }
}

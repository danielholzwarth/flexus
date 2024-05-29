import 'package:app/resources/app_settings.dart';
import 'package:chopper/chopper.dart';

part 'notification_service.chopper.dart';

@ChopperApi(baseUrl: '/notifications')
abstract class NotificationService extends ChopperService {
  @Get(path: '/')
  Future<Response> getNewWorkoutNotifications(
    @Header('flexus-jwt') String flexusJWTAccess,
  );

  static NotificationService create() {
    final client = ChopperClient(
        baseUrl: AppSettings.useIPv4 ? Uri.parse('http://${AppSettings.ipv4}:8080') : Uri.parse('http://10.0.2.2:8080'),
        services: [
          _$NotificationService(),
        ],
        converter: const JsonConverter());
    return _$NotificationService(client);
  }
}

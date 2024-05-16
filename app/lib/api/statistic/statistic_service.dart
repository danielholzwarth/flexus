import 'package:app/resources/app_settings.dart';
import 'package:chopper/chopper.dart';

part 'statistic_service.chopper.dart';

@ChopperApi(baseUrl: '/statistics')
abstract class StatisticService extends ChopperService {
  @Get(path: '/total-moved-weight')
  Future<Response> getTotalMovedWeight(
    @Header('flexusjwt') String flexusJWTString,
    @Query('period') int period,
  );

  @Get(path: '/total-reps')
  Future<Response> getTotalReps(
    @Header('flexusjwt') String flexusJWTString,
    @Query('period') int period,
  );

  @Get(path: '/workout-days')
  Future<Response> getWorkoutDays(
    @Header('flexusjwt') String flexusJWTString,
    @Query('period') int period,
  );

  @Get(path: '/workout-duration')
  Future<Response> getWorkoutDuration(
    @Header('flexusjwt') String flexusJWTString,
    @Query('period') int period,
  );

  static StatisticService create() {
    final client = ChopperClient(
        baseUrl: AppSettings.useIPv4 ? Uri.parse('http://${AppSettings.ipv4}:8080') : Uri.parse('http://10.0.2.2:8080'),
        services: [
          _$StatisticService(),
        ],
        converter: const JsonConverter());
    return _$StatisticService(client);
  }
}

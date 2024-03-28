import 'package:app/resources/app_settings.dart';
import 'package:chopper/chopper.dart';

part 'exercise_service.chopper.dart';

@ChopperApi(baseUrl: '/exercises')
abstract class ExerciseService extends ChopperService {
  // @Post(path: '/')
  // Future<Response> postExercise(
  //   @Header('flexusjwt') String flexusJWTString,
  //   @Body() Map<String, dynamic> exercise,
  // );

  @Get(path: '/')
  Future<Response> getExercises(
    @Header('flexusjwt') String flexusJWTString,
  );

  static ExerciseService create() {
    final client = ChopperClient(
        //For local device    ipv4:8080
        //For virtual device  10.0.2.2:8080
        //For Web             localhost:8080
        baseUrl: AppSettings.ipv4 != "" ? Uri.parse('http://${AppSettings.ipv4}:8080') : Uri.parse('http://10.0.2.2:8080'),
        services: [
          _$ExerciseService(),
        ],
        converter: const JsonConverter());
    return _$ExerciseService(client);
  }
}

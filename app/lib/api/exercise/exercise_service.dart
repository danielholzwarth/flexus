import 'package:app/resources/app_settings.dart';
import 'package:chopper/chopper.dart';

part 'exercise_service.chopper.dart';

@ChopperApi(baseUrl: '/exercises')
abstract class ExerciseService extends ChopperService {
  @Post(path: '/')
  Future<Response> postExercise(
    @Header('flexusjwt') String flexusJWTString,
    @Body() Map<String, dynamic> exercise,
  );

  @Get(path: '/')
  Future<Response> getExercises(
    @Header('flexusjwt') String flexusJWTString,
  );

  @Get(path: '/{splitID}')
  Future<Response> getExercisesFromSplitID(
    @Header('flexusjwt') String flexusJWTString,
    @Path('splitID') int splitID,
  );

  static ExerciseService create() {
    final client = ChopperClient(
        baseUrl: AppSettings.useIPv4 ? Uri.parse('http://${AppSettings.ipv4}:8080') : Uri.parse('http://10.0.2.2:8080'),
        services: [
          _$ExerciseService(),
        ],
        converter: const JsonConverter());
    return _$ExerciseService(client);
  }
}

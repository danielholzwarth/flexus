import 'package:chopper/chopper.dart';

part 'workout_service.chopper.dart';

@ChopperApi(baseUrl: '/workouts')
abstract class WorkoutService extends ChopperService {
  @Get(path: '/')
  Future<Response> getWorkouts(
    @Header('flexusjwt') String flexusJWTString,
  );

  @Get(path: '/search')
  Future<Response> getSearchedWorkouts(
    @Header('flexusjwt') String flexusJWTString,
    @Query('keyword') String keyWord,
  );

  @Get(path: '/archive')
  Future<Response> getArchivedWorkouts(
    @Header('flexusjwt') String flexusJWTString,
  );

  @Get(path: '/archive/search')
  Future<Response> getSearchedArchivedWorkouts(
    @Header('flexusjwt') String flexusJWTString,
    @Query('keyword') String keyWord,
  );

  @Get(path: '/{workoutID}')
  Future<Response> getWorkoutDetails(
    @Header('flexusjwt') String flexusJWTString,
    @Path('workoutID') int workoutID,
  );

  static WorkoutService create() {
    final client = ChopperClient(
        baseUrl: Uri.parse('http://10.0.2.2:8080'),
        //baseUrl: Uri.parse('http://localhost:8080'),
        services: [
          _$WorkoutService(),
        ],
        converter: const JsonConverter());
    return _$WorkoutService(client);
  }
}

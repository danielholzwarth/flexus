import 'package:chopper/chopper.dart';

part 'workout_service.chopper.dart';

@ChopperApi(baseUrl: '/workouts')
abstract class WorkoutService extends ChopperService {
  @Get(path: '/')
  Future<Response> getWorkoutOverviews(
    @Header('flexusjwt') String flexusJWTString,
  );

  @Patch(path: '/{workoutID}')
  Future<Response> patchWorkout(
    @Header('flexusjwt') String flexusJWTString,
    @Path('workoutID') int workoutID,
    @Body() Map<String, dynamic> body,
  );

  @Delete(path: '/{workoutID}')
  Future<Response> deleteWorkout(
    @Header('flexusjwt') String flexusJWTString,
    @Path('workoutID') int workoutID,
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

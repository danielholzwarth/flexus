import 'package:app/resources/app_settings.dart';
import 'package:chopper/chopper.dart';

part 'workout_service.chopper.dart';

@ChopperApi(baseUrl: '/workouts')
abstract class WorkoutService extends ChopperService {
  @Post()
  Future<Response> postWorkout(
    @Header('flexusjwt') String flexusJWTString,
    @Body() Map<String, dynamic> workout,
  );

  @Get(path: '/')
  Future<Response> getWorkoutOverviews(
    @Header('flexusjwt') String flexusJWTString,
  );

  @Get(path: '/{workoutID}')
  Future<Response> getWorkoutFromID(
    @Header('flexusjwt') String flexusJWTString,
    @Path('workoutID') int workoutID,
  );

  @Patch(path: '/{workoutID}')
  Future<Response> patchWorkout(
    @Header('flexusjwt') String flexusJWTString,
    @Path('workoutID') int workoutID,
    @Body() Map<String, dynamic> body,
  );

  @Patch(path: '/start/{workoutID}')
  Future<Response> patchStartWorkout(
    @Header('flexusjwt') String flexusJWTString,
    @Path('workoutID') int workoutID,
    @Body() Map<String, dynamic> body,
  );

  @Patch(path: '/finish')
  Future<Response> patchFinishWorkout(
    @Header('flexusjwt') String flexusJWTString,
    @Body() Map<String, dynamic> body,
  );

  @Delete(path: '/{workoutID}')
  Future<Response> deleteWorkout(
    @Header('flexusjwt') String flexusJWTString,
    @Path('workoutID') int workoutID,
  );

  @Get(path: '/details/{workoutID}')
  Future<Response> getWorkoutDetailsFromWorkoutID(
    @Header('flexusjwt') String flexusJWTString,
    @Path('workoutID') int workoutID,
  );

  @Patch(path: '/sync')
  Future<Response> patchEntireWorkouts(
    @Header('flexusjwt') String flexusJWTString,
    @Body() Map<String, dynamic> body,
  );

  static WorkoutService create() {
    final client = ChopperClient(
        baseUrl: AppSettings.useIPv4 ? Uri.parse('http://${AppSettings.ipv4}:8080') : Uri.parse('http://10.0.2.2:8080'),
        services: [
          _$WorkoutService(),
        ],
        converter: const JsonConverter());
    return _$WorkoutService(client);
  }
}

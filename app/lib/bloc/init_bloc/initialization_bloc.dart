import 'package:app/resources/app_settings.dart';
import 'package:app/resources/background_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:permission_handler/permission_handler.dart';

part 'initialization_event.dart';
part 'initialization_state.dart';

class InitializationBloc extends Bloc<InitializationEvent, InitializationState> {
  final userBox = Hive.box("userBox");

  InitializationBloc() : super(InitializationInitial()) {
    on<InitializeApp>(_onInitApp);
  }

  void _onInitApp(InitializeApp event, Emitter<InitializationState> emit) async {
    emit(Initializing());

    try {
      final flexusjwt = userBox.get("flexusjwt");
      AppSettings.isTokenExpired = JwtDecoder.isExpired(flexusjwt);

      WidgetsFlutterBinding.ensureInitialized();
      await Permission.notification.isDenied.then((value) {
        if (value) {
          Permission.notification.request();
        }
      });
      await initializeService();

      FlutterBackgroundService().invoke('setAsBackground');

      emit(Initialized());
    } catch (e) {
      emit(InitializingError(error: e.toString()));
    }
  }
}

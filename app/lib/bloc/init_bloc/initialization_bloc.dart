import 'package:app/resources/background_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:permission_handler/permission_handler.dart';

part 'initialization_event.dart';
part 'initialization_state.dart';

class InitializationBloc extends Bloc<InitializationEvent, InitializationState> {
  final userBox = Hive.box('userBox');

  InitializationBloc() : super(InitializationInitial()) {
    on<InitializeApp>(_onInitApp);
  }

  void _onInitApp(InitializeApp event, Emitter<InitializationState> emit) async {
    emit(Initializing());

    try {
      WidgetsFlutterBinding.ensureInitialized();
      await Permission.notification.isDenied.then((value) async {
        if (value) {
          PermissionStatus permissionStatus = await Permission.notification.request();
          if (permissionStatus.isGranted) {
            FlutterBackgroundService().invoke('setAsForeground');

            await initializeService();
          }
        }
      });

      emit(Initialized());
    } catch (e) {
      emit(InitializingError(error: e.toString()));
    }
  }
}

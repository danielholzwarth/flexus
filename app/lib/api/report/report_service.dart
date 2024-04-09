import 'package:app/resources/app_settings.dart';
import 'package:chopper/chopper.dart';

part 'report_service.chopper.dart';

@ChopperApi(baseUrl: '/reports')
abstract class ReportService extends ChopperService {
  @Post()
  Future<Response> postReport(
    @Header('flexusjwt') String flexusJWTString,
    @Body() Map<String, dynamic> body,
  );

  static ReportService create() {
    final client = ChopperClient(
        baseUrl: AppSettings.useIPv4 ? Uri.parse('http://${AppSettings.ipv4}:8080') : Uri.parse('http://10.0.2.2:8080'),
        services: [
          _$ReportService(),
        ],
        converter: const JsonConverter());
    return _$ReportService(client);
  }
}

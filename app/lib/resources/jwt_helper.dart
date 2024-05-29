import 'package:app/resources/app_settings.dart';
import 'package:chopper/chopper.dart';
import 'package:hive/hive.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class JWTHelper {
  static String? getActiveJWT() {
    Box userBox = Hive.box('userBox');

    String? jwt = userBox.get("flexus-jwt-access");
    if (jwt != null) {
      bool isExpired = isTokenExpired(jwt);
      if (!isExpired) {
        return jwt;
      }
    }

    jwt = userBox.get("flexus-jwt-refresh");
    if (jwt != null) {
      bool isExpired = isTokenExpired(jwt);
      if (!isExpired) {
        return jwt;
      }
    }

    AppSettings.isTokenExpired = true;
    return null;
  }

  static bool isTokenExpired(String token) {
    DateTime expiryDate = JwtDecoder.getExpirationDate(token);
    DateTime currentDate = DateTime.now();
    DateTime bufferTime = currentDate.add(const Duration(seconds: 30));
    return expiryDate.isBefore(bufferTime);
  }

  static void saveJWTsFromResponse(Response<dynamic> response) {
    Box userBox = Hive.box('userBox');

    final jwtAccess = response.headers["flexus-jwt-access"];
    if (jwtAccess != null) {
      userBox.put("flexus-jwt-access", jwtAccess);
    }

    final jwtRefresh = response.headers["flexus-jwt-refresh"];
    if (jwtRefresh != null) {
      userBox.put("flexus-jwt-refresh", jwtRefresh);
    }

    if (jwtAccess != null || jwtRefresh != null) {
      AppSettings.isTokenExpired = false;
    }
  }
}

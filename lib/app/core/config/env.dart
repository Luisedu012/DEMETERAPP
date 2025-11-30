import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env')
abstract class Env {
  @EnviedField(varName: 'API_BASE_URL')
  static const String apiBaseUrl = _Env.apiBaseUrl;

  @EnviedField(varName: 'API_TIMEOUT')
  static const int apiTimeout = _Env.apiTimeout;

  @EnviedField(varName: 'APP_NAME')
  static const String appName = _Env.appName;

  @EnviedField(varName: 'APP_VERSION')
  static const String appVersion = _Env.appVersion;

  @EnviedField(varName: 'ENVIRONMENT')
  static const String environment = _Env.environment;

  @EnviedField(varName: 'MAX_IMAGE_SIZE_MB')
  static const int maxImageSizeMb = _Env.maxImageSizeMb;

  @EnviedField(varName: 'CACHE_DURATION_HOURS')
  static const int cacheDurationHours = _Env.cacheDurationHours;

  @EnviedField(varName: 'DEBUG_MODE')
  static const bool debugMode = _Env.debugMode;
}

// lib/core/network/http_service.dart
import 'package:dio/dio.dart';

import '../constants/api_constants.dart';
import '../error/exceptions.dart';
import '../utils/app_local_storage.dart';
import '../utils/app_preferences_keys.dart';

enum ApiType { MainAPI, SocketAPI, UploadAPI } // Defined in api_constants.dart in full project

enum Environment { Production, Development, Local } // Defined in api_constants.dart in full project

class HttpService {
  static final Map<ApiType, Dio> _dioInstances = {};
  static Environment defaultEnvironment = Environment.Development;

  static Dio getInstance({ApiType apiType = ApiType.MainAPI, Environment? environment}) {
    Environment env = environment ?? defaultEnvironment;
    String baseUrl = ApiConstants.baseUrls[env]?[apiType] ?? ApiConstants.baseUrls[env]![apiType]!;

    if (!_dioInstances.containsKey(apiType)) {
      _dioInstances[apiType] = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );
      _dioInstances[apiType]!.interceptors.add(InterceptorsWrapper(
            onRequest: (options, handler) async {
              final credential = await AppLocalStorage.getLocalStorage(key: AppPreferencesKeys.credential);
              if (credential != null && credential['access_token'] != null && credential['access_token'] != "") {
                options.headers['Authorization'] = 'Bearer ${credential['access_token']}';
              }
              options.headers['Content-Type'] = 'application/json';
              return handler.next(options);
            },
            onError: (DioException e, handler) async {
              // Refresh Token Logic (simplified)
              if (e.response?.statusCode == 401 && e.requestOptions.path != '/auth/refresh-token') {
                final String? refreshToken = (await AppLocalStorage.getLocalStorage(key: AppPreferencesKeys.credential))?['refresh_token'];
                if (refreshToken != null && refreshToken.isNotEmpty) {
                  // Simulate refresh token call
                  try {
                    // For a real app, call your actual AuthService().refreshToken(refreshToken)
                    final newAccessToken = 'new_access_token';
                    await AppLocalStorage.setLocalStorage(key: AppPreferencesKeys.credential, object: {"access_token": newAccessToken, "refresh_token": refreshToken});
                    e.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
                    final newResponse = await _dioInstances[apiType]!.fetch(e.requestOptions);
                    return handler.resolve(newResponse);
                  } on DioException catch (refreshError) {
                    // Handle refresh failure / logout
                    return handler.reject(refreshError);
                  }
                }
              }
              // Convert DioException to custom exceptions
              if (e.type == DioExceptionType.badResponse) {
                return handler.reject(ServerException(statusCode: e.response?.statusCode, message: e.response?.data is Map ? e.response?.data['message'] : e.message));
              } else if (e.type == DioExceptionType.connectionError || e.type == DioExceptionType.connectionTimeout) {
                return handler.reject(NetworkException(message: e.message ?? 'No internet connection.'));
              } else {
                return handler.reject(e);
              }
            },
          ));
    }
    return _dioInstances[apiType]!;
  }

  static void setEnvironment(Environment environment) {
    defaultEnvironment = environment;
    _dioInstances.clear();
  }
}

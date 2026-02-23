import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provide the local backend or remote one.
// For physical devices on the same Wi-Fi, change this to your PC's local IP (e.g. 192.168.1.x:8000)
// For Android emulator it uses 10.0.2.2.
const String baseUrl = 'https://qush-uyi-platform-production.up.railway.app';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));

  // Middleware for intercepting logic (Token inject, logging, etc.)
  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) {
      // Logic for bearer tokens can be added here
      return handler.next(options);
    },
    onError: (DioException e, handler) {
      print('HTTP ERROR: \${e.message}');
      return handler.next(e);
    },
  ));

  return dio;
});

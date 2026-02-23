import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import 'package:dio/dio.dart';

final paymentRepositoryProvider = Provider((ref) {
  return PaymentRepository(ref.watch(dioProvider));
});

class PaymentRepository {
  final Dio _dio;
  PaymentRepository(this._dio);

  Future<bool> processEscrowPayment({
    required String birdId,
    required double amount,
    required String buyerId,
  }) async {
    try {
      final response = await _dio.post(
        '/pay/process',
        data: {
          'bird_id': birdId,
          'amount': amount,
          'payment_method': 'card', // Mock
          'buyer_id': buyerId,
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}

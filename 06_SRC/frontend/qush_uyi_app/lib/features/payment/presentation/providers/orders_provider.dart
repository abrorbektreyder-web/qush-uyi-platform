import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dioProvider = Provider<Dio>((ref) {
  return Dio(BaseOptions(baseUrl: 'http://127.0.0.1:8000'));
});

final ordersProvider =
    FutureProvider.autoDispose<List<OrderModel>>((ref) async {
  final dio = ref.read(dioProvider);
  final response = await dio.get('/user/orders/mock_buyer_id');
  final List items = response.data['orders'];
  return items.map((e) => OrderModel.fromJson(e)).toList();
});

class OrdersRepository {
  final Dio _dio;
  OrdersRepository(this._dio);

  Future<bool> releaseMuzlatilganPul(String orderId) async {
    try {
      final response = await _dio.post('/pay/release/$orderId');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> nizoYuborish(String orderId, String reason) async {
    try {
      final response = await _dio.post('/pay/dispute/$orderId', data: {
        'reason': reason,
      });
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}

final ordersRepositoryProvider =
    Provider((ref) => OrdersRepository(ref.read(dioProvider)));

class OrderModel {
  final String orderId;
  final String species;
  final double price;
  final String status;
  final String imageUrl;

  OrderModel({
    required this.orderId,
    required this.species,
    required this.price,
    required this.status,
    required this.imageUrl,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    String img = '';
    if (json['media'] != null && (json['media'] as List).isNotEmpty) {
      img = json['media'][0]['url'];
    }
    return OrderModel(
      orderId: json['order_id'],
      species: json['species'] ?? "Noma'lum",
      price: (json['price'] as num).toDouble(),
      status: json['status'],
      imageUrl: img,
    );
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../data/shop_item_model.dart';
import 'package:dio/dio.dart';

final shopRepositoryProvider = Provider((ref) {
  return ShopRepository(ref.watch(dioProvider));
});

final shopItemsProvider = FutureProvider<List<ShopItemModel>>((ref) async {
  final repo = ref.watch(shopRepositoryProvider);
  return repo.fetchShopItems();
});

class ShopRepository {
  final Dio _dio;
  ShopRepository(this._dio);

  Future<List<ShopItemModel>> fetchShopItems() async {
    try {
      final response = await _dio.get('/shop/items');
      if (response.statusCode == 200) {
        final List data = response.data;
        return data.map((json) => ShopItemModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Dokon maxsulotlarini yuklashda xato: $e');
    }
  }

  Future<bool> buyItem(String itemId, int quantity, String userId) async {
    try {
      final response = await _dio.post(
        '/shop/buy/$itemId',
        data: FormData.fromMap({
          'quantity': quantity,
          'user_id': userId,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}

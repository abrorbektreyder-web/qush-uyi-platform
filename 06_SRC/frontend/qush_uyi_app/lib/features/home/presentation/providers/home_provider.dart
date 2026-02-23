import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../data/bird_model.dart';
import 'package:dio/dio.dart';

final birdsRepositoryProvider = Provider((ref) {
  return BirdsRepository(ref.watch(dioProvider));
});

class BirdsState {
  final List<BirdModel> birds;
  final bool isLoadingMore;
  final bool hasMore;
  final int offset;

  BirdsState({
    this.birds = const [],
    this.isLoadingMore = false,
    this.hasMore = true,
    this.offset = 0,
  });

  BirdsState copyWith({
    List<BirdModel>? birds,
    bool? isLoadingMore,
    bool? hasMore,
    int? offset,
  }) {
    return BirdsState(
      birds: birds ?? this.birds,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      offset: offset ?? this.offset,
    );
  }
}

class BirdsNotifier extends StateNotifier<AsyncValue<BirdsState>> {
  final BirdsRepository repo;
  static const int limit = 20;

  BirdsNotifier(this.repo) : super(const AsyncValue.loading()) {
    fetchInitial();
  }

  Future<void> fetchInitial() async {
    try {
      state = const AsyncValue.loading();
      final result = await repo.fetchBirds(limit: limit, offset: 0);
      state = AsyncValue.data(BirdsState(
        birds: result.items,
        isLoadingMore: false,
        hasMore: result.items.length == limit,
        offset: limit,
      ));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> loadMore() async {
    final currentState = state.value;
    if (currentState == null ||
        currentState.isLoadingMore ||
        !currentState.hasMore) return;

    state = AsyncValue.data(currentState.copyWith(isLoadingMore: true));

    try {
      final result =
          await repo.fetchBirds(limit: limit, offset: currentState.offset);
      final newBirds = [...currentState.birds, ...result.items];

      state = AsyncValue.data(currentState.copyWith(
        birds: newBirds,
        isLoadingMore: false,
        hasMore: result.items.length == limit,
        offset: currentState.offset + limit,
      ));
    } catch (e, st) {
      state = AsyncValue.data(currentState.copyWith(isLoadingMore: false));
    }
  }
}

final birdsNotifierProvider =
    StateNotifierProvider<BirdsNotifier, AsyncValue<BirdsState>>((ref) {
  return BirdsNotifier(ref.watch(birdsRepositoryProvider));
});

class PaginatedBirdsResult {
  final List<BirdModel> items;
  final int total;
  PaginatedBirdsResult({required this.items, required this.total});
}

class BirdsRepository {
  final Dio _dio;

  BirdsRepository(this._dio);

  Future<PaginatedBirdsResult> fetchBirds(
      {int limit = 20, int offset = 0}) async {
    try {
      final response = await _dio.get('/birds', queryParameters: {
        'limit': limit,
        'offset': offset,
      });
      if (response.statusCode == 200) {
        final List data = response.data['items'];
        final total = response.data['total'] as int;
        return PaginatedBirdsResult(
          items: data.map((json) => BirdModel.fromJson(json)).toList(),
          total: total,
        );
      }
      return PaginatedBirdsResult(items: [], total: 0);
    } catch (e) {
      throw Exception('Qushlarni yuklashda xatolik: $e');
    }
  }
}

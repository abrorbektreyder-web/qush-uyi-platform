import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'providers/shop_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/glass_container.dart';
import '../data/shop_item_model.dart';
import 'package:go_router/go_router.dart';

class ShopScreen extends ConsumerWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncItems = ref.watch(shopItemsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Official Shop'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: asyncItems.when(
        data: (items) => items.isEmpty
            ? const Center(
                child: Text("Hozircha mol yo'q",
                    style: TextStyle(color: Colors.white)))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  final formattedPrice = '${item.price.toInt()} UZS'
                      .replaceAllMapped(
                          RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ' ');

                  return _ShopItemCard(
                      item: item, formattedPrice: formattedPrice);
                },
              ),
        loading: () => _buildSkeleton(),
        error: (err, stack) => Center(
            child:
                Text('Xato: $err', style: const TextStyle(color: Colors.red))),
      ),
    );
  }

  Widget _buildSkeleton() {
    return Skeletonizer(
      enabled: true,
      containersColor: AppColors.surface,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 4,
        itemBuilder: (context, index) {
          return GlassContainer(
            margin: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                Container(width: 80, height: 80, color: Colors.grey[800]),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Maxsulot nomi uzuni',
                          style: TextStyle(fontSize: 16)),
                      SizedBox(height: 8),
                      Text('100 000 UZS'),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ShopItemCard extends ConsumerStatefulWidget {
  final ShopItemModel item;
  final String formattedPrice;

  const _ShopItemCard({required this.item, required this.formattedPrice});

  @override
  ConsumerState<_ShopItemCard> createState() => _ShopItemCardState();
}

class _ShopItemCardState extends ConsumerState<_ShopItemCard> {
  bool _isBuying = false;

  void _handleBuy() async {
    setState(() => _isBuying = true);
    final success = await ref
        .read(shopRepositoryProvider)
        .buyItem(widget.item.id, 1, 'mock_buyer_id');
    setState(() => _isBuying = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              "Buyurtma qabul qilindi, Adminga Telegram orqali xabar ketti!"),
          backgroundColor: AppColors.primary,
          duration: Duration(seconds: 4),
        ),
      );
      // Refresh list to update stock
      ref.invalidate(shopItemsProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Icon Placeholder
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              widget.item.category.toLowerCase() == 'yem'
                  ? Icons.grass
                  : widget.item.category.toLowerCase() == 'dori'
                      ? Icons.medical_services
                      : Icons.inventory_2,
              size: 40,
              color: AppColors.primary.withOpacity(0.5),
            ),
          ),
          const SizedBox(width: 16),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.item.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white)),
                const SizedBox(height: 4),
                Text(widget.item.description ?? '',
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 8),
                Text(widget.formattedPrice,
                    style: const TextStyle(
                        color: AppColors.primaryLight,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
              ],
            ),
          ),
          // Buy Trigger
          Column(
            children: [
              Text('${widget.item.stockQuantity} ta bor',
                  style: TextStyle(
                      color: widget.item.stockQuantity < 10
                          ? AppColors.error
                          : AppColors.textSecondary,
                      fontSize: 12)),
              const SizedBox(height: 8),
              _isBuying
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                          color: AppColors.primary, strokeWidth: 2))
                  : ElevatedButton(
                      onPressed:
                          widget.item.stockQuantity > 0 ? _handleBuy : null,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                      ),
                      child: const Text('Olish'),
                    ),
            ],
          )
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1);
  }
}

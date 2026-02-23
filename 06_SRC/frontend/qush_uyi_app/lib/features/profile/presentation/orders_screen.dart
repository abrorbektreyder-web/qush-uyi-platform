import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../../payment/presentation/providers/orders_provider.dart';
import 'package:go_router/go_router.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(ordersProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mening Buyurtmalarim'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ordersAsync.when(
        data: (orders) {
          if (orders.isEmpty) {
            return const Center(
              child: Text(
                "Sizda hali xaridlar yo'q.",
                style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              return _OrderCard(order: orders[index]);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Text('Xatolik: $err',
              style: const TextStyle(color: AppColors.error)),
        ),
      ),
    );
  }
}

class _OrderCard extends ConsumerWidget {
  final OrderModel order;

  const _OrderCard({required this.order});

  Future<void> _handleRelease(BuildContext context, WidgetRef ref) async {
    final bool? confirm = await showDialog(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Qushni qabul qildingizmi?',
            style: TextStyle(color: Colors.white)),
        content: const Text(
            "Tasdiqlasangiz, muzlatilgan pul sotuvchi hisobiga o'tkaziladi. Bu amalni orqaga qaytarib bo'lmaydi.",
            style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: const Text("Bekor qilish",
                  style: TextStyle(color: Colors.white54))),
          TextButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Ha, qabul qildim',
                style: TextStyle(
                    color: AppColors.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await ref
          .read(ordersRepositoryProvider)
          .releaseMuzlatilganPul(order.orderId);
      if (success) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Sotuvchiga pul uzatildi!')));
        }
        ref.invalidate(ordersProvider);
      }
    }
  }

  Future<void> _handleDispute(BuildContext context, WidgetRef ref) async {
    final reasonController = TextEditingController();
    final bool? confirm = await showDialog(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Muammo xabarini yozing',
            style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: reasonController,
          style: const TextStyle(color: Colors.white),
          maxLines: 3,
          decoration: InputDecoration(
            hintText: "Masalan: Qush kasal ekan / Yetib kelmadi...",
            hintStyle: const TextStyle(color: Colors.white30),
            filled: true,
            fillColor: Colors.black26,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: const Text("Bekor qilish",
                  style: TextStyle(color: Colors.white54))),
          TextButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Yuborish',
                style: TextStyle(
                    color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true && reasonController.text.isNotEmpty) {
      final success = await ref
          .read(ordersRepositoryProvider)
          .nizoYuborish(order.orderId, reasonController.text);
      if (success) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Nizo ochildi! Admin tez orada aloqaga chiqadi.')));
        }
        ref.invalidate(ordersProvider);
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Color statusColor = Colors.white;
    String statusStr = order.status;
    if (order.status == 'payment_held') {
      statusColor = Colors.orangeAccent;
      statusStr = "Pul Muzlatilgan";
    } else if (order.status == 'completed') {
      statusColor = AppColors.primary;
      statusStr = "Xarid Yakunlangan";
    } else if (order.status == 'disputed') {
      statusColor = Colors.redAccent;
      statusStr = "Nizo (Dispute)";
    }

    final formattedPrice = '${order.price.toInt()} UZS'
        .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ' ');

    return GlassContainer(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.black26,
                  image: order.imageUrl.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(
                              'http://127.0.0.1:8000${order.imageUrl}'),
                          fit: BoxFit.cover)
                      : null,
                ),
                child: order.imageUrl.isEmpty
                    ? const Icon(Icons.pets, color: Colors.white30)
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(order.species,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.white)),
                    const SizedBox(height: 4),
                    Text(formattedPrice,
                        style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Status: $statusStr",
                  style: TextStyle(
                      color: statusColor, fontWeight: FontWeight.bold)),
            ],
          ),
          if (order.status == 'payment_held') ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _handleRelease(context, ref),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary),
                    child: const Text("Qabul qildim",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _handleDispute(context, ref),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent.withOpacity(0.8)),
                    child: const Text("Muammo bor",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13)),
                  ),
                ),
              ],
            )
          ]
        ],
      ),
    );
  }
}

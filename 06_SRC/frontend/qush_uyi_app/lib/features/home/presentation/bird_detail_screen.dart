import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../data/bird_model.dart';
import '../../payment/presentation/providers/payment_provider.dart';

class BirdDetailScreen extends ConsumerStatefulWidget {
  final BirdModel bird;

  const BirdDetailScreen({super.key, required this.bird});

  @override
  ConsumerState<BirdDetailScreen> createState() => _BirdDetailScreenState();
}

class _BirdDetailScreenState extends ConsumerState<BirdDetailScreen> {
  bool _isProcessing = false;

  void _handleEscrow() async {
    setState(() => _isProcessing = true);
    final repo = ref.read(paymentRepositoryProvider);
    final success = await repo.processEscrowPayment(
      birdId: widget.bird.id,
      amount: widget.bird.price,
      buyerId: 'mock_buyer_id',
    );
    setState(() => _isProcessing = false);

    if (success && mounted) {
      showDialog(
        context: context,
        builder: (c) => AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text("Xavfsiz To'lov (Escrow)",
              style: TextStyle(color: Colors.white)),
          content: const Text(
              "Pullaringiz muvaffaqiyatli muzlatildi. Sotuvchi endi sizga maxsulotni yetkazib berishi kerak. Admin monitoringda.",
              style: TextStyle(color: Colors.white70)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(c),
              child: const Text('Tushunarli',
                  style: TextStyle(color: AppColors.primary)),
            )
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Xatolik yuz berdi. Yoki ushbu qush band qilingan.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String imageUrl = widget.bird.media.isNotEmpty
        ? 'http://127.0.0.1:8000${widget.bird.media.first.url}'
        : '';
    final formattedPrice = '${widget.bird.price.toInt()} UZS'
        .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ' ');

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            backgroundColor: AppColors.background,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              background: imageUrl.isNotEmpty
                  ? Image.network(imageUrl, fit: BoxFit.cover)
                  : Container(
                      color: AppColors.surface,
                      child: const Center(
                          child: Icon(Icons.image,
                              size: 80, color: Colors.white24)),
                    ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.bird.species ?? "Noma'lum",
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      if (widget.bird.status == 'active')
                        const Icon(Icons.verified,
                            color: AppColors.primary, size: 28),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    formattedPrice,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppColors.primary, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 20),
                  const Text('Tavsifi',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 16)),
                  const SizedBox(height: 8),
                  Text(
                    widget.bird.description ?? "Tavsif kiritilmagan",
                    style: const TextStyle(
                        fontSize: 16, height: 1.5, color: Colors.white),
                  ),
                  const SizedBox(height: 30),

                  // Action Buttons
                  GlassContainer(
                    radius: 16,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const CircleAvatar(
                              backgroundColor: AppColors.surface,
                              child: Icon(Icons.person, color: Colors.white),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(widget.bird.sellerName,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16)),
                                  Text(widget.bird.regionName,
                                      style: const TextStyle(
                                          color: AppColors.textSecondary)),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                if (widget.bird.sellerPhone != null &&
                                    widget.bird.sellerPhone!.isNotEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              'Calling: ${widget.bird.sellerPhone}')));
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Telefon raqam yashirilgan yoki mavjud emas.')));
                                }
                              },
                              icon: const Icon(Icons.call,
                                  color: AppColors.primary),
                              style: IconButton.styleFrom(
                                  backgroundColor:
                                      AppColors.primary.withOpacity(0.1)),
                            ),
                            if (widget.bird.allowTelegram) ...[
                              const SizedBox(width: 8),
                              IconButton(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              'Yozish: @${widget.bird.sellerTelegram ?? 'Noma\'lum'}')));
                                },
                                icon: const Icon(Icons.telegram,
                                    color: Colors.blueAccent),
                                style: IconButton.styleFrom(
                                    backgroundColor:
                                        Colors.blueAccent.withOpacity(0.1)),
                              ),
                            ]
                          ],
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isProcessing ? null : _handleEscrow,
                            style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryDark),
                            child: _isProcessing
                                ? const CircularProgressIndicator(
                                    color: Colors.white)
                                : const Text('Xavfsiz To\'lov (Escrow)',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

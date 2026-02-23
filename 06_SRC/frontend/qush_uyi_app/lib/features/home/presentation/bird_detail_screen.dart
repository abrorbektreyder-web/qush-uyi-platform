import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../data/bird_model.dart';

class BirdDetailScreen extends StatelessWidget {
  final BirdModel bird;

  const BirdDetailScreen({super.key, required this.bird});

  @override
  Widget build(BuildContext context) {
    String imageUrl = bird.media.isNotEmpty
        ? 'http://127.0.0.1:8000\${bird.media.first.url}'
        : '';
    final formattedPrice = '\${bird.price.toInt()} UZS'
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
                          bird.species ?? "Noma'lum",
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      if (bird.status == 'active')
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
                    bird.description ?? "Tavsif kiritilmagan",
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
                                  Text(bird.sellerName,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16)),
                                  Text(bird.regionName,
                                      style: const TextStyle(
                                          color: AppColors.textSecondary)),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () {}, // Trigger call
                              icon: const Icon(Icons.call,
                                  color: AppColors.primary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () {
                              // Trigger Safe Checkout Escrow logic
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryDark),
                            child: const Text('Xavfsiz Sotib Olish (Escrow)',
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

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/glass_container.dart';
import '../data/bird_model.dart';
import 'providers/home_provider.dart';
import '../../../core/network/api_client.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(birdsNotifierProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final stateAsync = ref.watch(birdsNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Qush Uyi',
            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: stateAsync.when(
        data: (state) {
          if (state.birds.isEmpty) {
            return const Center(
              child: Text("Hozircha e'lonlar yo'q",
                  style: TextStyle(color: Colors.white)),
            );
          }
          return _buildContent(state);
        },
        loading: () => _buildSkeleton(),
        error: (err, stack) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Xatolik: $err',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () =>
                    ref.read(birdsNotifierProvider.notifier).fetchInitial(),
                child: const Text('Qayta yuklash'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkeleton() {
    return Skeletonizer(
      enabled: true,
      containersColor: AppColors.surface,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5,
        itemBuilder: (context, index) {
          return const _BirdCardSkeleton();
        },
      ),
    );
  }

  Widget _buildContent(BirdsState state) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: state.birds.length + (state.isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= state.birds.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }

        final bird = state.birds[index];
        final formattedPrice = '${bird.price.toInt()} UZS'
            .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ' ');

        return _PremiumBirdCard(
          bird: bird,
          formattedPrice: formattedPrice,
        );
      },
    );
  }
}

class _BirdCardSkeleton extends StatelessWidget {
  const _BirdCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: GlassContainer(
        padding: EdgeInsets.zero,
        radius: 20,
        child: Column(
          children: [
            Container(
              height: 200,
              width: double.infinity,
              color: Colors.grey[800],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Sayroqi Qush Skelet Nomi',
                      style: TextStyle(fontSize: 18)),
                  SizedBox(height: 8),
                  Text('1 000 000 UZS'),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 16),
                      Text(' Samarqand viloyati'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PremiumBirdCard extends StatelessWidget {
  final BirdModel bird;
  final String formattedPrice;

  const _PremiumBirdCard({
    required this.bird,
    required this.formattedPrice,
  });

  @override
  Widget build(BuildContext context) {
    String imageUrl = '';
    if (bird.media.isNotEmpty) {
      imageUrl = '$baseUrl${bird.media.first.url}';
    }

    return GestureDetector(
      onTap: () {
        context.push('/home/detail', extra: bird);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: GlassContainer(
          padding: EdgeInsets.zero,
          radius: 20,
          child: Column(
            children: [
              // Image Section with verification badge
              Stack(
                children: [
                  Container(
                    height: 220,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20)),
                      image: imageUrl.isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(imageUrl),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: imageUrl.isEmpty
                        ? Center(
                            child: Icon(Icons.image,
                                size: 60, color: Colors.white.withOpacity(0.1)),
                          )
                        : const SizedBox(),
                  ),
                  if (bird.status == 'active')
                    Positioned(
                      top: 12,
                      right: 12,
                      child: GlassContainer(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        radius: 12,
                        color: AppColors.primaryDark.withOpacity(0.3),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.verified,
                                color: AppColors.primary, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              'Vet Tasdiqlagan',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              // Details Section
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            bird.species ?? "Noma'lum qush",
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                    fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            formattedPrice,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(Icons.location_on,
                                  size: 14, color: AppColors.textSecondary),
                              const SizedBox(width: 4),
                              Text(
                                bird.regionName,
                                style: Theme.of(context)
                                    .textTheme
                                    .labelMedium
                                    ?.copyWith(color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Cart button → opens detail page
                    ElevatedButton(
                      onPressed: () {
                        context.push('/home/detail', extra: bird);
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
                        shape: const CircleBorder(),
                      ),
                      child: const Icon(Icons.shopping_cart_checkout,
                          color: AppColors.background),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

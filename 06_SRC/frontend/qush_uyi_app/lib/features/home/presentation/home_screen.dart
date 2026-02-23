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
          child: Text('Xatolik: $err\nURL: $baseUrl',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red)),
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
          title: bird.species ?? "Noma'lum qush",
          price: formattedPrice,
          location: bird.regionName,
          isVerified: bird.status == 'active',
          mediaList: bird.media,
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
              color: Colors.grey[800], // Skeleton standard image block
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Sayroqi Qush Skelet Nomi',
                      style: TextStyle(fontSize: 18)),
                  const SizedBox(height: 8),
                  const Text('1 000 000 UZS'),
                  const SizedBox(height: 16),
                  const Row(
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
  final String title;
  final String price;
  final String location;
  final bool isVerified;
  final List<MediaModel> mediaList;

  const _PremiumBirdCard({
    required this.title,
    required this.price,
    required this.location,
    required this.isVerified,
    required this.mediaList,
  });

  @override
  Widget build(BuildContext context) {
    String imageUrl = '';
    if (mediaList.isNotEmpty) {
      imageUrl = '$baseUrl${mediaList.first.url}';
    }

    return GestureDetector(
      onTap: () {
        final bird = BirdModel(
            id: 'temp_will_bind_from_param',
            categoryId: 1,
            price:
                double.tryParse(price.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0.0,
            status: isVerified ? 'active' : 'inactive',
            regionName: location,
            sellerName: 'Sotuvchi',
            species: title,
            media: mediaList);
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
                      color: AppColors.surface, // Placeholder for image
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
                  if (isVerified)
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
                            title,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                    fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            price,
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
                                location,
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
                    // Premium Button
                    ElevatedButton(
                      onPressed: () {},
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

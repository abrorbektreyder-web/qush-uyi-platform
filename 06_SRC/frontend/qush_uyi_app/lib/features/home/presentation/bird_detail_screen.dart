import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/glass_container.dart';
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
    // Check price > 0
    if (widget.bird.price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Bu e\'londa narx ko\'rsatilmagan. Sotuvchiga bog\'laning.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Confirm dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text("To'lov tasdiqlash",
            style: TextStyle(color: Colors.white)),
        content: Text(
          "Siz \"${widget.bird.species}\" uchun ${_formatPrice(widget.bird.price)} to'lov qilmoqchisiz.\n\n"
          "Pul sizning hisobingizda muzlatiladi. Tovar qo'lingizga yetgach, admin pul sotuvchiga uzatadi.",
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Bekor qilish',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Tasdiqlash"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isProcessing = true);

    // Get real user_id fron SharedPreferences or generate
    final prefs = await SharedPreferences.getInstance();
    String buyerId = prefs.getString('user_id') ?? '';
    if (buyerId.isEmpty) {
      buyerId = 'buyer_${DateTime.now().millisecondsSinceEpoch}';
      await prefs.setString('user_id', buyerId);
    }

    final repo = ref.read(paymentRepositoryProvider);
    final success = await repo.processEscrowPayment(
      birdId: widget.bird.id,
      amount: widget.bird.price,
      buyerId: buyerId,
    );
    setState(() => _isProcessing = false);

    if (success && mounted) {
      showDialog(
        context: context,
        builder: (c) => AlertDialog(
          backgroundColor: AppColors.surface,
          title: Row(
            children: const [
              Icon(Icons.check_circle, color: AppColors.primary, size: 28),
              SizedBox(width: 12),
              Expanded(
                child: Text("Muvaffaqiyatli!",
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
          content: Text(
              "Pul muvaffaqiyatli muzlatildi — ${_formatPrice(widget.bird.price)}.\n\n"
              "Sotuvchi sizga qushni yetkazib berishi kerak. "
              "Qushni qo'lingizga olgach, admin tomonidan pul sotuvchiga o'tkaziladi.\n\n"
              "Muammo bo'lsa, profilda \"Nizo ochish\" tugmasini bosing.",
              style: const TextStyle(color: Colors.white70)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(c);
                Navigator.pop(context); // Go back to home
              },
              child: const Text('Tushunarli',
                  style: TextStyle(color: AppColors.primary)),
            )
          ],
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Bu qush allaqachon band qilingan yoki xatolik yuz berdi.'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  String _formatPrice(double price) {
    return '${price.toInt()} UZS'
        .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ' ');
  }

  /// Open phone dialer
  Future<void> _callSeller() async {
    final phone = widget.bird.sellerPhone;
    if (phone != null && phone.isNotEmpty) {
      final uri = Uri.parse('tel:$phone');
      try {
        await launchUrl(uri);
      } catch (_) {
        if (mounted) {
          // Copy phone number as fallback
          Clipboard.setData(ClipboardData(text: phone));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('📋 Raqam nusxalandi: $phone'),
              backgroundColor: AppColors.primary,
            ),
          );
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Sotuvchi telefon raqamini yashirgan. Telegram orqali yozing.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  /// Open Telegram chat
  Future<void> _openTelegram() async {
    final telegramId = widget.bird.sellerTelegram;

    if (telegramId != null &&
        telegramId.isNotEmpty &&
        telegramId != 'null' &&
        telegramId != 'None') {
      Uri telegramUri;

      if (telegramId.startsWith('@')) {
        // Username
        telegramUri = Uri.parse('https://t.me/${telegramId.substring(1)}');
      } else if (telegramId.startsWith('+')) {
        // Phone number with +
        telegramUri = Uri.parse('https://t.me/$telegramId');
      } else if (RegExp(r'^\d+$').hasMatch(telegramId)) {
        // Numeric ID — try as user link
        telegramUri = Uri.parse('tg://user?id=$telegramId');
      } else {
        // Treat as username
        telegramUri = Uri.parse('https://t.me/$telegramId');
      }

      try {
        await launchUrl(telegramUri, mode: LaunchMode.externalApplication);
      } catch (_) {
        if (mounted) {
          Clipboard.setData(ClipboardData(text: telegramId));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('📋 Telegram: $telegramId nusxalandi'),
              backgroundColor: Colors.blueAccent,
            ),
          );
        }
      }
    } else {
      // Fallback: use phone number for telegram
      final phone = widget.bird.sellerPhone;
      if (phone != null && phone.isNotEmpty) {
        final uri = Uri.parse('https://t.me/$phone');
        try {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } catch (_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Telegramda $phone ga yozing'),
                backgroundColor: Colors.blueAccent,
              ),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text('Sotuvchining aloqa ma\'lumotlari hali kiritilmagan.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String imageUrl = widget.bird.media.isNotEmpty
        ? 'https://qush-uyi-platform-production-0146.up.railway.app${widget.bird.media.first.url}'
        : '';
    final formattedPrice = _formatPrice(widget.bird.price);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            backgroundColor: AppColors.background,
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [
              IconButton(
                icon: const Icon(Icons.share, color: Colors.white),
                onPressed: () {
                  final textToShare =
                      "Yangi qush sotuvda: ${widget.bird.species} - $formattedPrice\nBatafsil: https://qush-uyi.uz/birds/${widget.bird.id}";
                  Clipboard.setData(ClipboardData(text: textToShare));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          "E'lon nusxalandi! Do'stlaringizga yuboring.",
                          style: TextStyle(color: Colors.white)),
                      backgroundColor: Colors.blueAccent,
                      duration: Duration(seconds: 3),
                    ),
                  );
                },
              ),
            ],
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

                  // Seller Card & Actions
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
                            // Phone call
                            IconButton(
                              onPressed: _callSeller,
                              icon: const Icon(Icons.call,
                                  color: AppColors.primary),
                              style: IconButton.styleFrom(
                                  backgroundColor:
                                      AppColors.primary.withOpacity(0.1)),
                              tooltip: 'Qo\'ng\'iroq qilish',
                            ),
                            // Telegram
                            if (widget.bird.allowTelegram) ...[
                              const SizedBox(width: 8),
                              IconButton(
                                onPressed: _openTelegram,
                                icon: const Icon(Icons.telegram,
                                    color: Colors.blueAccent),
                                style: IconButton.styleFrom(
                                    backgroundColor:
                                        Colors.blueAccent.withOpacity(0.1)),
                                tooltip: 'Telegram orqali yozish',
                              ),
                            ]
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Escrow button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isProcessing ? null : _handleEscrow,
                            style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryDark),
                            child: _isProcessing
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 2.5),
                                  )
                                : const Text('Xavfsiz To\'lov (Escrow)',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Pul admin tomonidan muzlatiladi. Tovarni qo'lingizga olgach, pul sotuvchiga o'tkaziladi.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: AppColors.textSecondary, fontSize: 11),
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

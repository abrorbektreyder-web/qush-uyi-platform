import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/glass_container.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  String _userName = 'Foydalanuvchi';
  String _userPhone = '';
  int _listingsCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('user_name') ?? 'Foydalanuvchi';
      _userPhone = prefs.getString('user_phone') ?? '+998 XX XXX XX XX';
      _listingsCount = prefs.getInt('listing_count') ?? 0;
    });
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Tizimdan chiqish',
            style: TextStyle(color: Colors.white)),
        content: const Text('Haqiqatan ham tizimdan chiqmoqchimisiz?',
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Bekor qilish',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              if (mounted) {
                context.go('/splash');
              }
            },
            child:
                const Text('Chiqish', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _showSavedItems() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            const Icon(Icons.favorite_border,
                size: 60, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            const Text(
              "Saqlanganlar ro'yxati bo'sh",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Yoqqan e'lonlarni ❤️ tugmasi bilan saqlang va ularni bu yerda ko'ring.",
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  context.go('/home');
                },
                child: const Text("E'lonlarni ko'rish"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showVerificationCenter() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            const Icon(Icons.verified_user, size: 60, color: AppColors.primary),
            const SizedBox(height: 16),
            const Text(
              'Verifikatsiya Markazi',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            GlassContainer(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildVerifyItem(
                    Icons.phone_android,
                    'Telefon raqam',
                    'Tasdiqlangan ✅',
                    true,
                  ),
                  const Divider(color: AppColors.glassBorder),
                  _buildVerifyItem(
                    Icons.telegram,
                    'Telegram',
                    'Bog\'lanmagan',
                    false,
                  ),
                  const Divider(color: AppColors.glassBorder),
                  _buildVerifyItem(
                    Icons.badge,
                    'Shaxs guvohnomasi',
                    'Tekshirilmagan',
                    false,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Verifikatsiyadan o'tish orqali e'lonlaringiz yuqori o'rinlarda ko'rsatiladi va xaridorlar ishonchi oshadi.",
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildVerifyItem(
      IconData icon, String title, String status, bool isVerified) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: isVerified ? AppColors.primary : Colors.white54),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600)),
                Text(status,
                    style: TextStyle(
                        color: isVerified ? AppColors.primary : Colors.orange,
                        fontSize: 12)),
              ],
            ),
          ),
          Icon(
            isVerified ? Icons.check_circle : Icons.arrow_forward_ios,
            color: isVerified ? AppColors.primary : Colors.white24,
            size: 20,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profil'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // User Avatar
            const Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: AppColors.surface,
                child: Icon(Icons.person,
                    size: 50, color: AppColors.textSecondary),
              ),
            ).animate().scale(delay: 100.ms, duration: 400.ms),
            const SizedBox(height: 16),
            Center(
                child: Text(_userName,
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white))),
            const SizedBox(height: 4),
            Center(
                child: Text(_userPhone,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 16))),
            const SizedBox(height: 24),

            // Stats
            Row(
              children: [
                Expanded(
                    child: _buildStatCard(
                        "E'lonlar", '$_listingsCount', Icons.list_alt)),
                const SizedBox(width: 16),
                Expanded(
                    child: _buildStatCard(
                        "Muzlatilgan", "0 UZS", Icons.account_balance_wallet)),
              ],
            ).animate().slideY(begin: 0.2, duration: 400.ms).fadeIn(),

            const SizedBox(height: 24),

            // Menu
            GlassContainer(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _buildListTile(Icons.favorite_border, "Saqlanganlar",
                      onTap: _showSavedItems),
                  _buildDivider(),
                  _buildListTile(
                      Icons.shopping_bag_outlined, "Mening xaridlarim (Escrow)",
                      onTap: () => context.push('/orders')),
                  _buildDivider(),
                  _buildListTile(
                      Icons.storefront, "Mening buyurtmalarim (Shop)",
                      onTap: () => context.push('/shop')),
                  _buildDivider(),
                  _buildListTile(
                      Icons.verified_user_outlined, "Verifikatsiya markazi",
                      onTap: _showVerificationCenter),
                  _buildDivider(),
                  _buildListTile(Icons.settings_outlined, "Sozlamalar",
                      onTap: () => context.push('/profile/settings')),
                  _buildDivider(),
                  _buildListTile(Icons.exit_to_app, "Tizimdan chiqish",
                      isDestructive: true, onTap: _handleLogout),
                ],
              ),
            )
                .animate()
                .slideY(begin: 0.2, delay: 200.ms, duration: 400.ms)
                .fadeIn(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 28),
          const SizedBox(height: 12),
          Text(value,
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          const SizedBox(height: 4),
          Text(title,
              style: const TextStyle(
                  fontSize: 14, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildListTile(IconData icon, String title,
      {bool isDestructive = false, VoidCallback? onTap}) {
    return ListTile(
      leading:
          Icon(icon, color: isDestructive ? AppColors.error : Colors.white70),
      title: Text(title,
          style: TextStyle(
              color: isDestructive ? AppColors.error : Colors.white,
              fontWeight: FontWeight.w500)),
      trailing: isDestructive
          ? null
          : const Icon(Icons.chevron_right, color: Colors.white30),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return const Divider(
        height: 1, color: AppColors.glassBorder, indent: 16, endIndent: 16);
  }
}

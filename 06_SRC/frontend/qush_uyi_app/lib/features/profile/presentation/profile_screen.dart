import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/glass_container.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
            // User Meta
            const Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: AppColors.surface,
                child: Icon(Icons.person,
                    size: 50, color: AppColors.textSecondary),
              ),
            ).animate().scale(delay: 100.ms, duration: 400.ms),
            const SizedBox(height: 16),
            const Center(
                child: Text("Ali Valiyev",
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white))),
            const SizedBox(height: 4),
            const Center(
                child: Text("+998 90 123 45 67",
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 16))),
            const SizedBox(height: 24),

            // Stats
            Row(
              children: [
                Expanded(
                    child: _buildStatCard("E'lonlar", "12", Icons.list_alt)),
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
                      onTap: () {}),
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
                      onTap: () {}),
                  _buildDivider(),
                  _buildListTile(Icons.settings_outlined, "Sozlamalar",
                      onTap: () => context.push('/profile/settings')),
                  _buildDivider(),
                  _buildListTile(Icons.exit_to_app, "Tizimdan chiqish",
                      isDestructive: true, onTap: () {}),
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
